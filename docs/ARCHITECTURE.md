# Architecture

## Document Status

- Status: Foundation dependencies configured
- Architecture style: Offline-first, layered, and feature-oriented

## Technology Baseline

- Application UI and shared domain: Flutter and Dart
- State and dependency management: Riverpod
- Navigation: GoRouter
- Local relational storage: Drift over SQLite
- Android anatomy renderer: Kotlin and Filament
- iOS anatomy renderer: Swift and Filament when iOS work begins
- Runtime 3D format: GLB/glTF
- Source asset processing: Blender-based pipeline

## Foundation Dependency Baseline

| Capability | Package | Constraint |
| --- | --- | --- |
| State and dependency management | `flutter_riverpod` | `^3.3.2` |
| Routing | `go_router` | `^17.3.0` |
| Relational persistence | `drift` | `^2.34.1` |
| Flutter database connection | `drift_flutter` | `^0.3.0` |
| Platform localization delegates | `flutter_localizations` | Flutter SDK |
| Locale-aware number formatting | `intl` | `^0.20.2` |
| Code generation | `build_runner` | `^2.15.0` |
| Database generator | `drift_dev` | `^2.34.0` |

`sqlparser` is pinned to `0.44.5` as a development-only compatibility
constraint. The newer transitive release does not compile with the latest
`drift_dev` version currently resolvable by Flutter 3.44.4. Remove this pin only
after the generator, analysis, and database tests pass without it.

## Layers

### Presentation

Screens, reusable components, navigation, localization, accessibility, and view state.

### Application

Use cases that coordinate repositories, training rules, scheduling, notifications, and user actions.

### Domain

Platform-independent models and deterministic rules for programs, sessions, progression, availability, and measurements.

### Data

Drift tables, data access objects, repository implementations, migrations, export, and future synchronization boundaries.

### Platform

3D rendering, notifications, calendar insertion, secure key storage, and other operating-system integrations.

## Core Modules

- App shell and navigation
- Design system and localization
- Profile and settings
- Exercise catalog
- Program builder
- Active workout and history
- Scheduling and progression engine
- Measurements and progress
- Anatomy renderer and asset bridge
- Export and restore

## Foundation Layout

- `lib/app`: Application shell and declarative router
- `lib/core/database`: Drift database connection and providers
- `lib/features`: Feature-oriented presentation and domain code
- `test/app`: Application and routing widget tests
- `test/core`: Platform-independent infrastructure tests

## Data Principles

- The local database is the source of truth for the personal release.
- Completed workout records remain append-only; corrections create revisions.
- Program changes create immutable program versions.
- Prescribed and actual set values are stored separately.
- Domain identifiers remain stable and synchronization-ready.
- Sensitive user data never enters source control or bundled sample data.

## Localization and Units

- English is the template locale and Turkish is the second required locale.
- UI messages are stored in ARB files and compiled with Flutter `gen_l10n`.
- Locale overrides are provided through Riverpod; a null override follows the device locale.
- Mass is stored internally in kilograms and length in centimeters.
- Pounds and inches are converted only at input and presentation boundaries.
- Conversion factors are exact constants; display rounding never changes stored values.

## Main Interfaces

- `ExerciseRepository`
- `ProgramRepository`
- `WorkoutRepository`
- `MeasurementRepository`
- `ProgramGenerator`
- `ScheduleSolver`
- `ProgressionEngine`
- `AnatomyRenderer`
- `ExportService`

Exact Dart signatures will be defined with the first consuming feature.

## Cross-Platform Boundary

Shared code owns domain decisions and screen behavior. Platform adapters own 3D surfaces and operating-system APIs. Typed messages cross the boundary; platform code does not decide training rules.

## Quality Constraints

- Every push and pull request must pass generated-source verification,
  formatting, static analysis, tests with coverage, and an Android debug build.
- CI runs with read-only repository permissions and publishes only coverage and
  a non-release debug APK as short-lived artifacts.
- Core workflows function in airplane mode.
- An interrupted workout can be restored without losing completed sets.
- Database migrations are tested before release.
- Anatomy rendering has measured file-size, frame-rate, and memory budgets.
- Accessibility and localization are part of feature acceptance, not a final retrofit.

## Security Boundary

- No secrets or signing material in the repository.
- No real personal data in fixtures or screenshots.
- Raw application data is excluded from uncontrolled backup paths.
- Export files require an explicit user action and an encryption design before release.
