# Shared Auth Setup — HollyMart Supabase

> **Updated:** 2026-02-13 WITA
>
> All HollyMart projects share ONE Supabase instance. This guide explains the shared auth system.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Supabase Instance                   │
│              (nnzhdjibilebpjgaqkdu)              │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ auth.users│  │ hm_core  │  │ wa_intel │      │
│  │ (login)  │  │ (RBAC)   │  │ (data)   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│       ↑              ↑              ↑            │
└───────┼──────────────┼──────────────┼────────────┘
        │              │              │
   ┌────┴────┐   ┌────┴────┐   ┌────┴────┐
   │  HMBI   │   │  HMCS   │   │HMWAIntel│
   │  App    │   │  App    │   │  App    │
   └─────────┘   └─────────┘   └─────────┘
```

### Key Concepts

1. **`auth.users`** — Supabase's built-in auth table. One account per person across all apps.
2. **`hm_core` schema** — Organization-wide RBAC system. Manages roles, permissions, scoping.
3. **`wa_intel` schema** — HMWAIntel's data. Isolated from other projects.

---

## hm_core Integration RPCs

```typescript
// Get user's role in the system
const { data: role } = await supabase.rpc('get_my_hm_role');

// Get menu items the user can access
const { data: menu } = await supabase.rpc('get_my_menu', { p_app_id: 'wa_intel' });

// Check if user can access a specific resource
const { data: allowed } = await supabase.rpc('check_my_access', { p_resource_code: 'dashboard.view' });
```

---

## Important Notes

- **hm_core schema is NOT exposed to PostgREST directly.** Use public wrapper RPCs.
- **Never call `.schema('hm_core')`** from the client — it won't work.
- **After creating new RPCs, always run `NOTIFY pgrst, 'reload schema'`**
- **Test accounts:** admin@hmcs.com (SYSTEM_ADMIN)
