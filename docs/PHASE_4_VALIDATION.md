# Phase 4 Validation

## Result

- Date: 2026-07-20
- Scope: Phase 4 active workout entry, set logging, previous performance,
  outcome capture, rest timers, process recovery, execution statuses, workout
  history, personal records, append-only corrections, resilience tests, and
  Build C2 APK production
- Pull request:
  [#5 Complete Phase 4 active workout and history](https://github.com/emir-ertunc/project-atlas/pull/5)
- Result: Passed
- Remaining Phase 4 checklist items: None

The Phase 4 branch is published as a stacked pull request on top of the Phase 3
branch.

## Build C2 Artifact

- Package: `app.projectatlas.personal`
- Version: `0.1.0+1`
- Version code: `1`
- Application label: `Project Atlas`
- Minimum SDK: `24`
- Target SDK: `36`
- File: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 177,137,788 bytes
- SHA-256:
  `E690A875EC69A2AAAAF8A16A4E000ED8F19F40156B00C04098A9FEC4F840D185`
- Distribution status: Development-only debug artifact; excluded from source
  control

The APK was built from an ASCII temporary workspace and then copied back to the
repository `build` output directory. This avoids the known Windows native-build
failure mode where CMake, Ninja, or Kotlin incremental compilation resolves the
repository's Unicode OneDrive path.

## Local Validation Coverage

- Resolved Flutter dependencies.
- Regenerated localization and Drift outputs.
- Verified generated outputs are stable after repeated generation.
- Verified Dart formatting and static analysis.
- Ran the full Flutter test suite with coverage.
- Re-ran the P4-10 workout resilience tests directly.
- Validated anatomy asset budgets and animation contracts.
- Built the Android debug APK from a clean ASCII workspace copy.
- Verified APK package metadata with `aapt dump badging`.
- Checked Markdown and patch whitespace.
- Scanned changed and untracked repository files for prohibited attribution
  phrases.
- Scanned the repository for secret-like values and signing material.

## Commands

| Command | Result |
| --- | --- |
| `flutter pub get` | Passed |
| `flutter gen-l10n` | Passed |
| `dart run build_runner build` | Passed |
| generated-output hash stability check | Passed |
| `dart format --output=none --set-exit-if-changed lib test` | Passed |
| `dart analyze` | Passed |
| `flutter analyze --no-pub` | Passed |
| `flutter test --coverage` | Passed |
| `flutter test test\app\project_atlas_workout_resilience_test.dart` | Passed |
| `python tool\anatomy\validate_asset_budgets.py --budget tool\anatomy\anatomy_asset_budgets.v1.json --scan-repository .` | Passed |
| `python tool\anatomy\animation\validate_animation_contract.py --rig tool\anatomy\animation\shared_humanoid_rig.v1.json --animations tool\anatomy\animation\core_exercise_animation_prototypes.v1.json --ontology tool\anatomy\muscle_region_ontology.v1.json --expected-exercise-count 10` | Passed |
| `flutter build apk --debug` | Passed |
| `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk` | Passed |
| `git diff --check` | Passed |
| repository attribution scan | Passed |
| repository secret scan | Passed |

## CI Result

The `CI / Quality and Android debug build` workflow passed for the pushed
Phase 4 branch and pull request.

## Build C2 Product Boundary

Build C2 packages the offline workout MVP slice implemented through P4-10:

- manual program publication to a local active program
- Today workout start from a selected training day
- set-level repetitions, load, RIR, and outcome logging
- previous-performance display
- active rest timer and Android background rest notification scheduling while
  the app process is alive
- active-session recovery from local storage after process restart
- calculated set, exercise, and session execution statuses
- workout history, selected set details, and personal-record summaries
- append-only historical corrections
- airplane-mode and file-backed recovery coverage

Explicit session-finish or cancel actions and durable rest-timer replay after
process death remain outside Build C2. The current durability guarantee covers
committed active sessions, completed set slots, actual-log revisions, and
history read models.
