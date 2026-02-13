# Spec 631: Multi-App Database Boundary Governance

## Status
- **Created**: 2026-02-12
- **Status**: Draft
- **Assigned**: Kiro

## Quick Links
- [Requirements](./631%20requirements.md)
- [Design](./631%20design.md)
- [Tasks](./631%20tasks.md)

## Summary
Establishes a self-documenting database object registry and naming convention system to prevent cross-app interference when multiple applications (HMCS, HMBI, future apps) share a single Supabase database. Triggered by the Feb 12 2026 incident where an AI assistant working on HMBI accidentally deleted HMCS's daily task generation cron job.

## Key Decisions
- Registry table in `hm_core` schema (single source of truth, queryable by all apps)
- Naming convention for future objects only (no renaming legacy objects)
- Schema-based isolation as primary boundary, prefix naming as secondary visual cue
- Universal AI steering template that references the registry (not static lists)

## Related Specs
- Spec 609: Service Layer Migration - established service layer patterns
- Spec 900: Architecture Cleanup Phase 2 - consolidated migrations

## Incident Reference
- **Date**: 2026-02-12
- **Root Cause**: Migration `disable_broken_crons` (20260211015410) deleted cron job 3 (generate-daily-tasks) as collateral damage
- **Impact**: Zero daily tasks generated for Feb 12, affecting all outlets
- **Resolution**: Manual trigger + cron job restored via migration `restore_generate_daily_tasks_cron`

## Implementation Notes
- This spec is primarily database + documentation work (no frontend code changes)
- The registry backfill is a one-time migration
- Steering templates must be distributed to all app projects manually
