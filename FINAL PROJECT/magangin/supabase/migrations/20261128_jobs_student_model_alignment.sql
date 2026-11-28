-- ==========================================
-- MAGANGIN: JOBS STUDENT MODEL ALIGNMENT
-- ==========================================

BEGIN;

-- Tambahkan kolom yang dibutuhkan model Job.
ALTER TABLE public.jobs
ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT 'Other',
ADD COLUMN IF NOT EXISTS duration_months INTEGER NOT NULL DEFAULT 3,
ADD COLUMN IF NOT EXISTS is_paid BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS allowance NUMERIC,
ADD COLUMN IF NOT EXISTS qualifications TEXT[] NOT NULL DEFAULT '{}',
ADD COLUMN IF NOT EXISTS benefits TEXT[] NOT NULL DEFAULT '{}';

-- Pastikan kolom yang wajib dibaca model tidak NULL.
UPDATE public.jobs
SET
    location = COALESCE(location, 'Belum ditentukan'),
    work_type = COALESCE(work_type, 'onsite');

ALTER TABLE public.jobs
ALTER COLUMN location SET DEFAULT 'Belum ditentukan',
ALTER COLUMN location SET NOT NULL,
ALTER COLUMN work_type SET DEFAULT 'onsite',
ALTER COLUMN work_type SET NOT NULL;

COMMIT;
