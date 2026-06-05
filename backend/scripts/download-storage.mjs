/**
 * Download CRM upload files from production API into ./backups/storage.
 *
 * Usage (from backend/):
 *   node scripts/download-storage.mjs
 */

import { mkdirSync, existsSync, writeFileSync, readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendRoot = join(__dirname, '..');
const outRoot = join(backendRoot, 'backups', 'storage');

function loadDotEnv(path) {
  if (!existsSync(path)) return;
  for (const line of readLines(path)) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i < 0) continue;
    const key = t.slice(0, i).trim();
    let val = t.slice(i + 1).trim();
    if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
      val = val.slice(1, -1);
    }
    if (!(key in process.env)) process.env[key] = val;
  }
}

function readLines(path) {
  return readFileSync(path, 'utf8').split(/\r?\n/);
}

function cleanEnv(raw) {
  let s = String(raw || '').replace(/^\uFEFF/, '').trim();
  if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
    s = s.slice(1, -1).trim();
  }
  return s;
}

async function listDbPaths() {
  const url = cleanEnv(process.env.DATABASE_URL);
  if (!url) return [];
  const client = new pg.Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  const { rows } = await client.query(`
    SELECT DISTINCT path FROM (
      SELECT logo_url AS path FROM company_settings WHERE logo_url IS NOT NULL
      UNION SELECT favicon_url FROM company_settings WHERE favicon_url IS NOT NULL
      UNION SELECT invoice_logo_url FROM company_settings WHERE invoice_logo_url IS NOT NULL
      UNION SELECT avatar_url FROM users WHERE avatar_url IS NOT NULL
      UNION SELECT image_url FROM products WHERE image_url IS NOT NULL
    ) t WHERE path IS NOT NULL AND path <> '' ORDER BY 1
  `);
  await client.end();
  return rows.map((r) => String(r.path).trim()).filter(Boolean);
}

async function downloadHttp(apiBase, relPath) {
  const base = apiBase.replace(/\/$/, '');
  const rel = relPath.startsWith('/') ? relPath : `/${relPath}`;
  const url = `${base}${rel}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const dest = join(outRoot, rel.replace(/^\//, ''));
  mkdirSync(dirname(dest), { recursive: true });
  const buf = Buffer.from(await res.arrayBuffer());
  writeFileSync(dest, buf);
  return { dest, bytes: buf.length };
}

async function main() {
  loadDotEnv(join(backendRoot, '.env.production'));
  loadDotEnv(join(backendRoot, '.env'));

  const apiBase =
    cleanEnv(process.env.API_PUBLIC_URL) || 'https://api-ezcrm.redonix.in/api';
  mkdirSync(outRoot, { recursive: true });

  const manifest = { downloaded: [], failed: [], at: new Date().toISOString() };

  console.log('Downloading paths from database via production API …');
  const paths = await listDbPaths();
  for (const p of paths) {
    try {
      const { dest, bytes } = await downloadHttp(apiBase, p);
      manifest.downloaded.push({ path: p, file: dest, bytes });
      console.log(`  OK ${p} (${bytes} bytes)`);
    } catch (e) {
      manifest.failed.push({ path: p, error: String(e.message || e) });
      console.log(`  FAIL ${p}: ${e.message || e}`);
    }
  }

  const manifestPath = join(outRoot, 'manifest.json');
  writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
  console.log(`\nWrote ${manifestPath}`);
  console.log(
    `Summary: ${manifest.downloaded.length} downloaded, ${manifest.failed.length} failed`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
