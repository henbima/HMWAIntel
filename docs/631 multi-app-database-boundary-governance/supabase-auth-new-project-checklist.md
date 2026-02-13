# Supabase Auth — New Project Setup Checklist

> **Created:** 2026-02-12 21:45 WITA
> **Author:** Hendra + Claude (lessons from HMBI auth debugging)
> **Purpose:** Step-by-step guide to set up Supabase Auth correctly in a new React SPA project, avoiding all known pitfalls.
> **Related:** `supabase-auth-session-stability.md` (detailed bug analysis), `example-auth-context.tsx` (copy-paste reference)

---

## Quick Start: Copy These Files

1. Copy `resources/pack-and-go/reference/example-auth-context.tsx` → `src/shared/contexts/AuthContext.tsx`
2. Adapt the `UserProfile` interface and `fetchUserProfile()` for your project
3. Follow the checklist below

---

## Step 1: Supabase Client Configuration

```typescript
// src/shared/services/supabase.ts
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,       // Auto-refresh JWT before expiry
    persistSession: true,          // Store session in localStorage
    detectSessionInUrl: false,     // ← IMPORTANT: disable for email/password apps
  },
});
```

### Why each option matters:
- `autoRefreshToken: true` — Without this, users get logged out after 1 hour when the JWT expires
- `persistSession: true` — Without this, refreshing the page logs users out
- `detectSessionInUrl: false` — Default `true` parses URL hash for OAuth tokens. For email/password apps, this is unnecessary and can **interfere with React Router**

---

## Step 2: AuthContext Provider

### THE GOLDEN RULE: `onAuthStateChange` callback MUST be SYNCHRONOUS

```typescript
// ❌ WRONG — causes navigator.locks DEADLOCK
supabase.auth.onAuthStateChange(async (event, session) => {
  const profile = await fetchProfile(session.user.id); // DEADLOCK!
  setState({ session, userProfile: profile });
});

// ✅ CORRECT — synchronous callback, deferred async work
supabase.auth.onAuthStateChange((event, session) => {
  setState(prev => ({ ...prev, session, user: session?.user })); // sync!

  setTimeout(() => { // escape the navigator.locks lock
    fetchProfile(session.user.id).then(profile => {
      setState(prev => ({ ...prev, userProfile: profile, loading: false }));
    });
  }, 0);
});
```

**Why:** Supabase JS v2 runs `onAuthStateChange` inside a `navigator.locks` exclusive lock. If your callback is `async` and calls any Supabase API (which also needs the lock), you get a **deadlock**. `getSession()` never resolves, the safety timeout fires, session becomes null, user appears "logged out."

