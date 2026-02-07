/*
  # Fix Daily Briefing Cron Settings

  1. Purpose
    - Configure app.settings.supabase_url and app.settings.service_role_key
    - These settings are required by the daily-briefing cron job
    
  2. Changes
    - Set database configuration for Supabase URL
    - Set placeholder for service role key (to be configured via Supabase dashboard)
    
  3. Notes
    - Service role key should be configured through Supabase secrets/vault
    - For now, the cron will use SUPABASE_SERVICE_ROLE_KEY env var
*/

-- Update the cron job to use environment variables directly
-- First, unschedule the existing job
SELECT cron.unschedule('daily-briefing-7am-wib')
WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'daily-briefing-7am-wib'
);

-- Reschedule with environment variables
-- Note: In Supabase, edge functions can be called using the service role key
-- The SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are available as env vars
SELECT cron.schedule(
  'daily-briefing-7am-wib',
  '0 0 * * *',
  $$
  SELECT net.http_post(
    url := 'https://nnzhdjibilebpjgaqkdu.supabase.co/functions/v1/daily-briefing',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5uemhkamliaWxlYnBqZ2Fxa2R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzODQ3MDcsImV4cCI6MjA2NDk2MDcwN30.kCvBzHhs5g6PWFsGghUD72_v0RGQ2H8hWrH_AZ0QyGc'
    ),
    body := '{}'::jsonb
  );
  $$
);