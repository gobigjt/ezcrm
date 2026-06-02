ALTER TABLE tenants ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 0;
COMMENT ON COLUMN tenants.max_users IS '0 = unlimited';
