# Phase 1 Validation

## Result

- Date: 2026-07-07
- Scope: Current Phase 1 working tree through P1-09
- Result: Local quality, database, security-policy, Android build, and emulator
  smoke gates passed
- Remaining Phase 1 checklist items: P1-03 and P1-05
- Publication gate: P1-10 was not started

P1-09 validates the implementation currently present in the working tree. It
does not mark the two remaining feature checklist items complete and does not
authorize commit, push, or pull-request publication.

## Toolchain

- Windows 11
- Flutter 3.44.4 stable
- Dart 3.12.2
- OpenJDK 21.0.10
- Android SDK Platform 36
- Android emulator: ProjectAtlas API 35, x86_64
- Git for Windows 2.55.0

## Quality Gates

| Gate | Result | Evidence |
| --- | --- | --- |
| Dependency resolution | Passed | `flutter pub get` completed with the committed constraints |
| Localization generation | Passed | Generated localization hashes remained unchanged |
| Drift generation | Passed | Verification run wrote zero outputs |
| Dart formatting | Passed | 45 files checked, zero changes |
| Static analysis | Passed | No issues found |
| Automated tests | Passed | 37 tests |
| Android debug build | Passed | Gradle `assembleDebug` completed |
| Android install and launch | Passed | API 35 emulator, foreground activity and live process verified |
| Runtime navigation smoke | Passed | Today, Program, Anatomy, Progress, and Settings selected successfully |
| Runtime error scan | Passed | No application fatal exception or ANR found |
| Repository safety scans | Passed | No secret, private-data, signing-key, or prohibited attribution match |

## Coverage

The raw LCOV report contains generated Drift code and reports 1,492 of 4,613
lines, or 32.34%. Excluding generated Dart sources reports 477 of 705 lines, or
67.66%. Excluding generated sources and declarative Drift table definitions
reports 461 of 576 hand-written executable lines, or 80.03%.

Coverage is currently published as a CI artifact. A filtered enforcement script
and per-module thresholds have not yet been accepted, so the percentages are
recorded as measurements rather than an integration gate.

## Database and Recovery

- Fresh schema creation and foreign key enforcement passed.
- Version 1 and version 2 migration paths matched clean schema version 3
  metadata.
- Synthetic legacy records survived migration.
- SQLite foreign key and integrity checks passed after migration.
- Committed in-progress workout state survived reopen.
- An interrupted uncommitted transaction was rolled back without a partial set
  log.
- Program version and session-plan aggregate writes were transactionally
  atomic.

## Backup and Export Security

- The packaged Android manifest contains `allowBackup=false` and references both
  legacy and Android 12+ extraction rules.
- Cloud and device-transfer rules exclude all supported private data domains.
- The iOS source marks the application Documents directory as excluded from
  backup at launch.
- The encrypted export format and authenticated restore design are recorded in
  [backup and encrypted export security](SECURITY_AND_EXPORT.md).

An iOS build and a physical iOS backup/restore test remain deferred until iOS
development begins.

## Android Artifact

- Package: `app.projectatlas.personal`
- Version: `0.1.0+1`
- File: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 179,867,140 bytes
- SHA-256: `A67DA44D1D638EA1465A4BBF200C20CA8CF753E91A1B72D2B13E667C5B8D071E`
- Distribution status: Development-only; excluded from source control

The first debug launch command exceeded its wait window during Flutter debug
startup, but the application subsequently became the top resumed activity,
retained a live process, rendered the Today screen, and completed all five
navigation checks. This is a functional smoke result, not a startup-performance
measurement.

## Open Gates

- P1-03: Complete behavioral accessibility foundations and their acceptance
  tests.
- P1-05: Complete the dedicated acceptance review for program versions,
  prescribed sets, and actual set logs.
- Physical Android hardware is not currently connected; the API 35 emulator is
  the local runtime target for this record.
