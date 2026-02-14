-- Migration: fix_cron_job_naming_and_batch_schedule
-- Applied: 2026-02-13
-- Purpose: Fix incorrectly-named cron jobs (were hmbi_* prefix, should be wa_intel_*)
--          and update analyze-daily schedule for batch processing (every 10 min window)

-- Step 1: Unschedule old incorrectly-named cron jobs (jobid 18, 19)
SELECT cron.unschedule('hmbi_analyze-daily');
SELECT cron.unschedule('hmbi_daily-briefing');

-- Step 2: Create new correctly-named cron jobs
-- analyze-daily: every 10 minutes between 18:00-19:59 UTC (01:00-02:59 WIB)
-- Batch processing: each invocation processes up to 5 groups, cron repeats to cover all groups
SELECT cron.schedule(
  'wa_intel_analyze-daily',
  '*/10 18-19 * * *',
  $$SELECT net.http_post(
    url := 'https://nnzhdjibilebpjgaqkdu.supabase.co/functions/v1/analyze-daily',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'SERVICE_ROLE_KEY' LIMIT 1)
    ),
    body := '{}'::jsonb
  );$$
);

-- daily-briefing: 22:00 UTC (05:00 WIB)
SELECT cron.schedule(
  'wa_intel_daily-briefing',
  '0 22 * * *',
  $$SELECT net.http_post(
    url := 'https://nnzhdjibilebpjgaqkdu.supabase.co/functions/v1/daily-briefing',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'SERVICE_ROLE_KEY' LIMIT 1)
    ),
    body := '{}'::jsonb
  );$$
);

-- Step 3: Fix registry entries (owner_app was incorrectly set to 'hmbi')
UPDATE hm_core.object_registry
SET owner_app = 'wa_intel',
    object_name = 'wa_intel_analyze-daily',
    description = 'Cron: analyze-daily edge function - batch topic analysis (every 10 min, 01:00-02:59 WIB)'
WHERE object_type = 'cron_job' AND object_name = 'hmbi_analyze-daily';

UPDATE hm_core.object_registry
SET owner_app = 'wa_intel',
    object_name = 'wa_intel_daily-briefing',
    description = 'Cron: daily-briefing edge function - generates morning briefing (05:00 WIB)'
WHERE object_type = 'cron_job' AND object_name = 'hmbi_daily-briefing';

UPDATE hm_core.object_registry
SET owner_app = 'wa_intel'
WHERE object_type = 'edge_function' AND object_name IN ('analyze-daily', 'daily-briefing')
  AND owner_app = 'hmbi';
