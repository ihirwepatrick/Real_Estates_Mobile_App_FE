# Easy Homes

Rwanda real-estate mobile app (Flutter) + Express API/admin UI (Render) on Supabase.

## Structure

```
lib/                 Flutter mobile app
backend/             Express API + /admin review UI
backend/supabase/    SQL migrations
```

## Quick start

### 1. Supabase

1. Create a project.
2. Run SQL in order:
   - `backend/supabase/migrations/001_initial_schema.sql`
   - `backend/supabase/migrations/002_storage_bucket.sql`
3. Create an Auth user and set `profiles.role = 'admin'` (see `backend/README.md`).

### 2. Backend (local)

```bash
cd backend
cp .env.example .env   # fill Supabase keys
npm install
npm run dev
```

- API health: http://localhost:3000/api/health
- Admin UI: http://localhost:3000/admin

### 3. Flutter

```bash
flutter pub get
# Android emulator → host machine:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
# Physical device (use your PC LAN IP):
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000
# Production Render URL:
flutter run --dart-define=API_BASE_URL=https://your-service.onrender.com
```

### 4. Deploy backend on Render

- Root directory: `backend`
- Build: `npm install`
- Start: `npm start`
- Env: see `backend/.env.example`

## Product rules (v1)

- Guests browse **approved** listings (rent/sale in Rwanda).
- Owners register/login in the app and submit listings (pending until admin approves).
- Admins review at `/admin` on the API host.
- Favorites are stored on-device (no login required).

## Play Store

See [PLAY_STORE.md](PLAY_STORE.md).
