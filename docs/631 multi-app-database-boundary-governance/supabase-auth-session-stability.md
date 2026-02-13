# Supabase Auth Session Stability — Reference Guide

> **Created:** 2026-02-12 15:30 WITA
> **Updated:** 2026-02-12 21:30 WITA — Added Bug 4 (navigator.locks deadlock), updated AuthContext fix
> **Project:** HMBI (HollyMart Business Intelligence)
> **Applies to:** Any React SPA using Supabase Auth with email/password login
> **Related files:** `src/shared/services/supabase.ts`, `src/shared/contexts/AuthContext.tsx`

---

## Problem Summary

Users get "logged out" after browsing the app or after ~1 hour of use. After logout, re-login gets stuck on a blank "Loading..." page that never resolves. Only workaround is using a different browser or guest/incognito mode.

## Root Cause

Four interacting bugs in the auth implementation, with **Bug 4 being the most critical**:

### Bug 1: Token refresh blanks the entire UI

Supabase auto-refreshes the JWT access token every ~1 hour via `onAuthStateChange`. The original code ignored the `event` parameter and treated EVERY auth event identically — setting `loading: true` and re-fetching the user profile. This caused the entire app UI to disappear (replaced by a loading spinner) every time the token refreshed.

**The fix:** Handle each event type separately. `TOKEN_REFRESHED` should silently update session/user without touching `loading` or `userProfile`.

### Bug 2: No timeout on profile fetch inside `onAuthStateChange`

The initial mount had a safety timeout but `onAuthStateChange` callback had none. If `fetchUserProfile()` hung, `loading` stayed `true` forever — permanent blank page.

**The fix:** Wrap all profile fetches in `fetchProfileWithTimeout()` that resolves to `null` after 5 seconds.

### Bug 3: `signOut()` crashes on network failure

If `supabase.auth.signOut()` threw (network error), state cleanup never ran. localStorage kept stale tokens.

**The fix:** Use `try/catch/finally` — always clear state in `finally`.

### Bug 4: `navigator.locks` DEADLOCK — THE MAIN CULPRIT (Found 2026-02-12)

**This was the hardest bug to find and the root cause of the "phantom logout" issue.**

Supabase JS v2 uses `navigator.locks` API for session management. The `onAuthStateChange` callback runs **inside an exclusive lock**. If the callback is `async` and calls other Supabase APIs (which also need the lock), it causes a **deadlock**:

1. Supabase `_initialize()` acquires `navigator.locks` lock
2. During initialization, fires `onAuthStateChange('SIGNED_IN', session)`
3. Our **async** callback calls `fetchUserProfile()` → `supabase.from('users')...`
4. Those API calls try to acquire the same lock → **DEADLOCK**
5. `getSession()` also tries to acquire the lock → **NEVER RESOLVES**
6. Mount safety timeout fires after 5s → sets `session: null` → redirect to login
7. User appears "logged out" even though their session was valid

**Evidence from Playwright tests:**
```
[1108ms] Calling getSession()...
[1126ms] Auth event: SIGNED_IN admin@hmcs.com
[6123ms] MOUNT TIMEOUT FIRED — getSession() did NOT resolve in 5s! Setting session=null
[6126ms] Profile fetch timeout during SIGNED_IN — proceeding without profile
```

**The fix:** Make `onAuthStateChange` callback **synchronous** — no `async`/`await`, no Supabase API calls inside it. Defer profile fetching via `setTimeout(0)` which runs AFTER the callback returns and the lock is released:

```typescript
// CORRECT: synchronous callback, deferred profile fetch
supabase.auth.onAuthStateChange((event, session) => {
  // All state updates here are synchronous React setState calls — OK
  if (event === 'SIGNED_IN' && session?.user) {
    setState(prev => ({ ...prev, session, user: session.user, loading: true }));

    // Defer Supabase API calls OUTSIDE the lock
    setTimeout(() => {
      fetchProfileWithTimeout(session.user.id).then(profile => {
        setState({ session, user: session.user, userProfile: profile, loading: false });
      });
    }, 0);
  }
});
```

