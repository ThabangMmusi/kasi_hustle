-- ============================================
-- DUMMY JOBS SEED SCRIPT FOR KIMBERLEY
-- ============================================
-- Creates 50+ jobs around Kimberley area
-- User: ea6c2003-d8f4-4623-ae50-d2aa7693b947
-- Location: -28.7492, 24.766
-- Budget: R200-R1000

-- First, create the jobs table if it doesn't exist
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  required_skills TEXT[] DEFAULT '{}',
  budget_min REAL NOT NULL,
  budget_max REAL NOT NULL,
  location_name TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'in_progress', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert 50+ dummy jobs
INSERT INTO jobs (user_id, title, description, required_skills, budget_min, budget_max, location_name, latitude, longitude, status)
VALUES
  -- Plumbing Jobs (8 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Fix Kitchen Tap', 'Leaking kitchen tap needs replacement', ARRAY['Plumbing'], 250, 450, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Bathroom Pipe Repair', 'Burst pipe in bathroom wall', ARRAY['Plumbing'], 400, 700, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Toilet Installation', 'Install new toilet suite', ARRAY['Plumbing', 'Handyman'], 600, 950, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Water Tank Cleaning', 'Clean and inspect water tank', ARRAY['Plumbing'], 300, 500, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Drain Blockage', 'Clear blocked drain pipe', ARRAY['Plumbing', 'Handyman'], 200, 350, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Hot Water Geyser Install', 'Install new geyser', ARRAY['Plumbing', 'Electrical'], 700, 1000, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Tap Aerator Replacement', 'Replace multiple tap aerators', ARRAY['Plumbing'], 150, 300, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Shower Valve Repair', 'Fix pressure valve in shower', ARRAY['Plumbing'], 350, 600, 'Kimberley South', -28.7600, 24.7550, 'available'),

  -- Electrical Jobs (8 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Install Light Fixtures', 'Install 6 new light fixtures', ARRAY['Electrical', 'Handyman'], 500, 800, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Wire House', 'Complete house wiring for new build', ARRAY['Electrical'], 800, 1000, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Fix Electrical Outlets', 'Install 4 new outlets', ARRAY['Electrical'], 300, 500, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Circuit Breaker Replacement', 'Replace main circuit breaker', ARRAY['Electrical'], 600, 900, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Install Ceiling Fan', 'Install ceiling fan with light', ARRAY['Electrical', 'Handyman'], 250, 450, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Test Electrical System', 'Test and repair faulty wiring', ARRAY['Electrical'], 400, 700, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Solar Panel Installation', 'Install solar panel system', ARRAY['Electrical'], 900, 1000, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Surge Protector Install', 'Install surge protection devices', ARRAY['Electrical'], 200, 350, 'Kimberley North', -28.7350, 24.7680, 'available'),

  -- Carpentry Jobs (7 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Build Shelving Unit', 'Build custom shelving for bedroom', ARRAY['Carpentry', 'Handyman'], 400, 650, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Cabinet Installation', 'Install kitchen cabinets', ARRAY['Carpentry'], 700, 950, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Door Frame Repair', 'Fix damaged door frames', ARRAY['Carpentry', 'Handyman'], 300, 500, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Deck Building', 'Build wooden deck', ARRAY['Carpentry', 'Roofing'], 600, 900, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Furniture Repair', 'Repair antique furniture', ARRAY['Carpentry'], 250, 450, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Window Frame Repair', 'Fix wooden window frames', ARRAY['Carpentry', 'Handyman'], 350, 600, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Table Building', 'Build custom dining table', ARRAY['Carpentry'], 500, 800, 'Kimberley East', -28.7400, 24.7750, 'available'),

  -- Painting Jobs (7 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Interior House Painting', 'Paint 3 bedroom house interior', ARRAY['Painting', 'Handyman'], 500, 800, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Exterior Wall Painting', 'Paint house exterior walls', ARRAY['Painting', 'Roofing'], 600, 950, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Fence Painting', 'Paint wooden fence', ARRAY['Painting', 'Carpentry'], 300, 500, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Room Accent Wall', 'Paint accent wall with design', ARRAY['Painting'], 200, 400, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Cabinet Refinishing', 'Repaint kitchen cabinets', ARRAY['Painting', 'Carpentry'], 350, 600, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Deck Staining', 'Stain wooden deck', ARRAY['Painting', 'Carpentry'], 400, 700, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Mural Painting', 'Paint mural in child bedroom', ARRAY['Painting'], 450, 750, 'Kimberley West', -28.7520, 24.7500, 'available'),

  -- Cleaning Jobs (6 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Deep House Cleaning', 'Deep clean 3 bedroom house', ARRAY['Cleaning'], 300, 500, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Carpet Cleaning', 'Clean carpets in entire house', ARRAY['Cleaning'], 250, 450, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Window Cleaning', 'Clean all windows inside and out', ARRAY['Cleaning'], 200, 350, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Post Construction Cleaning', 'Clean after renovation work', ARRAY['Cleaning'], 400, 700, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Gutter Cleaning', 'Clean and maintain gutters', ARRAY['Cleaning', 'Handyman'], 200, 350, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Office Cleaning', 'Weekly office cleaning', ARRAY['Cleaning'], 300, 500, 'Kimberley Central', -28.7492, 24.766, 'available'),

  -- Roofing Jobs (5 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Roof Inspection', 'Inspect and repair roof damage', ARRAY['Roofing'], 400, 700, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Tile Replacement', 'Replace broken roof tiles', ARRAY['Roofing'], 500, 800, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Gutter Installation', 'Install new gutters', ARRAY['Roofing', 'Carpentry'], 600, 900, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Roof Waterproofing', 'Apply waterproof coating', ARRAY['Roofing'], 350, 600, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Skylight Installation', 'Install new skylight', ARRAY['Roofing', 'Carpentry'], 700, 950, 'Kimberley West', -28.7520, 24.7500, 'available'),

  -- Tiling Jobs (5 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Bathroom Tiling', 'Tile bathroom walls and floor', ARRAY['Tiling', 'Carpentry'], 600, 900, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Kitchen Backsplash', 'Install tile backsplash', ARRAY['Tiling'], 400, 700, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Floor Tiling', 'Tile kitchen and living room floors', ARRAY['Tiling'], 700, 950, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Pool Tiling', 'Tile around pool area', ARRAY['Tiling'], 500, 800, 'Kimberley East', -28.7400, 24.7750, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Patio Tiling', 'Tile outdoor patio', ARRAY['Tiling', 'Carpentry'], 550, 850, 'Kimberley West', -28.7520, 24.7500, 'available'),

  -- Gardening Jobs (4 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Lawn Maintenance', 'Weekly lawn mowing and maintenance', ARRAY['Gardening'], 200, 350, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Garden Design', 'Design and plant new garden', ARRAY['Gardening', 'Handyman'], 400, 700, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Tree Trimming', 'Trim and prune trees', ARRAY['Gardening'], 300, 550, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Hedge Installation', 'Plant and maintain hedges', ARRAY['Gardening'], 350, 600, 'Kimberley East', -28.7400, 24.7750, 'available'),

  -- Welding Jobs (3 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Gate Fabrication', 'Weld custom metal gate', ARRAY['Welding', 'Carpentry'], 600, 900, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Fence Repair', 'Weld and repair metal fence', ARRAY['Welding'], 400, 700, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Structural Steel Work', 'Weld structural steel frame', ARRAY['Welding'], 800, 1000, 'Kimberley North', -28.7350, 24.7680, 'available'),

  -- Moving Jobs (3 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'House Moving', 'Move furniture to new house', ARRAY['Moving'], 500, 850, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Office Relocation', 'Move office equipment', ARRAY['Moving'], 600, 900, 'Kimberley South', -28.7600, 24.7550, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Small Item Moving', 'Move small items and furniture', ARRAY['Moving', 'Handyman'], 300, 500, 'Kimberley East', -28.7400, 24.7750, 'available'),

  -- Photography Jobs (2 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Event Photography', 'Photograph birthday party', ARRAY['Photography'], 400, 700, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Product Photography', 'Photograph products for selling', ARRAY['Photography'], 250, 450, 'Kimberley West', -28.7520, 24.7500, 'available'),

  -- Tutoring Jobs (2 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Math Tutoring', 'Tutor high school math', ARRAY['Tutoring'], 200, 350, 'Kimberley North', -28.7350, 24.7680, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'English Tutoring', 'Tutor English language', ARRAY['Tutoring'], 200, 350, 'Kimberley South', -28.7600, 24.7550, 'available'),

  -- Hair & Beauty (2 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Haircut Service', 'Professional haircut and styling', ARRAY['Hair & Beauty'], 150, 300, 'Kimberley Central', -28.7492, 24.766, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Makeup Service', 'Makeup for event', ARRAY['Hair & Beauty'], 250, 450, 'Kimberley East', -28.7400, 24.7750, 'available'),

  -- Catering (2 jobs)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Party Catering', 'Cater for 50 person party', ARRAY['Catering'], 800, 1000, 'Kimberley West', -28.7520, 24.7500, 'available'),
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Lunch Catering', 'Cater lunch for 30 people', ARRAY['Catering'], 600, 900, 'Kimberley North', -28.7350, 24.7680, 'available'),

  -- Security (1 job)
  ('ea6c2003-d8f4-4623-ae50-d2aa7693b947', 'Event Security', 'Provide security for event', ARRAY['Security'], 500, 800, 'Kimberley Central', -28.7492, 24.766, 'available');

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS jobs_user_id_idx ON jobs(user_id);
CREATE INDEX IF NOT EXISTS jobs_status_idx ON jobs(status);
CREATE INDEX IF NOT EXISTS jobs_location_idx ON jobs(latitude, longitude);
CREATE INDEX IF NOT EXISTS jobs_created_at_idx ON jobs(created_at DESC);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_jobs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS update_jobs_updated_at_trigger
  BEFORE UPDATE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION update_jobs_updated_at();

-- Enable RLS on jobs table
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for jobs
CREATE POLICY IF NOT EXISTS "Anyone can read available jobs"
  ON jobs FOR SELECT
  USING (status = 'available');

CREATE POLICY IF NOT EXISTS "Users can read their own jobs"
  ON jobs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can create jobs"
  ON jobs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update their own jobs"
  ON jobs FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Display confirmation
SELECT COUNT(*) as total_jobs_created FROM jobs WHERE user_id = 'ea6c2003-d8f4-4623-ae50-d2aa7693b947';
