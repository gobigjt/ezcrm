import { existsSync, unlinkSync } from 'fs';
import { join } from 'path';

/** Remove a file under `./uploads` from a stored `/uploads/...` or `/api/uploads/...` URL. */
export function deleteUploadByUrl(url: string | null | undefined): void {
  const raw = String(url || '').trim();
  if (!raw || /^https?:\/\//i.test(raw)) return;

  let rel = '';
  if (raw.startsWith('/uploads/')) rel = raw.slice('/uploads/'.length);
  else if (raw.startsWith('/api/uploads/')) rel = raw.slice('/api/uploads/'.length);
  else return;

  const fp = join(process.cwd(), 'uploads', rel);
  try {
    if (existsSync(fp)) unlinkSync(fp);
  } catch {
    /* ignore */
  }
}