**This is a known Supabase issue:** [supabase-js#2013](https://github.com/supabase/supabase-js/issues/2013)
The type declarations even have a deprecation warning:
```
@deprecated Due to the possibility of deadlocks with async functions as callbacks
```

---

## Supabase Client Configuration

```typescript
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,       // Auto-refresh before expiry
    persistSession: true,          // Store session in localStorage
    detectSessionInUrl: false,     // Disable for non-OAuth apps
  },
});
```

**Why `detectSessionInUrl: false`?** The default (`true`) makes Supabase parse URL hash fragments for OAuth tokens. For email/password-only apps, this is unnecessary and can interfere with React Router.

---

## Supabase Auth Event Types

| Event | When it fires | Correct handling |
|-------|--------------|-----------------|
| `INITIAL_SESSION` | On client creation, after reading localStorage | Skip (handled by `getSession()`) |
| `SIGNED_IN` | After successful login or session restoration | Set session synchronously, defer profile fetch via `setTimeout(0)` |
| `SIGNED_OUT` | After `signOut()` or token becomes invalid | Clear all auth state immediately |
| `TOKEN_REFRESHED` | Every ~1 hour when access token is auto-refreshed | **Silent update only** — update session/user, NO loading, NO profile refetch |
| `USER_UPDATED` | After `updateUser()` call | Re-fetch profile if needed |
| `PASSWORD_RECOVERY` | When user clicks password reset link | Show password reset UI |

---

## Auth Flow Architecture (Current Working Pattern)

```
┌─────────────────────────────────────────────────────┐
│                    App Mount                         │
│                                                      │
│  1. getSession() — resolves from localStorage        │
│  2. If session → set session state, fetch profile    │
│  3. Subscribe to onAuthStateChange (SYNC callback)   │
│  4. Safety timeout at 8s (if everything hangs)       │
└─────────────────────────────────────────────────────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
SIGNED_IN         TOKEN_REFRESHED      SIGNED_OUT
    │                   │                   │
    ▼                   ▼                   ▼
Set session        Silent update       Clear state
(sync setState)    (session only)      loading: false
setTimeout(0)→     NO loading          → Login page
fetchProfile()     NO profile fetch
loading: false
→ Dashboard
```

**Key architectural decisions:**
- `onAuthStateChange` callback is **synchronous** (not `async`)
- Profile fetching uses `setTimeout(0)` to escape the `navigator.locks` lock
- `profileFetchId` ref tracks the latest fetch to prevent stale overwrites
- `mounted` flag prevents state updates after unmount
- `fetchProfileWithTimeout()` wraps profile fetch with a 5s safety timeout

---

## Symptoms → Diagnosis Cheat Sheet

| Symptom | Likely cause |
|---------|-------------|
| Logged out after ~5 seconds on page reload | **Bug 4: `navigator.locks` deadlock** — `getSession()` never resolves |
| Logged out after ~1 hour | `TOKEN_REFRESHED` triggers loading state or profile fetch failure |
| Blank "Loading..." page after re-login | Profile fetch hanging (deadlock or no timeout) |
| Different browser/incognito works | Stale tokens in localStorage; new browser has clean state |
| Every page navigation causes logout | Async `onAuthStateChange` callback + `getSession()` deadlock |
| Login works but shows "Access Pending" | Profile fetch failed/timed out, `userProfile` is null |
| Sign out button does nothing | `signOut()` threw and state cleanup was after the `await` |

---

## How We Found Bug 4 (Playwright Investigation)

### Step 1: Reproduction
Created `e2e/auth-stability.spec.ts` with 6 test cycles. Cycle 3 (navigate multiple pages → sign out → re-login) **failed 3/3 times** — the user was automatically logged out ~5 seconds after each `page.goto()`.

### Step 2: Polling diagnosis
Added URL polling every 500ms after navigation. Found that EVERY page showed the user logged in for ~5 seconds, then suddenly redirected to `/hmbi/login`. The exact same pattern on every page.

### Step 3: Diagnostic logging
Added `console.log` to the AuthContext showing `getSession()` resolution timing. **Discovered `getSession()` NEVER resolved** on subsequent page loads — the 5-second mount timeout fired and set `session: null`.

### Step 4: Root cause
The Supabase type declarations explicitly warn:
```
@deprecated Due to the possibility of deadlocks with async functions as callbacks
```

Our `onAuthStateChange` callback was `async` and called `fetchUserProfile()` which makes Supabase REST API calls. Those calls need the same `navigator.locks` lock that the callback is running inside → **deadlock**.

### Step 5: Fix verification
Made the callback synchronous, deferred profile fetch via `setTimeout(0)`. All 6 test cycles pass. The `getSession()` call now resolves instantly.

---

## Debugging Checklist

When auth issues occur, check in this order:

1. **Browser Console** — Look for `[AuthContext]` log messages showing auth events
2. **Check for deadlock** — If `getSession resolved:` log never appears, the `navigator.locks` deadlock is occurring. Check that `onAuthStateChange` callback is NOT async.
3. **Network Tab** — Filter for `auth/v1/token?grant_type=refresh_token` — check for 400/401
4. **localStorage** — Check `Application > Local Storage` for `sb-{ref}-auth-token` key
5. **Supabase Dashboard** — Authentication > Settings: JWT expiry, session timeout settings

---

## Key Takeaways

1. **`onAuthStateChange` callback MUST be synchronous** — never `async`, never `await`, never call Supabase APIs inside it. This causes `navigator.locks` deadlock.
2. **Defer Supabase API calls** with `setTimeout(0)` to escape the lock
3. **`TOKEN_REFRESHED` must be invisible** — no loading states, no profile refetches
4. **Every async operation needs a timeout** — use `fetchProfileWithTimeout()` pattern
5. **`signOut()` needs try/catch/finally** — network failures must not prevent state cleanup
6. **Set `detectSessionInUrl: false`** for email/password apps without OAuth
7. **Use `profileFetchId` ref** to prevent stale profile data from overwriting newer fetches
8. **Add console logging for auth events** — makes future debugging much faster

---

## Applies To

This pattern applies to any project using:
- `@supabase/supabase-js` v2.x (confirmed on v2.95.3)
- React with `createContext` for auth state
- Email/password authentication (not OAuth)
- Route guards that check `loading` state
- Profile/role fetching after authentication

Known projects with this pattern: **HMBI**, **HMCS**, **HMWAIntel**

---

## References

- [supabase-js #2013: Auth-JS Deadlock Issue](https://github.com/supabase/supabase-js/issues/2013)
- [supabase #35754: getUser() hangs indefinitely](https://github.com/supabase/supabase/issues/35754)
- [supabase #41968: onAuthStateChange does not trigger, refreshSession hangs](https://github.com/supabase/supabase/issues/41968)
