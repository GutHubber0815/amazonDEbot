# Supabase Setup for Early Help

## Prerequisites

1. Create a Supabase project at https://supabase.com
2. Note your project URL and anon key

## Database Setup

### 1. Run Schema

In your Supabase project:
1. Go to SQL Editor
2. Copy the contents of `schema.sql`
3. Run the SQL script

### 2. Seed Data

1. In SQL Editor, copy the contents of `seed.sql`
2. Run the SQL script to populate with dummy data

### 3. Create Admin User

In SQL Editor, run:

```sql
-- Create admin user (replace with your email and a secure password)
-- This creates the user in auth.users
-- You'll need to set role via user metadata in Supabase dashboard

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
  uuid_generate_v4(),
  'authenticated',
  'authenticated',
  'admin@example.com', -- Change this
  crypt('your-secure-password', gen_salt('bf')), -- Change this
  NOW(),
  '{"role": "admin"}'::jsonb,
  NOW(),
  NOW()
);
```

Or use Supabase Auth to sign up normally, then update user metadata in dashboard:
```json
{
  "role": "admin"
}
```

## Environment Variables

Add these to your apps:

```
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

## Privacy & GDPR Compliance

- ✅ No personal data about minors stored
- ✅ No user-generated content
- ✅ Row Level Security enabled on all tables
- ✅ Admin-only write access to content
- ✅ User favorites are opt-in with authentication
- ✅ Local-first storage for sensitive data (checklist)

## RLS Policies Summary

| Table | Public Read | User Write | Admin Write |
|-------|------------|------------|-------------|
| categories | ✅ | ❌ | ✅ |
| entries | ✅ (published) | ❌ | ✅ |
| glossary_items | ✅ | ❌ | ✅ |
| support_contacts | ✅ | ❌ | ✅ |
| entry_history | ❌ | ❌ | ✅ |
| favorites | Own only | Own only | ❌ |
