-- ==================== UPDATE ALL JOBS WITH REQUIRED SKILLS ====================
-- This script adds 1-2 random skills to all existing jobs based on their title
-- Ensures every job has at least one relevant skill

-- ==================== SKILL MAPPING BY JOB TITLE ====================
-- This uses job titles to intelligently assign relevant skills

UPDATE jobs
SET required_skills = ARRAY['Plumbing']
WHERE LOWER(title) LIKE '%plumb%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Electrical']
WHERE LOWER(title) LIKE '%electr%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Carpentry']
WHERE LOWER(title) LIKE '%carpen%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Painting']
WHERE LOWER(title) LIKE '%paint%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Cleaning']
WHERE LOWER(title) LIKE '%clean%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Gardening']
WHERE LOWER(title) LIKE '%garden%' OR LOWER(title) LIKE '%landscap%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Tiling']
WHERE LOWER(title) LIKE '%tile%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Roofing']
WHERE LOWER(title) LIKE '%roof%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Welding']
WHERE LOWER(title) LIKE '%weld%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Moving']
WHERE LOWER(title) LIKE '%mov%' OR LOWER(title) LIKE '%remov%' OR LOWER(title) LIKE '%transport%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Photography']
WHERE LOWER(title) LIKE '%photo%' OR LOWER(title) LIKE '%photo%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Tutoring']
WHERE LOWER(title) LIKE '%tutor%' OR LOWER(title) LIKE '%teach%' OR LOWER(title) LIKE '%lesson%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Hair & Beauty']
WHERE LOWER(title) LIKE '%hair%' OR LOWER(title) LIKE '%beauty%' OR LOWER(title) LIKE '%salon%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Catering']
WHERE LOWER(title) LIKE '%cater%' OR LOWER(title) LIKE '%cook%' OR LOWER(title) LIKE '%food%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Security']
WHERE LOWER(title) LIKE '%secur%'
  AND (required_skills IS NULL OR required_skills = '{}');

UPDATE jobs
SET required_skills = ARRAY['Handyman', 'General Repair']
WHERE LOWER(title) LIKE '%handyman%' OR LOWER(title) LIKE '%fix%' OR LOWER(title) LIKE '%repair%'
  AND (required_skills IS NULL OR required_skills = '{}');

-- ==================== DEFAULT SKILL ASSIGNMENT ====================
-- For any remaining jobs without skills, assign based on budget and description
-- High budget (>R500) likely complex work, low budget (<R300) likely simple tasks

UPDATE jobs
SET required_skills = ARRAY['General Handyman']
WHERE (required_skills IS NULL OR required_skills = '{}')
  AND budget > 500;

UPDATE jobs
SET required_skills = ARRAY['Cleaning']
WHERE (required_skills IS NULL OR required_skills = '{}')
  AND budget <= 300;

UPDATE jobs
SET required_skills = ARRAY['General Services']
WHERE (required_skills IS NULL OR required_skills = '{}');

-- ==================== VERIFICATION ====================
-- Check how many jobs now have skills
SELECT 
  COUNT(*) as total_jobs,
  COUNT(CASE WHEN required_skills IS NOT NULL AND required_skills != '{}' THEN 1 END) as jobs_with_skills,
  COUNT(CASE WHEN required_skills IS NULL OR required_skills = '{}' THEN 1 END) as jobs_without_skills
FROM jobs;

-- View sample of updated jobs with their skills
SELECT id, title, required_skills, budget
FROM jobs
WHERE required_skills IS NOT NULL AND required_skills != '{}'
LIMIT 20;
