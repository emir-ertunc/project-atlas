# Architecture

## Document Status

- Status: Current Phase 1 implementation validated; accessibility and dedicated prescription acceptance remain open
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
- `lib/core/design_system`: Semantic colors, typography, spacing, component tokens, and application themes
- `lib/core/database`: Drift database connection and providers
- `lib/core/repositories`: Platform-independent records and contracts with Drift-backed local implementations
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

## Core Relational Schema

- Schema version 3 contains profiles, programs, immutable program versions,
  prescribed sets, workout sessions, session sets, append-only actual set logs,
  and measurement records.
- Foreign keys are enabled on every database open.
- Profile-owned records use cascade deletion. Deleting a program preserves
  workout history by setting the optional session reference to null.
- Stable text identifiers keep records portable across a future synchronization
  boundary.
- Prescriptions and actual performance are separate records. Detailed body
  measurement fields remain a Phase 6 extension.
- Table definitions, constraints, indexes, and extension boundaries are recorded
  in [the core data model](DATA_MODEL.md).

## Localization and Units

- English is the template locale and Turkish is the second required locale.
- UI messages are stored in ARB files and compiled with Flutter `gen_l10n`.
- Locale overrides are provided through Riverpod; a null override follows the device locale.
- Mass is stored internally in kilograms and length in centimeters.
- Pounds and inches are converted only at input and presentation boundaries.
- Conversion factors are exact constants; display rounding never changes stored values.

## Design System

- Light and dark themes share explicit semantic `ColorScheme` roles.
- Success, warning, and information roles use a typed theme extension.
- Feature code consumes semantic theme roles instead of raw colors.
- Typography uses the platform system font and a documented role scale.
- Layout uses a four-logical-pixel spacing scale and 48-pixel minimum controls.
- Normal-size text color pairs are protected by automated 4.5:1 contrast tests.

## Main Navigation

- GoRouter uses a `StatefulShellRoute.indexedStack` with an independent navigator for each primary destination.
- Canonical roots are `/today`, `/program`, `/anatomy`, `/progress`, and `/settings`.
- The legacy `/` location redirects to `/today`.
- Switching destinations preserves each visited branch in memory.
- Selecting the active destination again returns that branch to its initial location.
- Router, shell, and branch restoration scopes are stable and explicit.
- Destination labels are compiled from the Turkish and English localization catalogs.

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

Profile, program, workout, measurement, and exercise repository signatures are
defined in the foundation. The exercise catalog implementation begins in Phase
2; service interfaces are defined by their first consuming features.

## Anatomy Muscle Ontology

- Fifty-six unilateral muscle regions use stable lowercase ASCII identifiers.
- Semantic identifiers are independent of BodyParts3D FMA/FJ references,
  renderer nodes, display names, and exercise categories.
- English and Turkish names are explicit ontology data rather than identity.
- The source reduction and semantic naming contracts are versioned and linked
  by a pinned hash.
- The complete contract is recorded in
  [the anatomy muscle ontology](ANATOMY_MUSCLE_ONTOLOGY.md).

## Anatomy Asset Pipeline

- Blender 5.1.2 is the validated source-processing toolchain for the P2
  anatomy spike.
- The pipeline reads the external BodyParts3D source archive directly, validates
  source and manifest hashes, and writes cleaned GLB LODs plus a manifest.
- GLB node names and `muscle_region_id` extras are the renderer identity
  contract consumed by P2-05.
- Raw source archives, source OBJ files, and processed GLB files stay outside
  the repository until a later checklist item explicitly bundles reviewed
  assets.
- The complete processing, validation, and license contract is recorded in
  [the anatomy Blender pipeline](ANATOMY_PIPELINE.md).

## Anatomy Rig and Animation Prototype

- The P2 shared rig is a source-level humanoid contract rather than a committed
  runtime binary asset.
- Exercise animation prototypes use bounded high-level controls, stable muscle
  region IDs, equipment anchors, and loopable keyframes.
- Ten core exercise prototypes cover squat, hinge, horizontal push, vertical
  push, horizontal pull, vertical pull, single-leg squat, elbow flexion, and
  elbow extension patterns.
- CI validates the rig and animation set against the P2-03 ontology.
- No motion-capture file, Blender file, FBX, or animation GLB is bundled in
  P2-09.
- The complete contract is recorded in
  [the anatomy rig and animation prototype](ANATOMY_ANIMATION_PROTOTYPE.md).

## Anatomy Renderer Bridge

- Android hosts the anatomy view through a registered Flutter platform view
  named `project_atlas/anatomy_renderer`.
- Flutter queries renderer capability metadata through the
  `project_atlas/anatomy_renderer_bridge` method channel.
- Flutter owns drag, pinch, tap, fallback picking, and heatmap preview state
  through a feature controller; Android receives normalized method-channel
  commands for the registered platform-view ID.
- The Android implementation initializes Filament, owns the native
  `SurfaceView`, creates a swapchain from the surface lifecycle, and renders
  through a native Choreographer frame loop.
- The bridge supports bounded orbit camera updates, zoom, semantic region
  selection, normalized picking coordinates, and heatmap scores keyed by stable
  P2-03 muscle IDs.
- The bridge exposes GLB support but does not bundle anatomy GLBs yet; processed
  assets remain external until a later packaging and budget gate. Until then,
  picking and highlighting operate as deterministic semantic previews rather
  than mesh/material operations.
- CI enforces anatomy asset budgets for GLB size, vertex count, triangle count,
  primitive draw-call upper bounds, material count, and required license
  metadata before any runtime GLB can be bundled.
- Non-Android Flutter targets use a safe fallback widget.
- The complete bridge contract is recorded in
  [the Android anatomy renderer bridge](ANATOMY_RENDERER_BRIDGE.md).
- The static asset budget contract is recorded in
  [the anatomy asset budgets](ANATOMY_ASSET_BUDGETS.md).

## Local-First Repository Flow

- Presentation and application layers depend on repository interfaces rather
  than Drift types.
- Repository writes commit to SQLite first; Drift watch streams then publish the
  resulting local state.
- Aggregate writes use transactions so a program version or session plan cannot
  become partially visible.
- Actual set corrections append revisions instead of replacing earlier results.
- Riverpod provides interface-typed repositories from one lifecycle-managed
  database instance.
- Detailed contracts and ownership rules are recorded in
  [the local-first data flow](LOCAL_DATA_FLOW.md).

## Database Migration and Recovery

- Every schema change increments the database version and defines an explicit
  upgrade path.
- Migration tests compare upgraded table, column, foreign key, and index
  metadata with a clean current database and run SQLite integrity checks.
- Synthetic legacy records verify data retention from supported schema origins.
- File-backed recovery tests prove committed in-progress workouts survive a
  restart and uncommitted transaction changes are rolled back.
- Detailed requirements are recorded in
  [database reliability](DATABASE_RELIABILITY.md).

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
- Android disables backup and explicitly excludes every private storage domain
  from legacy cloud backup and modern cloud/device transfer.
- iOS marks the application Documents directory as excluded from device backup
  when the application launches.
- Export is explicit and produces only a versioned Argon2id/AES-256-GCM
  authenticated container; plaintext export is forbidden.
- Restore authenticates before parsing, validates a separate database, and uses
  confirmed atomic replacement with rollback.
- Detailed controls and the P7-10 implementation contract are recorded in
  [backup and encrypted export security](SECURITY_AND_EXPORT.md).
