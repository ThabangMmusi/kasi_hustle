# Home Feature Documentation

## Overview

The **Home** feature is the main job discovery screen where users can browse available jobs, get personalized recommendations based on their skills, and filter jobs by skill categories.

## Feature Structure

```
home/
├── bloc/
│   ├── home_bloc.dart       # State management
│   ├── home_event.dart      # Events (Load, Refresh, Search, Filter)
│   └── home_state.dart      # States (Initial, Loading, Loaded, Error)
├── data/
│   ├── datasources/
│   │   └── home_local_data_source.dart    # Delegates to shared JobDataSource
│   └── repositories/
│       └── home_repository_impl.dart      # Business logic implementation
├── domain/
│   ├── models/
│   │   ├── job.dart                       # Job entity (shared)
│   │   └── user_profile.dart              # UserProfile entity (shared)
│   ├── repositories/
│   │   └── home_repository.dart           # Repository interface
│   └── usecases/
│       ├── get_user_profile.dart          # Fetch user profile
│       ├── get_jobs.dart                  # Fetch all jobs
│       ├── get_recommended_jobs.dart      # Calculate recommendations
│       ├── search_jobs.dart               # Search by query
│       └── filter_jobs_by_skill.dart      # Filter by skill
└── presentation/
    └── screens/
        └── home_screen.dart               # Main UI
```

## Key Features

### 1. Job Discovery
- Displays all available jobs in the platform
- Real-time updates with pull-to-refresh
- Pagination-ready architecture

### 2. Personalized Recommendations
- Matches user skills with job requirements
- Shows top 2 recommended jobs prominently
- Filters based on user's skill set

### 3. Skill-based Filtering
- Filter chips for each user skill
- Toggle filtering on/off
- Updates displayed jobs in real-time

### 4. Greeting System
- Dynamic greeting based on time of day
- Personalized to user context

## Shared Components

### Data Source
Uses **shared JobDataSource** (`core/data/datasources/job_data_source.dart`):
```dart
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final JobDataSource jobDataSource;
  
  @override
  Future<UserProfile> getUserProfile() => jobDataSource.getUserProfile();
  
  @override
  Future<List<Job>> getJobs() => jobDataSource.getAllJobs();
}
```

### Domain Models
- **Job**: Shared across all job-related features
- **UserProfile**: Contains user skills for recommendations

### UI Components
- **JobCard**: Displays individual job information
- **StyledLoadSpinner**: Loading indicator
- **PrimaryBtn**: Retry button on error

## Use Cases

### 1. GetUserProfile
**Purpose**: Fetch current user's profile including skills
```dart
typedef GetUserProfile = Future<UserProfile> Function();
```

### 2. GetJobs
**Purpose**: Fetch all available jobs
```dart
typedef GetJobs = Future<List<Job>> Function();
```

### 3. GetRecommendedJobs
**Purpose**: Filter jobs that match user's skills
```dart
typedef GetRecommendedJobs = List<Job> Function(
  List<Job> allJobs,
  List<String> userSkills,
);
```

### 4. SearchJobs
**Purpose**: Search jobs by title or description
```dart
typedef SearchJobs = List<Job> Function(
  List<Job> jobs,
  String query,
);
```

### 5. FilterJobsBySkill
**Purpose**: Filter jobs by specific skill
```dart
typedef FilterJobsBySkill = List<Job> Function(
  List<Job> jobs,
  String skill,
);
```

## State Management

### Events
```dart
abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}
class RefreshHomeData extends HomeEvent {}
class SearchJobsEvent extends HomeEvent {
  final String query;
}
class FilterBySkill extends HomeEvent {
  final String skill;
}
```

### States
```dart
abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final UserProfile user;
  final List<Job> allJobs;
  final List<Job> recommendedJobs;
  final List<Job> displayedJobs;
  final String? selectedSkillFilter;
}
class HomeError extends HomeState {
  final String message;
}
```

## Data Flow

```
User Action (Pull to Refresh)
  ↓
RefreshHomeData Event
  ↓
HomeBloc
  ↓
getJobs() usecase
  ↓
HomeRepository.getJobs()
  ↓
HomeLocalDataSource.getJobs()
  ↓
JobDataSource.getAllJobs() [Shared]
  ↓
Returns List<Job>
  ↓
getRecommendedJobs() filters based on skills
  ↓
HomeLoaded state with jobs + recommendations
  ↓
UI updates with new data
```

## UI Layout

```
┌─────────────────────────────────────┐
│  Dark Header Section                │
│  • Dynamic Greeting                 │
│  • Search Bar (navigates to Search) │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  White Content Section              │
│  ┌─────────────────────────────────┤
│  │ Skill Filter Chips              │
│  │ [Plumbing] [Electrical] [...]   │
│  ├─────────────────────────────────┤
│  │ ⭐ Recommended for You          │
│  │ • Job Card 1                    │
│  │ • Job Card 2                    │
│  ├─────────────────────────────────┤
│  │ All Jobs (X available)          │
│  │ • Job Card 1                    │
│  │ • Job Card 2                    │
│  │ • ...                           │
│  └─────────────────────────────────┘
└─────────────────────────────────────┘
```

## Business Logic

### Recommendation Algorithm
```dart
List<Job> getRecommendedJobs(List<Job> allJobs, List<String> userSkills) {
  return allJobs.where((job) {
    return userSkills.any((skill) =>
      job.title.toLowerCase().contains(skill.toLowerCase()) ||
      job.description.toLowerCase().contains(skill.toLowerCase())
    );
  }).toList();
}
```

### Skill Filtering
- When skill chip is tapped, filter jobs containing that skill
- Tapping the same chip again removes the filter
- Shows all jobs when no filter is active

## Integration Points

### Navigation
- **Search Bar**: Navigates to Search feature
- **Job Card**: Navigates to Job Details (not yet implemented)

### Shared Data
- Reads from same `JobDataSource` as Business Home and Search
- Changes in job data are reflected across all features

## Future Enhancements

1. **Location-based Filtering**: Filter jobs by distance
2. **Budget Range Filter**: Filter by min/max budget
3. **Job Status Filter**: Show only open/in-progress jobs
4. **Saved Jobs**: Bookmark jobs for later
5. **Job Alerts**: Notifications for new matching jobs
6. **Advanced Recommendations**: ML-based job matching

## Testing Considerations

### Unit Tests
- Test recommendation algorithm with various skill sets
- Test filtering logic with different queries
- Test state transitions in BLoC

### Widget Tests
- Test filter chip interactions
- Test pull-to-refresh functionality
- Test empty state display

### Integration Tests
- Test full job loading and display flow
- Test recommendation accuracy
- Test filter + recommendation interaction

## Migration to Supabase

When connecting to real backend:

1. **No changes needed** in:
   - Domain layer (use cases, repositories)
   - BLoC layer
   - Presentation layer

2. **Only update** `JobDataSource` implementation:
   ```dart
   @override
   Future<List<Job>> getAllJobs() async {
     final response = await supabase
       .from('jobs')
       .select()
       .eq('status', 'open');
     return response.map((json) => Job.fromJson(json)).toList();
   }
   ```

## Related Features

- **Business Home**: Shows jobs posted by current user
- **Search**: Full-text search across all jobs
- **Auth**: Provides user context for recommendations
