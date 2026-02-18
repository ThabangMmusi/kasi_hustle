# Plan: Deep Analysis of Home Feature

## Goal
Conduct a comprehensive analysis of the `features/home` module to identify architectural issues, code quality improvements, and potential bugs.

## Current State
- **Feature Location**: `lib/features/home` (Assumed, collecting verification)
- **Known Issues**: Previous refactoring touched on job application logic centralization.
- **Objectives**:
    - Verify adherence to Clean Architecture.
    - Identify UI/UX inconsistencies.
    - Check for performance bottlenecks (e.g., unnecessary rebuilds).
    - Audit State Management usage.

## Analysis Steps
1.  **Structure Audit**: Map out files and folders.
2.  **Layer Analysis**:
    - **Presentation**: Check `HomeScreen`, widgets, and Blocs.
    - **Domain**: Verify entities and use cases.
    - **Data**: Check repositories and data sources.
3.  **Dependency Check**: Ensure no circular dependencies or layer violations.

## Findings

### 1. Architectural Violations (Critical)
- **Dependency Injection**: `HomeScreen` manually instantiates `JobDataSourceImpl`, `HomeLocalDataSourceImpl`, and `HomeRepositoryImpl` inside the `build` method.
    - **Impact**: Objects are recreated on every rebuild, leading to performance issues and untestable code. It breaks the dependency inversion principle.
    - **Location**: `lib/features/home/presentation/screens/home_screen.dart`

### 2. File Structure Inconsistencies
- **Bloc Location**: `HomeBloc` is located in `features/home/bloc`, while `HomeMapBloc` is in `features/home/presentation/bloc/map`.
    - **Impact**: Inconsistent project structure makes navigation harder.
    - **Recommendation**: Move `HomeBloc` to `features/home/presentation/bloc/home`.

### 3. Data Layer Analysis
- **Reuse**: `HomeLocalDataSourceImpl` correctly delegates to `JobDataSource`, promoting reuse.
- **Caching**: `JobDataSourceImpl` uses `SharedPreferences` for caching. It mixes API logic with Cache logic, which is acceptable for simpler apps but could be separated into `RemoteDataSource` and `LocalDataSource` for better scalability.

### 4. UI/UX Code Quality
- **Hardcoded Styles**: `HomeScreen` contains a hardcoded gradient container for the status bar background. This should be extracted to a reusable widget or defined in `AppTheme`.

## Proposed Changes

### Phase 1: Dependency Injection Refactor
#### [MODIFY] [main.dart](file:///c:/devs/flutter/kasi_hustle/lib/main.dart)
- Add `RepositoryProvider` for `JobDataSource`.
- Initialize `JobDataSourceImpl` with Supabase client.

#### [MODIFY] [home_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/screens/home_screen.dart)
- Remove manual instantiation of `JobDataSourceImpl`.
- Retrieve `JobDataSource` via `context.read()`.
- Use `RepositoryProvider` to provide `HomeRepository` to the `HomeBloc`, ensuring it's only created once.

### Phase 2: Structure Cleanup
#### [MOVE] `features/home/bloc` -> `features/home/presentation/bloc/home`
- Move `home_bloc.dart`, `home_event.dart`, `home_state.dart`.

### Phase 3: UI Cleanup
#### [NEW] `features/home/presentation/widgets/home_components.dart`
- Extract generic UI components like gradients.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no regressions.
- Verify `HomeBloc` tests pass after moving.

### Phase 4: Pagination Implementation
#### [MODIFY] [job_data_source.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/data/datasources/job_data_source.dart)
- Update `getAllJobs` to accept `page` (int) and `limit` (int = 10).
- Use Supabase `.range(start, end)` for efficient fetching.

#### [MODIFY] [home_bloc.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/bloc/home_bloc.dart)
- Add `LoadMoreJobs` event.
- Add `hasReachedMax` to state.
- Implement logic to append jobs instead of replacing them.

#### [MODIFY] [home_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/screens/home_screen.dart)
- Add `ScrollController` loop to detect bottom of list.
- Trigger `LoadMoreJobs` when threshold reached.
- Show loading indicator at the bottom.
