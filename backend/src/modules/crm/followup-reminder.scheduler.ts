import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { DatabaseService } from '../../database/database.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class FollowupReminderScheduler {
  private readonly log = new Logger(FollowupReminderScheduler.name);

  constructor(
    private readonly db: DatabaseService,
    private readonly notifications: NotificationsService,
  ) {}

  // Runs every 5 minutes.
  // Reminder 1 — day-start (12 AM): fires once on the due date, as soon as the scheduler ticks after midnight.
  // Reminder 2 — 30 min before: fires once when due_date is within the next 30 minutes.
  // Both reminders go to the assignee AND all Admins / Sales Managers of the tenant.
  @Cron('*/5 * * * *')
  async sendFollowupReminders() {
    try {
      await this._sendDayStartReminders();
      await this._send30MinReminders();
    } catch (err) {
      this.log.error('Follow-up reminder scheduler failed', err);
    }
  }

  private async _getAdminIds(tenantId: number): Promise<number[]> {
    const res = await this.db.query(
      `SELECT id FROM users
        WHERE is_active = TRUE
          AND tenant_id = $1
          AND role IN ('Admin', 'Sales Manager', 'Super Admin')`,
      [tenantId],
    );
    return res.rows.map((r: any) => Number(r.id)).filter((id: number) => id > 0);
  }

  private async _notifyUsers(
    userIds: number[],
    tenantId: number,
    title: string,
    body: string,
    leadId: number,
  ) {
    const unique = [...new Set(userIds)].filter(id => id > 0);
    for (const uid of unique) {
      await this.notifications.createInAppAndPush({
        user_id:     uid,
        tenant_id:   tenantId || undefined,
        title,
        body,
        type:        'crm',
        module:      'crm',
        link:        `/crm/leads/${leadId}`,
        pushPayload: { leadId: String(leadId) },
      });
    }
  }

  private async _sendDayStartReminders() {
    const res = await this.db.query(
      `SELECT
          f.id, f.lead_id, f.description, f.due_date,
          f.assigned_to, l.name AS lead_name,
          l.assigned_to AS lead_assigned_to, l.tenant_id
         FROM lead_followups f
         JOIN leads l ON l.id = f.lead_id
        WHERE f.is_done = FALSE
          AND f.day_reminder_sent_at IS NULL
          AND f.due_date::date = CURRENT_DATE`,
    );
    if (!res.rows.length) return;

    for (const row of res.rows) {
      const tenantId  = Number(row.tenant_id) || 0;
      const assignee  = Number(row.assigned_to ?? row.lead_assigned_to) || 0;
      const admins    = tenantId > 0 ? await this._getAdminIds(tenantId) : [];
      const notifyIds = [...new Set([assignee, ...admins])].filter(id => id > 0);
      if (!notifyIds.length) continue;

      const leadName = String(row.lead_name || 'Lead');
      const desc     = String(row.description || 'Follow-up');
      const dueTime  = row.due_date
        ? new Date(row.due_date).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true })
        : '';

      await this._notifyUsers(
        notifyIds,
        tenantId,
        `Today: ${leadName}`,
        `${desc}${dueTime ? ` at ${dueTime}` : ''} is scheduled for today`,
        Number(row.lead_id),
      );

      await this.db.query(
        'UPDATE lead_followups SET day_reminder_sent_at = NOW() WHERE id = $1',
        [row.id],
      );
    }
    this.log.log(`Day-start reminders sent: ${res.rows.length}`);
  }

  private async _send30MinReminders() {
    const res = await this.db.query(
      `SELECT
          f.id, f.lead_id, f.description, f.due_date,
          f.assigned_to, l.name AS lead_name,
          l.assigned_to AS lead_assigned_to, l.tenant_id
         FROM lead_followups f
         JOIN leads l ON l.id = f.lead_id
        WHERE f.is_done = FALSE
          AND f.reminder_sent_at IS NULL
          AND f.due_date >= NOW()
          AND f.due_date <= NOW() + INTERVAL '30 minutes'`,
    );
    if (!res.rows.length) return;

    for (const row of res.rows) {
      const tenantId  = Number(row.tenant_id) || 0;
      const assignee  = Number(row.assigned_to ?? row.lead_assigned_to) || 0;
      const admins    = tenantId > 0 ? await this._getAdminIds(tenantId) : [];
      const notifyIds = [...new Set([assignee, ...admins])].filter(id => id > 0);
      if (!notifyIds.length) continue;

      const leadName = String(row.lead_name || 'Lead');
      const desc     = String(row.description || 'Follow-up');
      const dueTime  = row.due_date
        ? new Date(row.due_date).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true })
        : '';

      await this._notifyUsers(
        notifyIds,
        tenantId,
        `Due in 30 min: ${leadName}`,
        `${desc}${dueTime ? ` at ${dueTime}` : ''}`,
        Number(row.lead_id),
      );

      await this.db.query(
        'UPDATE lead_followups SET reminder_sent_at = NOW() WHERE id = $1',
        [row.id],
      );
    }
    this.log.log(`30-min reminders sent: ${res.rows.length}`);
  }
}
