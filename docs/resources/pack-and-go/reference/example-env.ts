/**
 * Reference: Environment Configuration
 * From: HMBI project (src/config/env.ts)
 *
 * Pattern: Central env access with type safety.
 * Vite requires VITE_ prefix for client-side env vars.
 */

export const env = {
  SUPABASE_URL: import.meta.env.VITE_SUPABASE_URL as string,
  SUPABASE_ANON_KEY: import.meta.env.VITE_SUPABASE_ANON_KEY as string,
} as const;