This is a known issue: [supabase-js#2013](https://github.com/supabase/supabase-js/issues/2013)

### Event handling matrix:

| Event | Action | Async work? |
|-------|--------|-------------|
| `INITIAL_SESSION` | Skip (handled by `getSession()`) | No |
| `SIGNED_IN` | Set session sync, defer profile fetch | `setTimeout(0)` |
| `TOKEN_REFRESHED` | Update session/user only, keep profile | No |
| `SIGNED_OUT` | Clear all state immediately | No |

---

## Step 3: Sign Out

```typescript
// ❌ WRONG — if signOut() throws, state is never cleared
const signOut = async () => {
  await supabase.auth.signOut();
  setState({ session: null, user: null, loading: false });
};

// ✅ CORRECT — always clear state, even if API fails
const signOut = async () => {
  try {
    await supabase.auth.signOut();
  } catch (err) {
    console.error('[AuthContext] signOut API failed:', err);
  } finally {
    setState({ session: null, user: null, userProfile: null, loading: false });
  }
};
```

**Why:** If the network is down, `signOut()` throws. The user is stuck — can't sign out, UI is frozen. `finally` ensures state is always cleaned up.

---

## Step 4: Safety Timeouts

Every async path needs a timeout to prevent infinite loading:

```typescript
// 1. Safety timeout for the entire auth initialization
const safetyTimeout = setTimeout(() => {
  setState(prev => prev.loading ? { ...prev, loading: false } : prev);
}, 8_000);

// 2. Profile fetch timeout (prevents hung fetches from blocking UI)
async function fetchProfileWithTimeout(uid: string, timeoutMs = 5_000) {
  return new Promise((resolve) => {
    let settled = false;
    const timer = setTimeout(() => {
      if (!settled) { settled = true; resolve(null); }
    }, timeoutMs);
    fetchUserProfile(uid)
      .then(p => { if (!settled) { settled = true; clearTimeout(timer); resolve(p); } })
      .catch(() => { if (!settled) { settled = true; clearTimeout(timer); resolve(null); } });
  });
}
```

---

## Step 5: Stale Fetch Prevention

When multiple auth events fire rapidly (login → navigate → token refresh), you can end up with stale profile data overwriting newer data.

```typescript
const profileFetchId = useRef(0);

// Before starting a fetch:
const fetchId = ++profileFetchId.current;

// After fetch completes:
if (fetchId !== profileFetchId.current) return; // stale, discard
```

---

## Step 6: Login Page

```typescript
// ❌ WRONG — navigating after signIn causes race condition
const handleSubmit = async () => {
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (!error) navigate('/dashboard'); // RACE CONDITION!
};

// ✅ CORRECT — let AuthContext handle navigation via session state
const handleSubmit = async () => {
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) setError(error.message);
  // Don't navigate! AuthContext detects SIGNED_IN, updates session,
  // and LoginPage's `if (session) return <Navigate to="/dashboard" />`
  // handles the redirect automatically.
};
```

**Why:** After `signInWithPassword()`, the session is updated asynchronously via `onAuthStateChange`. If you navigate immediately, the route guards may still see `session: null` and redirect back to login.

---

## Step 7: Route Guards

```typescript
function AuthGuard({ children }) {
  const { session, loading } = useAuth();
  if (loading) return <LoadingFallback />;
  if (!session) return <Navigate to="/login" replace />;
  return <>{children}</>;
}
```

### Rules:
- Check `loading` FIRST — never redirect while still initializing
- Check `session` for basic auth, check `userProfile.role` for RBAC
- Don't add any Supabase API calls inside guards — let AuthContext handle data

---

## Step 8: E2E Testing (Playwright)

Always create auth stability tests:

```typescript
// e2e/auth-stability.spec.ts
test('login → navigate multiple pages → sign out → re-login', async ({ page }) => {
  // Login
  await loginViaUI(page);

  // Navigate to several pages (this catches the navigator.locks deadlock)
  await page.goto('/page1');
  await page.waitForTimeout(2_000);
  await page.goto('/page2');
  await page.waitForTimeout(2_000);

  // Sign out
  await page.getByTitle('Sign out').click();
  await expect(page).toHaveURL(/\/login/);

  // Re-login (this catches stale localStorage issues)
  await loginViaUI(page);
});
```

**Key test scenarios:**
1. Basic login/logout/re-login (catches state cleanup bugs)
2. Rapid 5x login/logout cycles (catches race conditions)
3. Navigate multiple pages then sign out (catches navigator.locks deadlock)
4. Check localStorage after sign out (catches token cleanup bugs)
5. Idle period then navigate (catches token refresh bugs)

---

## Common Mistakes Checklist

Before shipping, verify:

- [ ] `onAuthStateChange` callback is NOT `async`
- [ ] No `await` or Supabase API calls inside `onAuthStateChange`
- [ ] Profile fetch is deferred via `setTimeout(0)`
- [ ] `signOut()` uses `try/catch/finally`
- [ ] `detectSessionInUrl: false` is set for email/password apps
- [ ] Safety timeout exists (8s) to prevent infinite loading
- [ ] Profile fetch has its own timeout (5s)
- [ ] `profileFetchId` ref prevents stale overwrites
- [ ] `mounted` flag prevents state updates after unmount
- [ ] Login page does NOT navigate after `signInWithPassword()` — uses session state
- [ ] Route guards check `loading` before checking `session`
- [ ] Console logging for auth events is present (helps future debugging)
- [ ] E2E test for login → navigate → logout → re-login exists
- [ ] `TOKEN_REFRESHED` is handled silently (no loading state, no profile refetch)

---

## Files to Include in Every Project

| File | Purpose |
|------|---------|
| `src/shared/services/supabase.ts` | Client config with `detectSessionInUrl: false` |
| `src/shared/contexts/AuthContext.tsx` | Copy from `example-auth-context.tsx`, adapt profile |
| `src/shared/components/LoginPage.tsx` | Login form, no manual navigation |
| `src/core/routes.tsx` | AuthGuard + AdminGuard wrappers |
| `e2e/auth-stability.spec.ts` | Auth stability tests (copy from HMBI) |
| `docs/reference/supabase-auth-session-stability.md` | Reference doc (copy from HMBI) |

---

## Version Compatibility

- **@supabase/supabase-js v2.x** (confirmed on v2.95.3) — the `navigator.locks` issue exists
- **React 18** with `createContext` pattern
- **React Router v6** with `Navigate` for redirects
- **Playwright** for E2E testing

The `navigator.locks` deadlock is a known Supabase issue that may be fixed in a future major version (v3). Until then, the synchronous callback + `setTimeout(0)` pattern is the correct workaround.
