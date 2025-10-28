# Business Home Feature Documentation

## Overview

The **Business Home** feature allows business users to view and manage jobs they have posted. This is the business dashboard for job management and monitoring.

## Feature Structure

```
business_home/
├── bloc/
│   ├── business_home_bloc.dart       # State management
│   ├── business_home_event.dart      # Events (LoadPostedJobs)
│   └── business_home_state.dart      # States (Loading, Loaded, Error)
├── data/
│   ├── datasources/
│   │   └── business_home_local_data_source.dart    # User-filtered jobs
│   └── repositories/
│       └── business_home_repository_impl.dart      # Repository implementation
├── domain/
│   ├── repositories/
│   │   └── business_home_repository.dart           # Repository interface
│   └── usecases/
│       └── get_posted_jobs.dart                    # Fetch user's posted jobs
└── presentation/
    ├── screens/
    │   └── business_home_screen.dart               # Main UI
    └── widgets/
        └── posted_jobs_list.dart                   # Job list display
```

## Key Features

### 1. Posted Jobs Management
- View all jobs posted by the current business user
- See job status (open, closed, in-progress)
- Quick access to job details

### 2. Job Posting
- FloatingActionButton to create new job posts
- (Navigate to job creation screen - not yet implemented)

### 3. Job Statistics
- Visual overview of posted jobs
- Status indicators for each job

## Shared Components

### Data Source
Uses **shared JobDataSource** (`core/data/datasources/job_data_source.dart`):
```dart
class BusinessHomeLocalDataSourceImpl implements BusinessHomeLocalDataSource {
  final JobDataSource jobDataSource;
  
  @override
  Future<List<Job>> getPostedJobs() async {
    // Fetch jobs created by current user
    return await jobDataSource.getJobsByUser('me');
  }
}
```

### Domain Models
- **Job**: Shared job entity with `createdBy` field for filtering

### UI Components
- **JobCard**: Reused from shared widgets to display job information
- **PostedJobsList**: Feature-specific widget wrapping JobCard list

## Use Cases

### GetPostedJobs
**Purpose**: Fetch jobs posted by the current business user

```dart
typedef GetPostedJobs = Future<List<Job>> Function();

GetPostedJobs makeGetPostedJobs(BusinessHomeRepository repository) {
  return () => repository.getPostedJobs();
}
```

## State Management

### Events
```dart
abstract class BusinessHomeEvent {}

class LoadPostedJobs extends BusinessHomeEvent {}
```

### States
```dart
abstract class BusinessHomeState {}

class BusinessHomeLoading extends BusinessHomeState {}

class BusinessHomeLoaded extends BusinessHomeState {
  final List<Job> postedJobs;
}

class BusinessHomeError extends BusinessHomeState {
  final String message;
}
```

## Data Flow

```
Screen Initialized
  ↓
LoadPostedJobs Event
  ↓
BusinessHomeBloc
  ↓
getPostedJobs() usecase
  ↓
BusinessHomeRepository.getPostedJobs()
  ↓
BusinessHomeLocalDataSource.getPostedJobs()
  ↓
JobDataSource.getJobsByUser('me') [Shared]
  ↓
Returns filtered List<Job>
  ↓
BusinessHomeLoaded state
  ↓
UI displays user's posted jobs
```

## UI Layout

```
┌─────────────────────────────────────┐
│  AppBar                             │
│  "My Job Posts"                     │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  Posted Jobs List                   │
│  ┌─────────────────────────────────┤
│  │ Job Card 1                      │
│  │ • Title                         │
│  │ • Description                   │
│  │ • Budget                        │
│  │ • Status Badge                  │
│  ├─────────────────────────────────┤
│  │ Job Card 2                      │
│  │ ...                             │
│  └─────────────────────────────────┘
│                                     │
│  [Empty State if no jobs]           │
│  "You have not posted any jobs yet."│
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  FloatingActionButton               │
│  [+] "Post a Job"                   │
└─────────────────────────────────────┘
```

## Business Logic

### Job Filtering by User
```dart
Future<List<Job>> getJobsByUser(String userId) async {
  return _allJobs.where((job) => job.createdBy == userId).toList();
}
```

The filtering happens at the **data source level** using the shared JobDataSource, ensuring:
- Consistent filtering logic
- Single source of truth
- Easy to test and maintain

## Integration Points

### Shared Data Source
- Uses `JobDataSource.getJobsByUser(userId)`
- Same data pool as Home and Search features
- Real-time consistency across features

### Navigation
- **Job Card Tap**: Navigate to job details (not yet implemented)
- **FAB**: Navigate to job creation form (not yet implemented)

## Future Enhancements

1. **Job Analytics**: Views, applications, completion rate
2. **Edit Job**: Modify existing job posts
3. **Delete Job**: Remove job posts
4. **Job Status Management**: Change status (open → in-progress → closed)
5. **Applicant Management**: View and manage job applications
6. **Quick Actions**: Duplicate, close, boost job posts
7. **Filters**: Filter by status, date, budget range
8. **Sort Options**: Sort by date, status, budget, applications

## PostedJobsList Widget

**Purpose**: Display list of posted jobs with empty state handling

```dart
class PostedJobsList extends StatelessWidget {
  final List<Job> postedJobs;

  @override
  Widget build(BuildContext context) {
    if (postedJobs.isEmpty) {
      return const Center(
        child: Text('You have not posted any jobs yet.'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Insets.lg),
      itemCount: postedJobs.length,
      itemBuilder: (context, index) => JobCard(job: postedJobs[index]),
    );
  }
}
```

## Testing Considerations

### Unit Tests
- Test job filtering by user ID
- Test empty state handling
- Test BLoC state transitions

### Widget Tests
- Test PostedJobsList with empty list
- Test PostedJobsList with jobs
- Test FAB interaction

### Integration Tests
- Test full job loading flow
- Test user-specific job filtering
- Test navigation to job creation

## Migration to Supabase

When connecting to real backend:

1. **Update JobDataSource**:
   ```dart
   @override
   Future<List<Job>> getJobsByUser(String userId) async {
     final response = await supabase
       .from('jobs')
       .select()
       .eq('created_by', userId)
       .order('created_at', ascending: false);
     return response.map((json) => Job.fromJson(json)).toList();
   }
   ```

2. **Get Real User ID**:
   ```dart
   // Instead of hardcoded 'me'
   final userId = supabase.auth.currentUser?.id ?? '';
   return await jobDataSource.getJobsByUser(userId);
   ```

3. **No other changes needed**

## Security Considerations

### Row Level Security (RLS)
When implementing with Supabase:
```sql
-- Only allow users to see their own posted jobs
CREATE POLICY "Users can view own jobs"
ON jobs FOR SELECT
USING (auth.uid() = created_by);

-- Only allow users to update their own jobs
CREATE POLICY "Users can update own jobs"
ON jobs FOR UPDATE
USING (auth.uid() = created_by);
```

### Data Validation
- Validate user ownership before any job modifications
- Implement proper error handling for unauthorized access
- Log suspicious activity

## Related Features

- **Home**: Shows all available jobs (excluding user's own)
- **Search**: Search across all jobs
- **Job Creation**: Create new job posts (not yet implemented)
- **Job Details**: View and edit specific job (not yet implemented)
