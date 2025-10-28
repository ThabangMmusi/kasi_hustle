# Job Model Architecture Analysis

## ✅ Current Status: CORRECT & UNIFIED

All three features (Home, Search, BusinessHome) are correctly using the **single shared Job model** from `lib/features/home/domain/models/job.dart`.

---

## Architecture Overview

### Shared Job Model
**Location:** `lib/features/home/domain/models/job.dart`

```dart
class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final double budget;
  final String createdBy;
  final DateTime createdAt;
  final String status;
  final List<String> imageUrls;
}
```

**Fields:**
- `id` - Unique job identifier
- `title` - Job title
- `description` - Detailed job description
- `location` - Human-readable location
- `latitude` - Geographic latitude
- `longitude` - Geographic longitude
- `budget` - Job budget (single value, see note below)
- `createdBy` - User ID of job creator
- `createdAt` - Job creation timestamp
- `status` - Job status (open, in_progress, completed)
- `imageUrls` - Array of job-related images

---

## Data Flow Architecture

### 1. **Data Source Layer** (Centralized)
**File:** `lib/core/data/datasources/job_data_source.dart`

This is the **single source of truth** for all job data:

```
JobDataSourceImpl
├── getAllJobs() → Query all jobs from 'jobs' table
├── getJobsByUser(userId) → Get jobs created by specific user (for BusinessHome)
├── searchJobs(query) → Search jobs by title, description, location (for Search)
└── getUserProfile() → Get current user profile
```

**Key Methods:**
- `getAllJobs()` - Used by Home screen to fetch all available jobs
- `getJobsByUser(userId)` - Used by BusinessHome to fetch user's posted jobs
- `searchJobs(query)` - Used by Search to find matching jobs
- All return `List<Job>` using `Job.fromJson(json)` parser

---

## Feature-Specific Usage

### 1. HOME FEATURE
**Purpose:** Display all available jobs to hustlers

**Flow:**
```
HomeScreen
  ↓
HomeBloc (LoadHomeData)
  ↓
HomeRepository
  ↓
HomeLocalDataSource
  ↓
JobDataSourceImpl.getAllJobs()
  ↓
Returns: List<Job>
  ↓
HomeBloc uses Job model to:
  - Display job cards in UI
  - Filter by skill
  - Get recommended jobs
  - Search within loaded jobs
```

**Usecases:**
- `GetJobs` - Fetches all jobs
- `FilterJobsBySkill` - Filters List<Job> by user's skills
- `GetRecommendedJobs` - Recommends jobs based on skills
- `SearchJobs` - Searches within all jobs

---

### 2. SEARCH FEATURE
**Purpose:** Allow users to search for specific jobs

**Flow:**
```
SearchScreen
  ↓
SearchBloc (SearchJobsEvent)
  ↓
SearchRepository
  ↓
SearchLocalDataSource
  ↓
JobDataSourceImpl.searchJobs(query)
  ↓
Returns: List<Job>
  ↓
SearchBloc emits SearchLoaded with List<Job>
```

**Usecase:**
- `SearchJobs(query)` - Searches jobs by title, description, location

**Key Points:**
- Reuses same Job model
- Queries database with ILIKE search
- Returns filtered List<Job>

---

### 3. BUSINESS_HOME FEATURE
**Purpose:** Display jobs posted by current user (job provider)

**Flow:**
```
BusinessHomeScreen
  ↓
BusinessHomeBloc (LoadPostedJobs)
  ↓
BusinessHomeRepository
  ↓
BusinessHomeLocalDataSource
  ↓
JobDataSourceImpl.getJobsByUser(currentUserId)
  ↓
Returns: List<Job>
  ↓
BusinessHomeBloc emits BusinessHomeLoaded with List<Job>
```

**Usecase:**
- `GetPostedJobs()` - Gets jobs where created_by = current user

**Key Points:**
- Filters jobs by `created_by` field
- Reuses same Job model
- Shows only user's posted jobs

---

## Data Model Imports

| Feature | File | Imports |
|---------|------|---------|
| Home | `home_bloc.dart` | `import 'package:kasi_hustle/features/home/domain/models/job.dart';` |
| Search | `search_bloc.dart` | `import 'package:kasi_hustle/features/home/domain/models/job.dart';` |
| BusinessHome | `business_home_bloc.dart` | `import 'package:kasi_hustle/features/home/domain/models/job.dart';` |
| Usecases | `search_jobs.dart`, `get_jobs.dart`, `get_posted_jobs.dart` | All import from `home/domain/models/job.dart` |

---

## Database Schema Mapping

