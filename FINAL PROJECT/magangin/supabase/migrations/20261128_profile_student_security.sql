-- ==========================================
-- MAGANGIN: PROFILE STUDENT SECURITY
-- ==========================================

BEGIN;

-- 1. Tambahkan kolom bio untuk profil mahasiswa.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS bio TEXT;

-- 2. Batasi role yang diperbolehkan hanya student.
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_role_check
CHECK (role = 'student');

-- 3. Pastikan mahasiswa hanya dapat memperbarui
-- kolom profil yang memang boleh diedit.
REVOKE UPDATE ON public.profiles FROM authenticated;

GRANT UPDATE (
    full_name,
    phone,
    university,
    major,
    semester,
    bio,
    avatar_url
)
ON public.profiles TO authenticated;

COMMIT;