# Early Help - Prevention & Civic Education App

A comprehensive educational platform for parents and teachers, focusing on radicalization prevention, media literacy, and civic education. Built with privacy-first principles and GDPR compliance.

## 🎯 Project Overview

**Early Help** provides:
- Educational content library on warning signs and prevention
- Codes & memes lexicon for understanding extremist symbols
- Self-guided warning signs checklist (stored locally)
- Help navigator for finding local support resources
- Admin panel for content management

### Key Principles
- ✅ **Privacy by design**: No personal data about minors stored
- ✅ **Local-first**: Sensitive data stays on device
- ✅ **Non-partisan**: Educational, neutral content
- ✅ **GDPR compliant**: Minimal data collection
- ✅ **No UGC**: No forums, comments, or user-generated content

## 📁 Repository Structure

```
early-help-monorepo/
├── apps/
│   ├── web/              # Next.js web application
│   └── mobile/           # Expo React Native iOS app
├── packages/
│   ├── types/            # Shared TypeScript types
│   ├── utils/            # Shared utilities (search, filters, etc.)
│   ├── api-client/       # Supabase client wrapper
│   └── ui/               # Shared UI components
├── supabase/
│   ├── schema.sql        # Database schema with RLS
│   ├── seed.sql          # Seed data (12 entries, 30 glossary items, 50 contacts)
│   └── README.md         # Supabase setup instructions
└── turbo.json            # Turborepo configuration
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** >= 18.0.0
- **pnpm** >= 8.0.0
- **Supabase account** (free tier works)
- **Expo CLI** (for mobile development)

### 1. Install Dependencies

```bash
pnpm install
```

### 2. Set Up Supabase

1. Create a Supabase project at https://supabase.com
2. Run the SQL schema:
   - Go to SQL Editor in Supabase
   - Copy contents of `supabase/schema.sql`
   - Execute the script
3. Seed the database:
   - Copy contents of `supabase/seed.sql`
   - Execute the script
4. Create an admin user (see `supabase/README.md`)

### 3. Configure Environment Variables

**Web App** (`apps/web/.env.local`):
```env
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

**Mobile App** (`apps/mobile/.env`):
```env
EXPO_PUBLIC_SUPABASE_URL=your-supabase-url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 4. Run Development Servers

```bash
# Run all apps in development mode
pnpm dev

# Or run individually:
cd apps/web && pnpm dev          # Web app on http://localhost:3000
cd apps/mobile && pnpm start     # Mobile app (opens Expo)
```

## 📱 Applications

### Web App (Next.js)

**Public Features:**
- 📚 **Content Library**: Browse and search educational articles
- 🔍 **Glossary**: Searchable codes and memes lexicon
- ✓ **Checklist**: Warning signs assessment (local storage)
- 🧭 **Help Navigator**: Find support contacts by role and region

**Admin Features:**
- Full CRUD operations for entries, categories, glossary, contacts
- Markdown editor with preview
- Entry versioning and history
- Protected by authentication and RLS

**Tech Stack:**
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Supabase (Auth + Postgres)
- React Markdown

### Mobile App (Expo React Native)

**Features:**
- All public features from web app
- Native iOS experience
- Local storage with AsyncStorage
- Responsive design for phones and tablets

**Tech Stack:**
- Expo 50
- React Native 0.73
- TypeScript
- Expo Router
- AsyncStorage

## 🧪 Testing

Run tests for shared utilities:

```bash
cd packages/utils
pnpm test
```

Tests cover:
- Search algorithms (fuzzy search, content search)
- Filter functions (category, tags, role, ZIP code)
- Checklist calculations
- Storage operations

## 🏗️ Building for Production

### Web App

```bash
cd apps/web
pnpm build
pnpm start
```

Deploy to Vercel, Netlify, or any Node.js hosting platform.

### Mobile App (iOS)

```bash
cd apps/mobile

# Development build
npx expo prebuild
npx expo run:ios

# Production build (requires Apple Developer account)
eas build --platform ios
```

See [Expo documentation](https://docs.expo.dev) for detailed build instructions.

## 📊 Database Schema

### Tables

- **categories**: Content organization
- **entries**: Educational articles
- **glossary_items**: Codes and memes lexicon
- **support_contacts**: Help navigator resources
- **entry_history**: Version control for entries
- **favorites**: User favorites (optional, with auth)

### Row Level Security (RLS)

All tables have RLS enabled:
- ✅ **Public read** for published content
- ✅ **Admin write** for all content management
- ✅ **User-owned** for favorites

See `supabase/schema.sql` for complete schema and policies.

## 🔐 Privacy & GDPR Compliance

### Data Minimization
- No personal data about minors stored
- No behavioral tracking or analytics
- No user-generated content

### Local-First Storage
- **Checklist progress**: AsyncStorage/localStorage only
- **Favorites (anonymous)**: Local storage only
- **Favorites (synced)**: Optional, requires explicit login

### User Rights
- Right to access: Users can export their data
- Right to deletion: Users can delete their account
- Right to be forgotten: All user data is deletable

### Legal Basis
- Legitimate interest: Educational content provision
- Consent: Optional favorites sync feature

## 🛠️ Development

### Code Style

```bash
# Format all code
pnpm format

# Type checking
pnpm typecheck

# Linting
pnpm lint
```

### Project Scripts

```bash
pnpm build      # Build all packages and apps
pnpm dev        # Run all apps in dev mode
pnpm test       # Run all tests
pnpm clean      # Clean all build artifacts
pnpm typecheck  # Type check all packages
```

### Adding New Features

1. Update types in `packages/types`
2. Add utilities in `packages/utils` with tests
3. Update API client in `packages/api-client`
4. Implement UI in apps
5. Update documentation

## 📖 Content Management

### Admin Access

1. Log in at `/admin` with admin credentials
2. Navigate to dashboard
3. Manage content through admin interface

### Content Guidelines

**Entries:**
- Use markdown for formatting
- Include clear, actionable information
- Maintain neutral, educational tone
- Tag appropriately for discoverability

**Glossary:**
- Be precise about context
- Include examples
- Link related terms
- Update as language evolves

**Support Contacts:**
- Verify contact information regularly
- Include multiple contact methods
- Specify geographic coverage clearly
- Categorize appropriately

## 🚨 Emergency Contacts

This app is educational only. For emergencies:

- **Germany Police**: 110
- **Youth Crisis Helpline**: 116 111 (Nummer gegen Kummer)

Use the Help Navigator feature to find local support organizations.

## 🤝 Contributing

This is a demonstration project. For a production deployment:

1. Replace dummy seed data with real contacts
2. Verify all support contact information
3. Review content with subject matter experts
4. Conduct security audit
5. Set up proper monitoring and logging
6. Implement analytics (privacy-preserving)

## 📄 License

Educational demonstration project. See LICENSE file for details.

## 🙏 Acknowledgments

- Content structure inspired by established prevention programs
- Glossary terms based on research into online extremism
- Built with privacy-first principles from the ground up

## 📞 Support

For technical issues:
- Check documentation in each package's README
- Review Supabase setup guide
- Consult Expo documentation for mobile issues

---

**Important**: This is a demonstration. Real deployment requires verification of all content, legal review for GDPR compliance, and ongoing content moderation.
