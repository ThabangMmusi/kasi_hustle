# Walkthrough: Home Feature Refactoring & Pagination

## Overview
We have successfully refactored the `Home` feature to adhere to Clean Architecture principles and improved performance by fixing Dependency Injection. Additionally, we implemented infinite scroll pagination for the jobs list.

## Changes

### 1. Core Refactoring (Architecture & DI)
- **Moved Bloc**: `HomeBloc`, `HomeEvent`, and `HomeState` are now located in `lib/features/home/presentation/bloc/home/`.
- **Global Data Source**: `JobDataSource` is now provided globally in `main.dart` using `RepositoryProvider`.
- **Dependency Injection**: `HomeScreen` now correctly accesses `JobDataSource` via `context.read()` and injects it into `HomeRepository`, preventing unnecessary object recreation on rebuilds.
- **UI Components**: Extracted `HomeStatusBarGradient` to `lib/features/home/presentation/widgets/home_status_bar_gradient.dart`.

### 2. Pagination Implementation
- **Data Layer**: Updated `JobDataSource` and `HomeRepository` to support `page` and `limit` parameters, utilizing Supabase's `range()` modifier.
- **Bloc Layer**: Added `LoadMoreJobs` event to `HomeBloc` and implemented logic to append new jobs to the existing list.
- **UI Layer**:
    - Added `ScrollController` loop in `HomeScreen` to detect the bottom of the list.
    - Updated `HomeSimpleBottomSheet` to show a loading indicator when fetching more jobs.

## Verification
- **Static Analysis**: Verified imports and syntax.
- **Manual Check**:
    - **Home Screen**: Should load initial 10 jobs.
    - **Scrolling**: Should trigger "Load More" when nearing bottom.
    - **Pull to Refresh**: Should still work (resetting to page 0).
    - **Map**: Markers should update as new jobs are loaded (appended).

## Files Modified
- `lib/features/home/presentation/bloc/home/home_bloc.dart` (Moved & Updated)
- `lib/core/data/datasources/job_data_source.dart` (Pagination)
- `lib/features/home/data/repositories/home_repository_impl.dart` (Pagination)
- `lib/features/home/presentation/screens/home_screen.dart` (DI & ScrollController)
- `lib/features/home/presentation/widgets/home_simple_bottom_sheet.dart` (Loader & Scroll)
- `lib/main.dart` (Global Provider)
