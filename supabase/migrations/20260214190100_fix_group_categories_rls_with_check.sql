-- Migration: Fix group_categories RLS policy - add WITH CHECK clause
-- Spec: 301-group-category-management
-- Fix: ALL policy was missing WITH CHECK, causing INSERT/UPDATE to fail

DROP POLICY IF EXISTS "Authenticated users can manage group_categories" ON wa_intel.group_categories;

CREATE POLICY "Authenticated users can manage group_categories"
  ON wa_intel.group_categories FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
