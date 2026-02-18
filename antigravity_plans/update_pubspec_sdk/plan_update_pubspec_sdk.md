# Update Pubspec SDK Environment

## Goal Description
Update the `environment` section in `pubspec.yaml` to match the currently installed Dart SDK version (`3.11.0`). The current constraint `^3.9.2` is outdated.

## Proposed Changes
### Root Directory
#### [MODIFY] [pubspec.yaml](file:///c:/devs/flutter/kasi_hustle/pubspec.yaml)
- Change `environment.sdk` constraint from `^3.9.2` to `^3.11.0`.

## Verification Plan
### Automated Tests
- Run `flutter pub get` to ensure the new constraint is valid and compatible with dependencies.
- Run `flutter --version` to confirm environment match (already done).
