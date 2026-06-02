# EzCRM — Claude Code Project Memory

## Project Overview

**EzCRM / GCRM** is a multi-tenant CRM + ERP system with three sub-projects:

| Sub-project | Tech | Dev port |
|---|---|---|
| `backend/` | NestJS + TypeScript + PostgreSQL + Redis | 4000 |
| `frontend/` | React 19 + Vite + Tailwind CSS + React Router v7 | 5173 |
| `crm_mobile/` | Flutter | — |

API base path prefix: `/api` (all routes are under `/api/...`)

---

## Architecture

### Backend (`backend/`)

- **Framework**: NestJS with `ts-node-dev` for dev, compiled TypeScript for prod
- **Database**: PostgreSQL via raw `pg` queries — no ORM (Prisma/TypeORM). All DB access goes through `DatabaseService`
- **Migrations**: Custom migrator at `src/database/migrate.ts`
  - `npm run migrate` — run pending migrations
  - `npm run migrate:fresh` — drop and recreate schema
  - `npm run migrate:status` — show migration state
- **Auth**: JWT access + refresh tokens. `bcryptjs` for passwords. Tokens stored in localStorage on frontend
- **Multi-tenancy**: Tenant slug-based. `TenantsService` normalizes slugs (lowercase, hyphens only)
- **File storage**: Local `./uploads` directory OR Hostinger S3-compatible object storage (configured via `STORAGE_BUCKET_*` env vars). `ObjectStorageService` abstracts both
- **PDF generation**: `PDFKit` for direct PDF output; `Puppeteer` for HTML-to-PDF (sales documents)
- **Push notifications**: Firebase Admin SDK (FCM) for mobile + `web-push` for browser
- **Caching/queues**: `ioredis` (Redis)
- **Scheduled jobs**: `@nestjs/schedule`

### Backend modules (`src/modules/`)

`auth`, `crm`, `sales`, `inventory`, `purchase`, `finance`, `hr`, `settings`, `tenants`, `users`, `notifications`, `communication`, `audit`, `export`, `production`

### Frontend (`frontend/`)

- **Build tool**: Vite 8
- **Styling**: Tailwind CSS 3
- **HTTP**: Axios with in-memory access token + auto-refresh on 401
- **API base**: `VITE_API_BASE_URL` env var (defaults to `/api` via Vite proxy in dev)
- **Charts**: Recharts
- **Testing**: Vitest + coverage via v8

### Mobile (`crm_mobile/`)

- Flutter app; API base URL passed at build time: `--dart-define=API_BASE_URL=http://...`
- Android emulator default: `http://10.0.2.2:4000/api`

---

## Environment Variables

### Backend (`.env`)

```
PORT=4000
DATABASE_URL=postgresql://...
JWT_SECRET=...
JWT_EXPIRES_IN=1d          # use span strings, NOT bare integers (would be ms not s)
STORAGE_BUCKET_*=...       # optional S3-compatible object storage
FCM_SERVICE_ACCOUNT_JSON=  # or FCM_SERVICE_ACCOUNT_PATH
FACEBOOK_APP_ID/SECRET/WEBHOOK_TOKEN  # optional Facebook Lead Ads
WEB_APP_ORIGIN=            # optional, for push notification deep links
```

### Frontend (`.env`)

```
VITE_API_BASE_URL=http://localhost:4000/api   # or production URL
```

---

## Key Dev Commands

### Backend

```powershell
cd backend
npm install
npm run migrate
npm run start:dev
```

### Frontend

```powershell
cd frontend
npm install
npm run dev
npm run test
npm run build
```

### Mobile

```powershell
cd crm_mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000/api
```

---

## Important Patterns & Conventions

- **No ORM**: Never introduce Prisma/TypeORM. Write raw SQL via `DatabaseService`
- **JWT timing**: `JWT_EXPIRES_IN` env vars are always strings. Parse digit-only strings to `Number` (seconds) before passing to jsonwebtoken — bare `"86400"` string is treated as milliseconds (~86s) by the `ms()` library
- **Tenant slug normalization**: Always use `normalizeSlug()` in `TenantsService` — lowercase, alphanumeric + hyphens only
- **File uploads**: Check whether object storage env vars are set before deciding local vs. S3 path
- **API client**: Access token lives in `accessTokenMem` (in-memory) + localStorage. Token refresh happens only in the Axios 401 response interceptor, never in request interceptor
- **Mobile API URL**: Must end with `/api` — the app appends paths directly

---

## Deployment

### Backend — Hostinger VPS

- **Server IP**: `187.127.167.12`
- **SSH**: `ssh root@187.127.167.12 -i ~/.ssh/id_ezcrm`
- **App path**: `/home/redonix/public_html/api-ezcrm`
- **API URL**: `https://api-ezcrm.redonix.in/api`
- **Deploy steps**:
  1. `git pull` inside `/home/redonix/public_html/api-ezcrm`
  2. `npm install`
  3. `npm run migrate` (run any pending migrations)
  4. `npm run build` then restart the process (PM2 or systemd)

### Frontend — Hostinger Cloud Hosting

- **Domain**: `app.ezflowcrm.com`
- **FTP host**: `88.222.211.181` (port 21)
- **FTP user**: `u547357606.app.ezflowcrm.com`
- **Upload folder**: `public_html`
- **Deploy script**: `deploy_frontend_ftp.ps1` (builds then FTPs `frontend/dist`)
- **Deploy steps**:
  1. `cd frontend && npm run build`
  2. Run `.\deploy_frontend_ftp.ps1` from project root

---

## Facebook Lead Ads (optional integration)

Connect via: Web → Settings → Lead platforms → Facebook Pages → "Continue with Facebook"

Required Meta app permissions: `pages_show_list`, `pages_read_engagement`, `leads_retrieval`

Common errors:
- `#100 requires pages_read_engagement` → disconnect + reconnect, enable all permissions in Meta dialog
- `#190 must be called with a Page Access Token` → token is a User token not a Page token; reconnect via OAuth flow

---

## Current Branch

`Change-Leads-only-landing-admin-User` — feature branch off `main`
