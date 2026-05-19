-- Migration 060: track when a follow-up reminder was last sent to avoid duplicates
ALTER TABLE lead_followups ADD COLUMN IF NOT EXISTS reminder_sent_at TIMESTAMPTZ;
