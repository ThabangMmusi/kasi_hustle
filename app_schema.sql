-- Kasi Hustle Database Schema
-- Run this SQL in Supabase SQL Editor to create the database structure

-- ============================================
-- PROFILES TABLE
-- ============================================
-- Stores user profile information for both hustlers and businesses
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT,
  last_name TEXT,

  user_type TEXT CHECK (user_type IN ('hustler', 'job_provider')),
  primary_skills TEXT[] DEFAULT '{}',
  secondary_skills TEXT[] DEFAULT '{}',
  bio TEXT,
  profile_image TEXT,
  rating REAL DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  completed_jobs INTEGER DEFAULT 0,
  location_name TEXT,
  latitude REAL,
  longitude REAL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================
-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================
-- TRIGGERS & FUNCTIONS
-- ============================================
-- Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INDEXES
-- ============================================
-- Create indexes for faster queries
CREATE INDEX profiles_user_type_idx ON profiles(user_type);
CREATE INDEX profiles_location_idx ON profiles(latitude, longitude);
CREATE INDEX profiles_created_at_idx ON profiles(created_at DESC);

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON TABLE profiles IS 'User profiles for both hustlers and job providers';
COMMENT ON COLUMN profiles.user_type IS 'Type of user: hustler or job_provider';
COMMENT ON COLUMN profiles.primary_skills IS 'Primary skills for hustlers only';
COMMENT ON COLUMN profiles.secondary_skills IS 'Secondary skills for hustlers only';
COMMENT ON COLUMN profiles.rating IS 'Average rating from reviews';
COMMENT ON COLUMN profiles.total_reviews IS 'Total number of reviews received';
COMMENT ON COLUMN profiles.is_verified IS 'Whether the user is verified';
COMMENT ON COLUMN profiles.completed_jobs IS 'Number of completed jobs';