The `Job.fromJson()` factory maps Supabase `jobs` table columns to Dart fields:

```dart
Job.fromJson(Map<String, dynamic> json) {
  return Job(
    id: json['id'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    location: json['location'] ?? '',
    latitude: json['latitude']?.toDouble() ?? 0.0,
    longitude: json['longitude']?.toDouble() ?? 0.0,
    budget: json['budget']?.toDouble() ?? 0.0,        // ⚠️ See notes below
    createdBy: json['created_by'] ?? '',
    createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    status: json['status'] ?? 'open',
    imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : [],
  );
}
```

**Database Columns Needed:**
- `id` (UUID)
- `title` (TEXT)
- `description` (TEXT)
- `location` (TEXT)
- `latitude` (NUMERIC/FLOAT)
- `longitude` (NUMERIC/FLOAT)
- `budget` (NUMERIC) - Currently stored as single value
- `created_by` (UUID - foreign key to profiles.id)
- `created_at` (TIMESTAMP)
- `status` (TEXT: 'available', 'in_progress', 'completed')
- `image_urls` (JSONB/TEXT[] array)

---

## ⚠️ Current Issues & Recommendations

### Issue 1: Budget Model is Incomplete
**Current:** Single `budget: double` field
**Problem:** Seed script creates jobs with `budget_min` and `budget_max` but model only has single `budget`

**Recommendation:**
Update Job model to support budget range:

```dart
class Job {
  final String id;
  // ... other fields
  final double budgetMin;
  final double budgetMax;
  
  // Or keep single budget for simplicity:
  // final double budget;
  
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      // ... other fields
      budgetMin: json['budget_min']?.toDouble() ?? 0.0,
      budgetMax: json['budget_max']?.toDouble() ?? 0.0,
    );
  }
}
```

---

### Issue 2: Missing fields in Job Model
**Current Job model missing:**
- `required_skills` (List<String>) - Array of required skills
- `budget_min` & `budget_max` (instead of single `budget`)
- Potentially: `user_name`, `user_rating`, `distance_from_user`

**Recommendation:**
Update Job model to include:

```dart
class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> requiredSkills;      // NEW
  final double budgetMin;                  // NEW (replace budget)
  final double budgetMax;                  // NEW (replace budget)
  final String createdBy;
  final DateTime createdAt;
  final String status;
  final List<String> imageUrls;
  
  // Optional fields for enriched display:
  final String? createdByName;             // NEW (from profiles join)
  final double? createdByRating;           // NEW (from profiles join)
  final double? distanceFromUser;          // NEW (calculated)
}
```

---

## ✅ What's Working Well

1. **Centralized Data Source** ✓
   - All features use `JobDataSourceImpl`
   - Single point of data access
   - No redundancy

2. **Shared Job Model** ✓
   - All features import from same location
   - Consistent data structure
   - Easy to maintain

3. **Clean Architecture** ✓
   - Clear separation: Data → Domain → Presentation
   - Each feature has own Repository & Usecases
   - BLoCs properly typed with Job model

4. **Reusable Queries** ✓
   - `getAllJobs()` - for home feed
   - `getJobsByUser()` - for business dashboard
   - `searchJobs()` - for search functionality

---

## UI Component Integration

All three features use the same `JobCard` widget:

```dart
// From lib/core/widgets/job_card.dart
JobCard(job: job)  // Accepts Job model instance
```

**Used in:**
- Home: `HomeScreen` → displays job cards in scrollable list
- Search: `SearchScreen` → displays search results as job cards
- BusinessHome: `PostedJobsList` → displays user's posted jobs

---

## Summary

| Aspect | Status | Details |
|--------|--------|---------|
| Model Unification | ✅ Correct | Single Job model in `home/domain/models/job.dart` |
| Data Source | ✅ Correct | Centralized `JobDataSourceImpl` |
| Feature Integration | ✅ Correct | All features properly use Job model |
| Architecture | ✅ Clean | Proper layering: Data → Domain → Presentation |
| **Budget Handling** | ⚠️ Needs Update | Model has single `budget`, seed script uses `budget_min`/`budget_max` |
| **Skills Support** | ⚠️ Missing | Model lacks `requiredSkills` field |

---

## Next Steps

1. **Update Job Model** to include:
   - `budgetMin` and `budgetMax` instead of single `budget`
   - `requiredSkills: List<String>` field

2. **Update Job.fromJson()** to parse new fields from database

3. **Update JobCard widget** to display budget range and required skills

4. **Update Seed Script** to use `budget_min`/`budget_max` table columns

5. **Test Integration** across all three features (Home, Search, BusinessHome)
