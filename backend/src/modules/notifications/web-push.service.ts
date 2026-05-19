import { Injectable, Logger } from '@nestjs/common';
import * as webpush from 'web-push';

@Injectable()
export class WebPushService {
  private readonly log = new Logger(WebPushService.name);
  private enabled = false;

  constructor() {
    const pub  = (process.env.VAPID_PUBLIC_KEY  || '').trim();
    const priv = (process.env.VAPID_PRIVATE_KEY || '').trim();
    const subj = (process.env.VAPID_SUBJECT      || 'mailto:admin@ezcrm.app').trim();
    if (pub && priv) {
      webpush.setVapidDetails(subj, pub, priv);
      this.enabled = true;
    } else {
      this.log.warn('Web Push disabled: set VAPID_PUBLIC_KEY and VAPID_PRIVATE_KEY in .env');
    }
  }

  get vapidPublicKey(): string {
    return (process.env.VAPID_PUBLIC_KEY || '').trim();
  }

  isWebSubscription(token: string): boolean {
    const t = token.trim();
    return t.startsWith('{') && t.includes('endpoint');
  }

  async sendToSubscription(subscriptionJson: string, payload: { title: string; body?: string; data?: Record<string, string> }) {
    if (!this.enabled) return { sent: 0, failed: 1, invalid: false };
    try {
      const sub = JSON.parse(subscriptionJson);
      await webpush.sendNotification(sub, JSON.stringify({
        title: payload.title,
        body: payload.body || '',
        data: payload.data || {},
      }));
      return { sent: 1, failed: 0, invalid: false };
    } catch (err: any) {
      const statusCode = err?.statusCode ?? 0;
      const invalid = statusCode === 404 || statusCode === 410;
      if (!invalid) this.log.warn('Web push send failed', err?.message);
      return { sent: 0, failed: 1, invalid };
    }
  }
}
