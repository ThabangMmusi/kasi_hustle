# Plan: Align Bottom Sheet UIs

## Goal
Align the UI headers of `JobDirectionBottomSheet` and `MessagesBottomSheet` and extract the common header into a reusable widget.

## Proposed Changes

### [UI] Shared Widgets

#### [NEW] [bottom_sheet_header.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/applications/presentation/widgets/bottom_sheet_header.dart)
- Create a reusable `BottomSheetHeader` widget.
- Arguments: `title`, `subtitle`, `icon`, `onClose`.
- Encapsulate the gradient icon container, text layout, close button, and divider.

### [UI] Bottom Sheet Implementation

#### [MODIFY] [job_direction_bottom_sheet.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/applications/presentation/widgets/job_direction_bottom_sheet.dart)
- Replace inline header code with `BottomSheetHeader`.
- Configure with Job Title, Location, and Briefcase icon.

#### [MODIFY] [messages_bottom_sheet.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/applications/presentation/widgets/messages_bottom_sheet.dart)
- Replace inline header code with `BottomSheetHeader`.
- Configure with Job Title, Location, and Briefcase icon.

## Verification Plan

### Manual Verification
1.  **Job Direction**: Verify the header appears correctly using the new widget.
2.  **Messages**: Verify the header matches the Job Direction header.
