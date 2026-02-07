/*
  # Add sync requests table
  
  1. New Tables
    - `sync_requests`
      - `id` (uuid, primary key)
      - `requested_at` (timestamptz) - When sync was requested
      - `status` (text) - pending, processing, completed, failed
      - `started_at` (timestamptz) - When listener started processing
      - `completed_at` (timestamptz) - When sync finished
      - `groups_synced` (integer) - Number of groups synced
      - `error` (text) - Error message if failed
  
  2. Security
    - Enable RLS on `sync_requests` table
    - Add policy for authenticated users to view sync requests
    - Add policy for authenticated users to create sync requests
*/

CREATE TABLE IF NOT EXISTS sync_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requested_at timestamptz DEFAULT now(),
  status text NOT NULL DEFAULT 'pending',
  started_at timestamptz,
  completed_at timestamptz,
  groups_synced integer DEFAULT 0,
  error text
);

ALTER TABLE sync_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view sync requests"
  ON sync_requests FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can create sync requests"
  ON sync_requests FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "System can update sync requests"
  ON sync_requests FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);