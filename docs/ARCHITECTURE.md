# Kasi Hustle - Clean Architecture Documentation

## Overview

This document describes the overall architecture of the Kasi Hustle application, focusing on how features are structured using Clean Architecture principles and how they share common components.

## Architecture Principles

The application follows **Clean Architecture** with clear separation of concerns across three main layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Screens, Widgets, BLoC)          │
└──────────────┬──────────────────────────┘
               │ depends on
┌──────────────▼──────────────────────────┐
│          Domain Layer                   │
│  (Entities, Use Cases, Repositories)    │
└──────────────┬──────────────────────────┘
               │ implements
┌──────────────▼──────────────────────────┐
│           Data Layer                    │
│  (Data Sources, Repository Impl)        │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Data Layer** (`/data`)
- **Data Sources**: Handle raw data operations (API calls, database queries, cache)
- **Repository Implementations**: Implement domain repository interfaces
- Contains all data fetching and storage logic
- No business logic

#### 2. **Domain Layer** (`/domain`)
- **Models/Entities**: Core business objects (Job, UserProfile)
- **Repositories**: Abstract interfaces defining data contracts
- **Use Cases**: Single-responsibility business logic operations
- Pure Dart code with no framework dependencies
- No knowledge of UI or data sources

#### 3. **Presentation Layer** (`/presentation`)
- **Screens**: Main UI entry points
- **Widgets**: Reusable UI components
- **BLoC**: State management (moved to `/bloc` at feature root)
- Depends only on domain layer abstractions

## Shared Components

### 1. Shared Data Source: `JobDataSource`

**Location**: `lib/core/data/datasources/job_data_source.dart`

All job-related features use a **single shared data source** to eliminate redundancy:

```dart
abstract class JobDataSource {
  Future<List<Job>> getAllJobs();
  Future<List<Job>> getJobsByUser(String userId);
  Future<List<Job>> searchJobs(String query);
  Future<UserProfile> getUserProfile();
}
```

**Benefits**:
- ✅ Single source of truth for job data
- ✅ Consistent data across all features
- ✅ Easy to swap implementation (e.g., from mock to Supabase)
- ✅ Reduced code duplication

**Used by**:
- `HomeLocalDataSource` - Fetches all jobs and user profile
- `BusinessHomeLocalDataSource` - Fetches user's posted jobs
- `SearchLocalDataSource` - Searches jobs by query

### 2. Shared Domain Models

**Location**: `lib/features/home/domain/models/`

Common models used across features:
- **Job**: Core job entity with all job attributes
- **UserProfile**: User information including skills and ratings

These models are shared across:
- Home feature (display jobs)
- Business Home feature (manage posted jobs)
- Search feature (search results)

### 3. Shared UI Widgets

**Location**: `lib/core/widgets/`

Reusable UI components:
- `JobCard` - Display job information (used by Home, BusinessHome, Search)
- `UiText` - Styled text component
- `PrimaryBtn`, `SecondaryBtn` - Button components
- `StyledTextInput` - Input field component
- `StyledLoadSpinner` - Loading indicator

## Feature Structure

Each feature follows the same structure:

```
feature_name/
├── bloc/                    # BLoC state management
│   ├── feature_bloc.dart
│   ├── feature_event.dart
│   └── feature_state.dart
├── data/                    # Data layer
│   ├── datasources/
│   │   └── feature_local_data_source.dart
│   └── repositories/
│       └── feature_repository_impl.dart
├── domain/                  # Domain layer
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
│       └── use_case.dart
└── presentation/            # Presentation layer
    ├── screens/
    │   └── feature_screen.dart
    └── widgets/
        └── feature_widget.dart
```

## Dependency Flow

```
Screen
  ↓ creates
JobDataSource (shared)
  ↓ injected into
FeatureLocalDataSource
  ↓ injected into
FeatureRepositoryImpl
  ↓ used by
UseCase (callable)
  ↓ injected into
BLoC
  ↓ provided to
Screen
```

## Features Overview

### 1. Home Feature
- **Purpose**: Browse available jobs, get recommendations
- **Shared Components**: JobDataSource, Job model, JobCard widget
- **Unique**: Skill-based filtering, recommendations algorithm

### 2. Business Home Feature
- **Purpose**: Manage jobs posted by business users
- **Shared Components**: JobDataSource, Job model, JobCard widget
- **Unique**: User-specific job filtering (by creator)

### 3. Search Feature
- **Purpose**: Search jobs by keywords
- **Shared Components**: JobDataSource, Job model, JobCard widget
- **Unique**: Real-time search with query filtering

## Data Flow Example

### Search Job Flow

1. **User types in SearchScreen**
   ```dart
   onChanged: (query) => context.read<SearchBloc>().add(SearchJobsEvent(query))
   ```

2. **SearchBloc receives event**
   ```dart
   final results = await searchJobs(event.query)
   ```

3. **Use case calls repository**
   ```dart
   searchJobs(query) => repository.searchJobs(query)
   ```

4. **Repository calls data source**
   ```dart
   await localDataSource.searchJobs(query)
   ```

5. **Local data source delegates to shared JobDataSource**
   ```dart
   await jobDataSource.searchJobs(query)
   ```

6. **Shared JobDataSource filters jobs**
   ```dart
   return _allJobs.where((job) => 
     job.title.contains(query) || 
     job.description.contains(query)
   ).toList()
   ```

7. **Results flow back up the chain to UI**

## Benefits of This Architecture

1. **Testability**: Each layer can be tested independently with mocks
2. **Maintainability**: Changes to one layer don't affect others
3. **Scalability**: Easy to add new features following the same pattern
4. **Reusability**: Shared components reduce duplication
5. **Flexibility**: Easy to swap implementations (e.g., mock → API → local DB)

## Migration to Real Backend

When connecting to Supabase:

1. **Update JobDataSource implementation**:
   ```dart
   class JobDataSourceImpl implements JobDataSource {
     final SupabaseClient supabase;
     
     @override
     Future<List<Job>> getAllJobs() async {
       final response = await supabase.from('jobs').select();
       return response.map((json) => Job.fromJson(json)).toList();
     }
   }
   ```

2. **No changes needed in**:
   - Domain layer (repositories, use cases)
   - BLoC layer
   - Presentation layer

3. **Only update**:
   - `JobDataSourceImpl` implementation
   - Data source instantiation in screens

## Future Considerations

### Dependency Injection
Currently using manual dependency injection in screens. Consider:
- **get_it**: Service locator for singleton management
- **Provider**: For widget tree injection
- **Riverpod**: For modern state management and DI

### State Management
Currently using BLoC. Each feature has its own BLoC:
- Isolated state per feature
- Clear event → state flow
- Easy to debug and test

### Code Generation
Consider using:
- **freezed**: For immutable models with copyWith
- **json_serializable**: For JSON parsing
- **injectable**: For dependency injection

## See Also

- [Home Feature Documentation](./HOME.md)
- [Business Home Feature Documentation](./BUSINESS_HOME.md)
- [Search Feature Documentation](./SEARCH.md)
