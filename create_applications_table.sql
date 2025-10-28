-- ==================== CREATE APPLICATIONS TABLE ====================
-- This table stores job applications from hustlers to jobs posted by job providers

CREATE TABLE IF NOT EXISTS applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  cover_letter TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),
  applied_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  -- Prevent duplicate applications for same job by same user
  UNIQUE(job_id, user_id)
);

-- ==================== CREATE INDEXES ====================
-- For faster queries when fetching user applications or job applications

CREATE INDEX IF NOT EXISTS idx_applications_user_id ON applications(user_id);
CREATE INDEX IF NOT EXISTS idx_applications_job_id ON applications(job_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_applied_at ON applications(applied_at DESC);

-- ==================== ROW LEVEL SECURITY (RLS) ====================
-- Enable RLS for applications table
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- Users can only see their own applications
CREATE POLICY "Users can read their own applications"
  ON applications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only submit their own applications
CREATE POLICY "Users can insert their own applications"
  ON applications
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own applications (withdraw)
CREATE POLICY "Users can update their own applications"
  ON applications
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Job providers can read applications for their posted jobs
CREATE POLICY "Job providers can read applications for their jobs"
  ON applications
  FOR SELECT
  USING (
    job_id IN (
      SELECT id FROM jobs WHERE created_by = auth.uid()
    )
  );

-- ==================== VERIFICATION ====================
-- View the table structure
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'applications'
ORDER BY ordinal_position;

-- Count existing applications (should be 0 initially)
SELECT COUNT(*) as total_applications FROM applications;
