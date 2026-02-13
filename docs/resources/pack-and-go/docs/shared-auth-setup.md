# Shared Auth Setup — HollyMart Supabase

> **Updated:** 2026-02-11 22:00 WITA
>
> All HollyMart projects share ONE Supabase instance. This guide explains how to connect a new project to the shared auth system.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Supabase Instance                   │
│              (nnzhdjibilebpjgaqkdu)              │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ auth.users│  │ hm_core  │  │ project  │      │
│  │ (login)  │  │ (RBAC)   │  │ schema   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│       ↑              ↑              ↑            │
└───────┼──────────────┼──────────────┼────────────┘
        │              │              │
   ┌────┴────┐   ┌────┴────┐   ┌────┴────┐
   │  HMBI   │   │  HMCS   │   │  Your   │
   │  App    │   │  App    │   │  App    │
   └─────────┘   └─────────┘   └─────────┘
```

### Key Concepts

1. **`auth.users`** — Supabase's built-in auth table. One account per person across all apps.
2. **`hm_core` schema** — Organization-wide RBAC system. Manages roles, permissions, scoping.
3. **Project schema** — Your app's data (e.g., `hmbi`, `hmls`). Isolated from other projects.

---

## Step 1: Supabase Client Setup

Create `src/shared/services/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js';
import { env } from '@config/env';

export const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
```

Create `src/config/env.ts`:

```typescript
export const env = {
  SUPABASE_URL: import.meta.env.VITE_SUPABASE_URL as string,
  SUPABASE_ANON_KEY: import.meta.env.VITE_SUPABASE_ANON_KEY as string,
} as const;
```

---

## Step 2: AuthContext

Create `src/shared/contexts/AuthContext.tsx` that:

1. Manages Supabase auth session (login, logout, session refresh)
2. Loads user profile from hm_core (role, scope)
3. Provides `useAuth()` hook to all components

### hm_core Integration

After login, call these public RPCs to get the user's role and permissions:

```typescript
// Get user's role in the system
const { data: role } = await supabase.rpc('get_my_hm_role');
// Returns: { role_name, role_code, scope_type, scope_value }

// Get menu items the user can access (filtered by app)
const { data: menu } = await supabase.rpc('get_my_menu', { p_app_id: 'YOUR_APP_ID' });
// Returns: [{ resource_code, resource_name, ... }]

// Check if user can access a specific resource
const { data: allowed } = await supabase.rpc('check_my_access', { p_resource_code: 'dashboard.view' });
// Returns: boolean
```

### Key Pattern: Always Check Error

```typescript
// WRONG — error is silently lost
const { data } = await supabase.rpc('get_my_hm_role');

// CORRECT — always check error
const { data, error } = await supabase.rpc('get_my_hm_role');
if (error) {
  console.error('Failed to load role:', error);
  // Handle gracefully
}
```

---

## Step 3: Register Your App in hm_core

Your app needs to be registered in hm_core so the RBAC system knows about it.

### Migration: Register App

```sql
-- Register the app
INSERT INTO hm_core.apps (app_code, app_name, description, is_active)
VALUES ('YOUR_APP_CODE', 'Your App Name', 'Description', true)
ON CONFLICT (app_code) DO NOTHING;

-- Register permissions for your app
INSERT INTO hm_core.permissions (app_id, resource_code, resource_name, description)
SELECT a.id, p.resource_code, p.resource_name, p.description
FROM hm_core.apps a,
(VALUES
  ('dashboard.view', 'View Dashboard', 'Access main dashboard'),
  ('data.export', 'Export Data', 'Export data to CSV/Excel')
  -- Add your permissions here
) AS p(resource_code, resource_name, description)
WHERE a.app_code = 'YOUR_APP_CODE'
ON CONFLICT DO NOTHING;
```

### Migration: Assign Permissions to Roles

```sql
-- Give SYSTEM_ADMIN and DIRECTOR full access to your app
INSERT INTO hm_core.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM hm_core.roles r
CROSS JOIN hm_core.permissions p
JOIN hm_core.apps a ON p.app_id = a.id
WHERE r.role_code IN ('SYSTEM_ADMIN', 'DIRECTOR')
AND a.app_code = 'YOUR_APP_CODE'
ON CONFLICT DO NOTHING;
```

---

## Step 4: Login Page

Use Supabase Auth UI or build a custom login:

```typescript
// Simple email/password login
const { data, error } = await supabase.auth.signInWithPassword({
  email: userEmail,
  password: userPassword,
});
```

Since all HollyMart apps share the same auth, users log in with the same credentials everywhere.

---

## Step 5: Route Protection

### AuthGuard Component

Wrap protected routes with an AuthGuard that:
1. Checks if user is logged in (redirect to login if not)
2. Checks if user has an hm_core role (show AccessPending if not)
3. Allows through if authenticated and authorized

### AdminGuard Component

For admin-only pages:
1. Check `userProfile.hmRoleCode === 'SYSTEM_ADMIN' || userProfile.hmRoleCode === 'DIRECTOR'`
2. Show "Access Denied" if not admin

---

## Important Notes

- **hm_core schema is NOT exposed to PostgREST directly.** Only `public`, `hmbi`, `storage`, `graphql_public` schemas are exposed. To call hm_core functions, use the public wrapper RPCs (`get_my_hm_role`, `get_my_menu`, `check_my_access`).
- **Never call `.schema('hm_core')`** from the client — it won't work.
- **After creating new RPCs, always run `NOTIFY pgrst, 'reload schema'`** to refresh PostgREST's cache.
- **Test accounts:** admin@hmcs.com (SYSTEM_ADMIN), manager02@hokkymart.com (no role — for testing AccessPending)

---

## Reference Implementation

See `reference/example-auth-context.tsx` in the Pack & Go kit for a working AuthContext pattern.
