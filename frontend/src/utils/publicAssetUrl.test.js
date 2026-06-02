import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// resolveApiPublicUrl reads import.meta.env at call time — stub before importing.
// We re-import the module per describe block using dynamic import + vi.resetModules().

describe('resolveApiPublicUrl — basic cases', () => {
  let resolveApiPublicUrl;

  beforeEach(async () => {
    vi.resetModules();
    vi.stubEnv('VITE_API_BASE_URL', '');
    vi.stubEnv('VITE_UPLOADS_ORIGIN', '');
    vi.stubEnv('VITE_STORAGE_BUCKET_ENDPOINT', '');
    vi.stubEnv('VITE_STORAGE_BUCKET_NAME', '');
    ({ resolveApiPublicUrl } = await import('./publicAssetUrl.js'));
  });

  afterEach(() => { vi.unstubAllEnvs(); });

  it('returns empty string for null', () => {
    expect(resolveApiPublicUrl(null)).toBe('');
  });

  it('returns empty string for empty string', () => {
    expect(resolveApiPublicUrl('')).toBe('');
  });

  it('returns empty string for non-string input', () => {
    expect(resolveApiPublicUrl(42)).toBe('');
  });

  it('returns absolute https URL unchanged', () => {
    expect(resolveApiPublicUrl('https://cdn.example.com/image.png')).toBe('https://cdn.example.com/image.png');
  });

  it('strips the duplicate /api prefix from /api/uploads/ paths', () => {
    // /api/uploads/logo.png → /uploads/logo.png internally, then
    // window.location.origin + /api + /uploads/logo.png in jsdom
    const result = resolveApiPublicUrl('/api/uploads/logo.png');
    expect(result).toContain('/uploads/logo.png');
    // Must NOT double-prefix as /api/api/uploads/
    expect(result).not.toContain('/api/api/');
  });
});

describe('resolveApiPublicUrl — with VITE_API_BASE_URL', () => {
  let resolveApiPublicUrl;

  beforeEach(async () => {
    vi.resetModules();
    vi.stubEnv('VITE_API_BASE_URL', 'https://api.example.com/api');
    vi.stubEnv('VITE_UPLOADS_ORIGIN', '');
    vi.stubEnv('VITE_STORAGE_BUCKET_ENDPOINT', '');
    vi.stubEnv('VITE_STORAGE_BUCKET_NAME', '');
    ({ resolveApiPublicUrl } = await import('./publicAssetUrl.js'));
  });

  afterEach(() => { vi.unstubAllEnvs(); });

  it('prepends API base to /uploads/ paths', () => {
    const result = resolveApiPublicUrl('/uploads/avatar.png');
    expect(result).toBe('https://api.example.com/api/uploads/avatar.png');
  });
});

describe('resolveApiPublicUrl — with VITE_UPLOADS_ORIGIN override', () => {
  let resolveApiPublicUrl;

  beforeEach(async () => {
    vi.resetModules();
    vi.stubEnv('VITE_API_BASE_URL', 'https://api.example.com/api');
    vi.stubEnv('VITE_UPLOADS_ORIGIN', 'https://uploads.example.com/api');
    vi.stubEnv('VITE_STORAGE_BUCKET_ENDPOINT', '');
    vi.stubEnv('VITE_STORAGE_BUCKET_NAME', '');
    ({ resolveApiPublicUrl } = await import('./publicAssetUrl.js'));
  });

  afterEach(() => { vi.unstubAllEnvs(); });

  it('uses VITE_UPLOADS_ORIGIN for /uploads/ paths', () => {
    const result = resolveApiPublicUrl('/uploads/logo.png');
    expect(result).toBe('https://uploads.example.com/api/uploads/logo.png');
  });
});
