/**
 * Reference: Feature Flags System
 * From: HMBI project (src/config/features.ts)
 *
 * Pattern: Define flags for domains and sub-features.
 * Start with everything false, enable as features are built.
 * Use dotted notation for hierarchy: 'domain.feature'
 */

interface FeatureFlags {
  [key: string]: boolean;
}

const flags: FeatureFlags = {
  // Domain-level flags (sidebar visibility)
  dashboard: true,     // Main dashboard domain
  settings: true,      // Settings domain
  admin: false,        // Admin domain (enable when RBAC is ready)

  // Feature-level flags (tab/page visibility within domains)
  'dashboard.overview': true,     // Main overview page
  'dashboard.analytics': false,   // Analytics sub-page
  'settings.profile': true,       // User profile settings
  'admin.users': false,           // User management (needs RBAC)
};

export const featureFlags = {
  isEnabled(flag: string): boolean {
    if (!Object.prototype.hasOwnProperty.call(flags, flag)) return false;
    return flags[flag] ?? false;
  },

  getEnabledModules(): string[] {
    return Object.entries(flags)
      .filter(([, enabled]) => enabled)
      .map(([name]) => name);
  },
};
