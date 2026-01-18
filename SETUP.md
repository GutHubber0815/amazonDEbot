# Setup Guide - Early Help

## Step-by-Step Setup Instructions

### 1. Clone and Install

```bash
cd /path/to/early-help-monorepo
pnpm install
```

### 2. Supabase Setup

#### Create Project
1. Go to https://supabase.com
2. Click "New Project"
3. Choose organization and region
4. Set database password (save it!)
5. Wait for project to initialize

#### Run Database Schema
1. In Supabase dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy entire contents of `supabase/schema.sql`
4. Paste into SQL Editor
5. Click "Run" or press Cmd/Ctrl + Enter
6. Verify success (should see "Success. No rows returned")

#### Seed Database
1. In SQL Editor, create another new query
2. Copy entire contents of `supabase/seed.sql`
3. Paste and run
4. Verify: Go to **Table Editor**, check tables have data

#### Create Admin User

**Option 1: Via Supabase Auth UI**
1. Go to **Authentication** → **Users**
2. Click "Add User"
3. Enter email and password
4. After creation, click on the user
5. Go to "Raw User Meta Data"
6. Add: `{"role": "admin"}`
7. Save

**Option 2: Via SQL**
```sql
-- In SQL Editor
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_user_meta_data,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@example.com',
  crypt('YourSecurePassword123', gen_salt('bf')),
  NOW(),
  '{"role": "admin"}'::jsonb,
  NOW(),
  NOW()
);
```

### 3. Get Supabase Credentials

1. In Supabase dashboard, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (long string starting with `eyJ...`)

### 4. Configure Web App

```bash
cd apps/web
cp .env.example .env.local
```

Edit `apps/web/.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxxxx...
```

### 5. Configure Mobile App

```bash
cd apps/mobile
cp .env.example .env
```

Edit `apps/mobile/.env`:
```env
EXPO_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJxxxxx...
```

### 6. Run Web App

```bash
cd apps/web
pnpm dev
```

Open http://localhost:3000

**Test it:**
- Browse to http://localhost:3000
- Click "Content Library" - should see 12 articles
- Click "Glossary" - should see 30 terms
- Go to http://localhost:3000/admin
- Login with admin credentials
- Verify admin dashboard loads

### 7. Run Mobile App

```bash
cd apps/mobile
pnpm start
```

**Options:**
- Press `i` for iOS simulator
- Press `a` for Android emulator
- Scan QR code with Expo Go app on phone

**Test it:**
- App should load with home screen
- Navigate to Library - should load articles
- Check Checklist - should save locally
- Test Help Navigator filters

## Troubleshooting

### "Missing Supabase environment variables"
- Make sure `.env.local` (web) or `.env` (mobile) exists
- Check variable names are exactly as shown
- Restart dev server after changing .env files

### "Failed to fetch" errors in web app
- Verify Supabase project is active
- Check Project URL is correct
- Ensure anon key is the **anon/public** key, not service key
- Check browser console for CORS errors

### Database permissions errors
- Verify RLS policies were created (check schema.sql ran successfully)
- Ensure admin user has `role: "admin"` in user_metadata
- Check SQL Editor for any error messages

### Mobile app won't connect
- Environment variables must start with `EXPO_PUBLIC_`
- Clear Expo cache: `npx expo start -c`
- Check phone and computer are on same network

### TypeScript errors
```bash
# From root directory
pnpm install
turbo run build
```

### Tests failing
```bash
cd packages/utils
pnpm install
pnpm test
```

## Verification Checklist

- [ ] pnpm install completed without errors
- [ ] Supabase project created
- [ ] Schema SQL executed successfully
- [ ] Seed SQL executed successfully
- [ ] Admin user created
- [ ] Environment variables configured
- [ ] Web app runs on http://localhost:3000
- [ ] Can see library entries on web app
- [ ] Admin login works
- [ ] Mobile app launches
- [ ] Mobile app can fetch data

## Next Steps

1. **Customize Content**: Edit entries via admin panel
2. **Add Real Contacts**: Replace dummy support contacts
3. **Test All Features**: Checklist, glossary, help navigator
4. **Review Privacy**: Ensure local storage works
5. **Test on Devices**: Try on real iOS device

## Production Deployment

### Web App (Vercel)
```bash
cd apps/web
pnpm build

# Deploy to Vercel
vercel deploy
```

Add environment variables in Vercel dashboard.

### Mobile App (EAS Build)
```bash
cd apps/mobile

# Install EAS CLI
npm install -g eas-cli

# Configure
eas build:configure

# Build for iOS
eas build --platform ios
```

See [Expo EAS documentation](https://docs.expo.dev/build/introduction/).

## Support

- Web framework: [Next.js docs](https://nextjs.org/docs)
- Mobile framework: [Expo docs](https://docs.expo.dev)
- Database: [Supabase docs](https://supabase.com/docs)
- Monorepo: [Turborepo docs](https://turbo.build/repo/docs)
