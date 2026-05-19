import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useToast } from '../context/ToastContext';

function formatDateTime(dt) {
  if (!dt) return '—';
  return new Date(dt).toLocaleString(undefined, {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

function bucket(due) {
  if (!due) return 'later';
  const d = new Date(due);
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1);
  const weekEnd = new Date(today); weekEnd.setDate(today.getDate() + 7);
  if (d < today) return 'overdue';
  if (d < tomorrow) return 'today';
  if (d < new Date(tomorrow.getTime() + 86400000)) return 'tomorrow';
  if (d < weekEnd) return 'week';
  return 'later';
}

const SECTIONS = [
  { key: 'overdue',  label: 'Overdue',    color: 'text-red-600 dark:text-red-400',    border: 'border-red-200 dark:border-red-800/40',    bg: 'bg-red-50 dark:bg-red-900/10' },
  { key: 'today',    label: 'Today',      color: 'text-orange-600 dark:text-orange-400', border: 'border-orange-200 dark:border-orange-800/40', bg: 'bg-orange-50 dark:bg-orange-900/10' },
  { key: 'tomorrow', label: 'Tomorrow',   color: 'text-blue-600 dark:text-blue-400',   border: 'border-blue-200 dark:border-blue-800/40',   bg: 'bg-blue-50 dark:bg-blue-900/10' },
  { key: 'week',     label: 'This Week',  color: 'text-slate-700 dark:text-slate-300', border: 'border-slate-200 dark:border-slate-700',    bg: 'bg-white dark:bg-[#1a1d2e]' },
  { key: 'later',    label: 'Later',      color: 'text-slate-500 dark:text-slate-400', border: 'border-slate-200 dark:border-slate-700',    bg: 'bg-white dark:bg-[#1a1d2e]' },
];

export default function RemindersPage() {
  const { show: showToast } = useToast();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    try {
      const r = await api.get('/crm/leads/followups');
      setItems(Array.isArray(r.data) ? r.data : []);
    } catch {
      showToast('Could not load reminders', 'error');
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => { load(); }, [load]);

  const markDone = async (leadId, fid) => {
    try {
      await api.patch(`/crm/leads/${leadId}/followups/${fid}/done`);
      setItems(prev => prev.filter(f => f.id !== fid));
      showToast('Marked done', 'success');
    } catch {
      showToast('Could not mark done', 'error');
    }
  };

  const grouped = SECTIONS.map(s => ({
    ...s,
    items: items.filter(f => bucket(f.due_date) === s.key),
  })).filter(s => s.items.length > 0);

  return (
    <div className="space-y-5 max-w-3xl">
      <div>
        <h2 className="text-[16px] font-semibold text-slate-800 dark:text-slate-100">Reminders</h2>
        <p className="text-[11px] text-slate-500 dark:text-slate-400">All upcoming follow-up tasks across leads</p>
      </div>

      {loading && <p className="text-sm text-slate-500">Loading…</p>}
      {!loading && grouped.length === 0 && (
        <div className="bg-white dark:bg-[#1a1d2e] rounded-2xl border border-slate-200/80 dark:border-slate-700/50 shadow-card p-10 text-center">
          <p className="text-sm text-slate-400">No upcoming reminders</p>
        </div>
      )}

      {grouped.map(section => (
        <div key={section.key}>
          <h3 className={`text-xs font-bold uppercase tracking-widest mb-2 ${section.color}`}>
            {section.label} · {section.items.length}
          </h3>
          <div className="space-y-2">
            {section.items.map(f => (
              <div key={f.id} className={`flex items-start justify-between gap-3 rounded-xl border p-3 ${section.border} ${section.bg}`}>
                <div className="min-w-0 flex-1">
                  <Link
                    to={`/crm/leads/${f.lead_id}`}
                    className="text-sm font-semibold text-brand-600 dark:text-brand-400 hover:underline truncate block"
                  >
                    {f.lead_name || `Lead #${f.lead_id}`}
                    {f.lead_company ? <span className="font-normal text-slate-400 ml-1">· {f.lead_company}</span> : null}
                  </Link>
                  <p className="text-sm text-slate-700 dark:text-slate-200 mt-0.5">{f.description || 'Follow up'}</p>
                  <div className="flex flex-wrap gap-3 mt-1">
                    <span className={`text-xs ${section.key === 'overdue' ? 'text-red-500 font-medium' : 'text-slate-400'}`}>
                      {formatDateTime(f.due_date)}
                    </span>
                    {f.assigned_name && (
                      <span className="text-xs text-slate-400">→ {f.assigned_name}</span>
                    )}
                    {f.lead_stage && (
                      <span className="text-xs bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400 px-2 py-0.5 rounded-full">
                        {f.lead_stage}
                      </span>
                    )}
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => markDone(f.lead_id, f.id)}
                  className="flex-shrink-0 w-6 h-6 rounded-full border-2 border-slate-300 dark:border-slate-600 hover:border-emerald-500 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-colors mt-0.5"
                  title="Mark done"
                />
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
