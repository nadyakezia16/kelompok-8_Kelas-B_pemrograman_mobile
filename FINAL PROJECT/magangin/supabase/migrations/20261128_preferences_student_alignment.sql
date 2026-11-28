-- ==========================================
-- MAGANGIN: PREFERENCES STUDENT ALIGNMENT
-- ==========================================

BEGIN;

ALTER TABLE public.preferences
ADD COLUMN IF NOT EXISTS categories TEXT[] NOT NULL DEFAULT '{}',
ADD COLUMN IF NOT EXISTS locations TEXT[] NOT NULL DEFAULT '{}',
ADD COLUMN IF NOT EXISTS work_types TEXT[] NOT NULL DEFAULT '{}',
ADD COLUMN IF NOT EXISTS duration_months INTEGER;

COMMIT;
