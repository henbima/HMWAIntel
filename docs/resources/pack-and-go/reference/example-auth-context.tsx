/**
 * Reference: AuthContext with Supabase Auth + hm_core RBAC
 * From: HMBI project (src/shared/contexts/AuthContext.tsx)
 * Updated: 2026-02-12 21:30 WITA — Fixed navigator.locks deadlock
 *
 * This is a REFERENCE EXAMPLE — adapt for your project.
 *
 * CRITICAL PATTERNS (do NOT deviate):
 * 1. onAuthStateChange callback MUST be synchronous (not async)
 *    — Supabase runs it inside navigator.locks. Async + Supabase API = DEADLOCK.
 * 2. Defer all Supabase API calls (profile fetch) via setTimeout(0)
 * 3. Filter by event type: INITIAL_SESSION=skip, TOKEN_REFRESHED=silent, SIGNED_IN=defer
 * 4. signOut() needs try/catch/finally — always clear state
 * 5. Always check error on .rpc() calls — they swallow errors silently
 * 6. Set detectSessionInUrl: false for email/password apps
 *
 * See also: docs/reference/supabase-auth-session-stability.md
 * Known issue: https://github.com/supabase/supabase-js/issues/2013
 */

import { createContext, useContext, useEffect, useState, useCallback, useRef } from 'react';
import type { ReactNode } from 'react';
import type { Session, User } from '@supabase/supabase-js';
import { supabase } from '@shared/services/supabase';

export interface UserProfile {
  id: string;
  uid: string;
  email: string;
  name: string;
  role: string;
  // hm_core RBAC fields
  hmRole: string | null;      // e.g., "Direktur", null if no role assigned
  hmRoleCode: string | null;  // e.g., "DIRECTOR", null if no role assigned
  hmScopeType: string | null; // e.g., "company", null if no role assigned
}

interface AuthState {
  session: Session | null;
  user: User | null;
  userProfile: UserProfile | null;
  loading: boolean;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthState>({
  session: null,
  user: null,
  userProfile: null,
  loading: true,
  signOut: async () => {},
});

interface HmRoleResult {
  role_name: string;
  role_code: string;
  scope_type: string;
}

async function fetchUserProfile(uid: string): Promise<UserProfile | null> {
  // 1. Query public.users (existing user table)
  const { data, error } = await supabase
    .from('users')
    .select('id, uid, email, name, role')
    .eq('uid', uid)
    .single();

  if (error || !data) {
    console.error('[AuthContext] fetchUserProfile failed:', JSON.stringify({ uid, error, data }, null, 2));
    return null;
  }

  // 2. Query hm_core role via public wrapper RPC
  // IMPORTANT: Always check error — .rpc() swallows errors silently
  let hmRole: string | null = null;
  let hmRoleCode: string | null = null;
  let hmScopeType: string | null = null;

  try {
    const { data: roleData, error: roleError } = await supabase.rpc('get_my_hm_role');
    if (roleError) {
      console.error('[AuthContext] get_my_hm_role RPC error:', roleError.message);
    } else if (roleData) {
      const role = roleData as HmRoleResult;
      hmRole = role.role_name;
      hmRoleCode = role.role_code;
      hmScopeType = role.scope_type;
    }
  } catch (e) {
    console.error('[AuthContext] hm_core role fetch exception:', e);
  }

  // 3. Merge: public.users + hm_core role
  return {
    ...(data as { id: string; uid: string; email: string; name: string; role: string }),
    hmRole,
    hmRoleCode,
    hmScopeType,
  };
}

/**
 * Fetch profile with a timeout safety net. Returns the profile or null.
 */
async function fetchProfileWithTimeout(uid: string, timeoutMs = 5_000): Promise<UserProfile | null> {
  return new Promise<UserProfile | null>((resolve) => {
    let settled = false;

    const timer = setTimeout(() => {
      if (!settled) {
        settled = true;
        console.warn('[AuthContext] Profile fetch timeout — proceeding without profile');
        resolve(null);
      }
    }, timeoutMs);

    fetchUserProfile(uid)
      .then((profile) => {
        if (!settled) {
          settled = true;
          clearTimeout(timer);
          resolve(profile);
        }
      })
      .catch(() => {
        if (!settled) {
          settled = true;
          clearTimeout(timer);
          resolve(null);
        }
      });
  });
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<Omit<AuthState, 'signOut'>>({
    session: null,
    user: null,
    userProfile: null,
    loading: true,
  });

  // Track the latest profile fetch to avoid stale overwrites
  const profileFetchId = useRef(0);

  const signOut = useCallback(async () => {
    try {
      await supabase.auth.signOut();
    } catch (err) {
      console.error('[AuthContext] signOut API failed:', err);
    } finally {
      // ALWAYS clear local state — even if the API call failed
      setState({ session: null, user: null, userProfile: null, loading: false });
    }
  }, []);

  useEffect(() => {
    let mounted = true;

    // ---- Initial session load ----
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!mounted) return;
      console.log('[AuthContext] getSession resolved:', session ? session.user?.email : 'null');

      if (session?.user) {
        setState((prev) => ({ ...prev, session, user: session.user }));

        const fetchId = ++profileFetchId.current;
        fetchProfileWithTimeout(session.user.id).then((profile) => {
          if (!mounted || fetchId !== profileFetchId.current) return;
          setState({ session, user: session.user, userProfile: profile, loading: false });
        });
      } else {
        setState({ session: null, user: null, userProfile: null, loading: false });
      }
    }).catch(() => {
      if (!mounted) return;
      console.error('[AuthContext] getSession() threw');
      setState({ session: null, user: null, userProfile: null, loading: false });
    });

    // Safety timeout
    const safetyTimeout = setTimeout(() => {
      if (!mounted) return;
      setState((prev) => {
        if (prev.loading) {
          console.warn('[AuthContext] Safety timeout — forcing loading=false');
          return { ...prev, loading: false };
        }
        return prev;
      });
    }, 8_000);

    // ---- Auth state change listener ----
    // CRITICAL: This callback MUST be synchronous (not async).
    // Supabase runs onAuthStateChange inside navigator.locks.
    // Async callbacks that call Supabase APIs cause DEADLOCK.
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        console.log('[AuthContext] Auth event:', event, session?.user?.email ?? 'no-user');

        if (event === 'INITIAL_SESSION') return;

        if (event === 'TOKEN_REFRESHED') {
          if (session?.user) {
            setState((prev) => ({ ...prev, session, user: session.user }));
          }
          return;
        }

        if (!session?.user) {
          profileFetchId.current++;
          setState({ session: null, user: null, userProfile: null, loading: false });
          return;
        }

        // SIGNED_IN: set session synchronously, defer profile fetch OUTSIDE the lock
        setState((prev) => ({ ...prev, session, user: session.user, loading: true }));

        const uid = session.user.id;
        const fetchId = ++profileFetchId.current;

        setTimeout(() => {
          if (!mounted || fetchId !== profileFetchId.current) return;
          fetchProfileWithTimeout(uid).then((profile) => {
            if (!mounted || fetchId !== profileFetchId.current) return;
            setState({ session, user: session.user, userProfile: profile, loading: false });
          });
        }, 0);
      }
    );

    return () => {
      mounted = false;
      clearTimeout(safetyTimeout);
      subscription.unsubscribe();
    };
  }, []);

  return (
    <AuthContext.Provider value={{ ...state, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  return useContext(AuthContext);
}
