# Architecture

## Document Status

- Status: P7 modern UX redesign planned after P6 review
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
- Profile, onboarding, and settings
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

- Schema version 8 contains profiles, onboarding preferences, weekly
  availability windows, programs, immutable program versions, version-scoped
  training-day snapshots, prescribed sets, workout sessions, session sets,
  append-only actual set logs, and measurement records.
- Foreign keys are enabled on every database open.
- Profile-owned records use cascade deletion. Deleting a program preserves
  workout history by setting the optional session reference to null.
- Stable text identifiers keep records portable across a future synchronization
  boundary.
- Prescriptions and actual performance are separate records. P6-01 stores
  height, weight, torso, and side-specific limb measurements on each
  measurement event for later visual estimation and progress history. P6-02
  adds optional body-fat percentage plus separate body-measurement and
  body-fat method fields without changing training decisions. P6-03 adds a
  schema-free guidance and validation contract for those fields. P6-04 creates
  bounded regional morph target signals from validated measurement records.
  P6-05 maps those normalized signals into target-specific visual ranges before
  renderer consumption. P6-06 labels personalized anatomy output as a visual
  estimate rather than a medical scan. P6-07 derives trained-muscle,
  weekly-volume, and fatigue heatmaps from local workout history and catalog
  muscle mappings without adding schema. P6-08 derives measurement, volume,
  load, repetition, and estimated-strength trends as Progress read models.
  P6-09 derives measurement-history comparisons and copyable CSV/JSON report
  text without adding schema or a restore path. P6-10 adds test-only morph
  boundary and visual regression coverage for the schema-free body estimate
  contracts. P6-11 packages those Phase 6 contracts into Build C4 without
  adding schema, runtime GLB assets, renderer mesh deformation, or release
  signing.
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
- P7-02 extends the component system with compact dashboard cards, status
  chips, progress rings, dense form sections, dense text fields, and motion
  tokens. These are the default building blocks for the P7 dashboard, focused
  route, sheet, and guided-step rebuilds recorded in
  [the modern UX redesign plan](UX_REDESIGN_PLAN.md) and
  [the modern UX quality bar](UX_QUALITY_BAR.md).

## Main Navigation

- GoRouter uses a `StatefulShellRoute.indexedStack` with an independent navigator for each primary destination.
- Canonical roots are `/today`, `/program`, `/anatomy`, `/progress`, and `/settings`.
- The legacy `/` location redirects to `/today`.
- Switching destinations preserves each visited branch in memory.
- Selecting the active destination again returns that branch to its initial location.
- Router, shell, and branch restoration scopes are stable and explicit.
- Destination labels are compiled from the Turkish and English localization catalogs.
- P7 keeps root destinations as dashboards and moves complex tasks into nested
  routes, step flows, or bottom sheets. Root screens must not become long
  vertical menus.
- P7-03 implements the first focused route split:
  `/today/workout`, `/program/builder`, `/program/catalog`,
  `/program/recommendations`, `/program/exercise/:exerciseId`,
  `/anatomy/estimate`, `/progress/history`, `/progress/trends`,
  `/progress/measurements`, `/settings/setup`, `/settings/units`, and
  `/settings/privacy`.
- Existing functional screens remain available under the child routes while
  root branches become compact dashboard entry surfaces.
- Settings evolves into a Profile hub for setup, equipment, availability,
  units, privacy, and export. Existing settings data ownership remains local.

## Modern UX Redesign

P7 is an experience reset over the completed local engine. It may refactor
presentation widgets, GoRouter routes, screen controllers, localized copy, and
non-persisted UI state to make the product compact and easier to use. It must
preserve repository contracts and completed progression, workout, measurement,
and safety rules unless a later checklist item explicitly introduces a schema
or domain change.

The redesign prioritizes:

- action-first root dashboards;
- focused subroutes instead of long forms;
- one-handed active workout logging;
- guided onboarding and program creation;
- visual-first anatomy review;
- compact progress and achievement summaries;
- local streaks and milestones that never override safety or progression
  rules.

P7-02 is presentation-only. It adds reusable widgets and visual tokens without
changing repository contracts, navigation paths, database schema, training
progression rules, measurement rules, or renderer behavior.

P7-03 is navigation-only. It changes route placement and root dashboard
composition without changing persistence, repository contracts, workout
logging, program-builder behavior, catalog data, measurement export, adaptive
programming rules, or renderer behavior.

P7-04 is a focused Settings/Profile setup presentation rebuild. It replaces the
previous long setup page with a six-step wizard for goal, experience,
equipment, availability, measurement preference, and review. Saving the wizard
continues to write only onboarding preferences and weekly availability windows
through the existing repositories. Measurement preference remains non-persisted
UI state in this step, and generated program or missed-session review surfaces
are no longer embedded in the setup route.

P7-05 rebuilds the Today root as a daily coach dashboard. The controller now
adds a display-only coach summary that derives the current local workout
streak and weekly consistency from completed local workout sessions and the
active program's training-day count. The root can start or resume the selected
workout, but it does not change program selection rules, set logging,
progression decisions, recommendation persistence, or the active-workout route.

P7-06 rebuilds the `/today/workout` presentation for active sessions as a
focused set-by-set route. The controller and repositories stay unchanged: the
screen selects the current focus set from the existing session summary, keeps
the just-completed set focused while an in-memory rest timer exists, and renders
other sets as compact status chips instead of editable rows.

P7-07 rebuilds the Program root as a repository-backed hub. The root listens to
profile-owned programs, resolves the active program version, reads training
days and prescriptions, and builds a presentation-only summary of active plan,
training-day cards, and the recommendation inbox. Builder, catalog, and
recommendation review remain child routes; the hub performs no program writes.

## Main Interfaces

- `ExerciseRepository`
- `OnboardingRepository`
- `AvailabilityRepository`
- `ProgramRepository`
- `WorkoutRepository`
- `MeasurementRepository`
- `ProgramGenerator`
- `ScheduleSolver`
- `ProgressionEngine`
- `AnatomyRenderer`
- `ExportService`

Profile, onboarding, availability, program, workout, measurement, and exercise
repository signatures are defined in the foundation. The exercise catalog
implementation begins in Phase 3; service interfaces are defined by their first
consuming features.

## Adaptive Onboarding

- P5-01 adds a profile-scoped onboarding preference boundary before program
  generation begins.
- Settings captures primary goal, training experience, available equipment,
  preferred session length, and preferred training weekdays.
- Preferences are saved through `OnboardingRepository` into local SQLite and
  can be watched by later planning, availability, and recommendation features.
- Saving onboarding creates the local profile when it does not exist yet.
- P5-02 adds a pure domain calibration planner that derives a conservative
  two-to-four-week block from saved onboarding preferences.
- The calibration block caps sessions per week by experience, applies reduced
  week-by-week volume, holds load progression off, and lists exit requirements
  for leaving calibration.
- P5-03 adds a profile-scoped weekly availability boundary with fixed and
  flexible period types, start and end minutes, and weekday ownership.
- Settings initializes availability drafts from onboarding preferred weekdays
  and saves them through `AvailabilityRepository`.
- P7-04 moves the same onboarding and availability inputs into a compact guided
  setup wizard. The wizard saves both preference groups together through the
  existing `OnboardingController` and `AvailabilityController`, keeps
  measurement preference as non-persisted setup UI state, and removes
  calibration, generated-program, and missed-session preview cards from the
  setup route.
- P5-04 adds a deterministic program planner in
  `features/adaptive_programming/domain`. It combines onboarding preferences,
  the conservative calibration block, saved availability windows, and the local
  exercise catalog to produce an editable `ProgramDraft`.
- The planner caps weekly sessions through the calibration session limit,
  constrains exercise count by the shortest selected window and preferred
  session length, spaces selected windows across the week, and filters exercise
  candidates by broad equipment capability.
- Applying a planner result replaces only the in-memory local Program builder
  draft after confirmation when another draft exists. It does not save,
  publish, activate, reschedule missed sessions, or change progression rules.
- P5-05 adds a deterministic missed-session replacement rule in
  `features/adaptive_programming/domain`. It evaluates the generated program
  plan and saved weekly availability to find the earliest spare window that
  keeps goal-specific recovery spacing around the remaining planned sessions.
- The replacement preview is displayed in Settings and remains non-mutating:
  it does not move a session, create a workout, update the active program, or
  apply progression.
- P5-06 adds the first deterministic bounded progression rule in
  `features/adaptive_programming/domain`. It takes an explicit increase, hold,
  or decrease request against a loaded exercise prescription, rounds load
  changes to the available equipment increment, caps increases and decreases by
  configured percentages, and protects a minimum load floor.
- Bounded progression decisions remain local domain proposals. They do not read
  workout history, infer exposure qualification, save recommendations, or mutate
  program versions until later Phase 5 review flows are implemented.
- P5-07 adds a deterministic smallest-load-increase rule in the same domain
  boundary. It evaluates ordered exercise exposure summaries, requires the two
  most recent matching exposures to qualify, and delegates the actual one-step
  increase to the P5-06 bounded progression rule.
- The P5-07 rule consumes value objects only and remains free of repository
  writes, database queries, recommendation persistence, program-version
  mutation, and user-review state.
- P5-08 adds a deterministic performance-miss response rule in the same domain
  boundary. It consumes pre-classified exposure signals, holds after no data,
  non-miss latest evidence, or an isolated miss, and proposes a bounded
  decrease only after the two most recent matching exposures are both
  performance misses.
- The P5-08 rule intentionally does not classify raw workout outcomes. Outcome
  filtering, pain handling, persistence, explanations, and review actions stay
  assigned to later Phase 5 rules.
- P5-09 adds a deterministic progression signal classifier in the same domain
  boundary. It converts raw set outcome and numeric evidence into the
  pre-classified signals consumed by P5-08 while keeping time, equipment, and
  external interruptions out of performance-failure streaks.
- The classifier remains a pure value-object rule. It does not query
  repositories, persist streak state, mutate prescriptions, or implement pain
  safety messaging.
- P5-10 adds a deterministic pain progression guard in the same domain
  boundary. It evaluates raw set outcome evidence for the matching exercise,
  blocks loaded progression when pain is reported, and returns typed safety
  guidance for the presentation layer.
- The guard delegates the unchanged-load result to the P5-06 bounded
  progression rule as a hold decision. It remains a pure value-object rule and
  does not query repositories, persist safety state, mutate prescriptions, or
  create recommendation-review records.
- P5-11 adds a deterministic plateau and deload data gate in the same domain
  boundary. It evaluates classified matching exercise exposures and allows
  future plateau or deload checks only when enough comparable evidence exists
  across a minimum observation span.
- The gate treats target-met and performance-miss signals as comparable data.
  Not-comparable signals such as pain, interruptions, or missing evidence are
  excluded, and a latest not-comparable exposure blocks the future check. The
  gate does not diagnose a plateau, recommend a deload, persist state, mutate
  prescriptions, or create review records.
- P5-12 adds a deterministic recommendation explanation envelope in the same
  domain boundary. It converts existing load-increase, load-decrease, and pain
  progression-stop candidates into typed change summaries, reason codes,
  triggering evidence references, and undo metadata.
- Explanation objects remain presentation-ready value objects. They do not
  localize copy, apply changes, restore previous prescriptions, persist
  recommendation state, or implement accept, reject, edit, and undo flows.
- P5-13 adds a deterministic recommendation review flow in the same domain
  boundary. It opens an explained recommendation candidate, supports accept,
  reject, load edit, and undo actions, and returns copied prescription state for
  the review surface.
- Accepted load recommendations apply the proposed or edited load to a copied
  prescription. Rejected recommendations keep the original prescription. Undo
  restores the previous load only after an accepted load change. Pain
  progression-stop reviews can be accepted without mutating prescription load.
- The review flow remains a pure value-object state machine. It does not write
  recommendation rows, publish program versions, mutate repositories, localize
  UI copy, or perform cross-exercise batch updates.
- P5-14 adds golden-persona simulation tests over the Phase 5 domain rules.
  The simulations run synthetic twelve-week histories through progression
  qualification, miss response, interruption filtering, pain guarding,
  explanation, review, and data-gate logic.
- The simulation suite is test-only. It does not add runtime engines,
  repositories, persistence, UI routes, build artifacts, or personal training
  data fixtures.
- P5-15 produces Build C3, a development-only Android debug APK for the
  adaptive-programming beta slice. The build packages P5-01 through P5-14:
  onboarding preferences, calibration, weekly availability, generated program
  drafts, missed-session replacement previews, bounded progression rules,
  recommendation explanation and review value objects, and golden-persona
  acceptance coverage.
- Build C3 does not add a new schema, persistence boundary, runtime service,
  release signing setup, or recommendation-publication workflow. P5-16 owns
  branch publication, pull request creation, and CI verification.

## Exercise Catalog Identity and Categories

- P3-01 defines the first 120 foundational exercise identities in
  [the exercise catalog plan](EXERCISE_CATALOG.md).
- The canonical inventory file stores immutable `snake_case` IDs and Turkish
  and English display names.
- P3-01 planning groups remain internal coverage buckets and are not used as
  product-facing filters.
- P3-02 adds a separate versioned category contract with movement-pattern
  categories, broad muscle-region categories, and one assignment per exercise.
- Muscle-region categories reference P2 semantic muscle group IDs and stay
  broader than the later primary, secondary, and stabilizer activation maps.
- P3-03 adds a separate versioned filter contract with equipment, level,
  laterality, and exercise-type filter vocabularies plus one assignment per
  exercise.
- P3-04 adds a separate versioned content contract with localized setup,
  execution, form-cue, common-error, substitution, and regression data for every
  foundational exercise.
- P3-05 adds a separate versioned muscle mapping contract with side-qualified
  P2 semantic `primary_region_ids`, `secondary_region_ids`, and
  `stabilizer_region_ids` for every foundational exercise.
- P3-06 bundles the P3 JSON contracts and P2 muscle ontology as local metadata,
  composes them through `lib/features/exercise_catalog`, and exposes a
  Riverpod-backed read-only catalog model to the Program branch.
- The Program branch root displays catalog search, filter chips, and exercise
  cards. Exercise detail is a nested GoRouter route at
  `/program/exercise/:exerciseId`.
- Catalog search and filters run fully on-device against immutable local
  metadata; no network or account state is required.
- P3-10 adds a separate versioned media contract with one procedural thumbnail
  binding for every foundational exercise and 30 animation bindings for
  compound or bodyweight-compound exercises.
- The catalog loader validates the media contract against the P3-10 compound
  animation contract before exposing animation badges to the UI.
- Catalog list cards and detail screens render thumbnails through a local
  Flutter painter. Exercises with available source-level animations display an
  animation badge.
- P7-09 keeps the catalog data model and bundled metadata immutable while
  rebuilding the presentation around compact search, a filter sheet, active
  filter chips, media-led result cards, muscle chips, substitution chips, and
  direct add-to-program actions.
- Add-to-program from catalog or detail writes only to the existing in-memory
  `ProgramBuilderController`; if no editable draft exists, the action creates a
  local draft with the existing default program and day names before adding the
  exercise to the selected day.
- P3-11 verifies catalog loading, search, thumbnail display, and animation-badge
  display while Dart network client creation is blocked.
- P3-12 records the Phase 3 branch publication, pull request, local validation,
  Android debug build, and CI verification.
- No third-party image files, motion-capture data, Blender files, FBX files,
  GLB files, or runtime animation binaries are bundled in P3-10.
- Final 120-exercise runtime animation exports, artist review, and
  equipment-contact review remain deferred to Phase 7.

## Manual Program Builder

- P3-07 introduces an in-memory local program draft controller in
  `lib/features/program`.
- The Program branch root is a two-tab workspace: Builder for manual program
  composition and Catalog for the read-only P3-06 exercise browser.
- The builder state tracks a draft name, ordered training days, the selected
  training day, and ordered exercise prescriptions per day.
- Training days can be added, selected, renamed, and deleted while keeping a
  valid selected day.
- Exercises are selected from the same local catalog model used by the catalog
  browser, then ordered inside the selected day.
- P3-08 adds local prescription fields to each exercise: set count, fixed or
  ranged repetitions, optional target RIR, optional load, and rest duration.
- Fixed repetitions use equal minimum and maximum values. Ranged repetitions
  keep separate minimum and maximum values. RIR remains independently optional.
- Load is held internally in kilograms and displayed through the existing unit
  system. Rest is held in seconds.
- P3-09 persists the current builder state through a local snapshot service.
  Saving a draft creates a new draft version; publishing creates a new active
  immutable version and retires earlier active versions for the same program.
- Training-day names are stored as version-scoped snapshots, so later day
  renames do not rewrite historical prescriptions.
- Copying clears persisted identity and returns the program to a local draft.
  Archiving updates only the stable program lifecycle and leaves version
  content immutable.
- Snapshot writes go through the repository layer and insert the program,
  version, training days, and prescribed sets transactionally.
- P3-11 verifies manual draft creation and catalog exercise selection while
  Dart network client creation is blocked.
- P7-08 keeps the same in-memory draft controller and repository contracts while
  rebuilding the builder presentation as a guided five-step flow: setup,
  training days, catalog search and ordering, prescription target review, and
  publish review.
- The publish action now passes through a presentation-layer confirmation dialog
  before calling the existing immutable-version persistence path.

## Active Workout Entry

- P4-01 replaces the Today placeholder with a local active-workout entry point.
- The Today screen reads the local profile's active program and active immutable
  version through repository providers.
- Until the later scheduling engine exists, the user explicitly selects one
  training day from the active version.
- Starting a workout creates one `inProgress` workout session and one planned
  `session_sets` row for each prescribed set in the selected training day.
- The session keeps optional links to the source program and program version;
  every session set keeps its optional prescribed-set link while retaining the
  exercise ID and set ordering needed for history.
- P4-02 records set-level actual repetitions, load, optional RIR, and set
  completion through the repository layer. The write updates the session-set
  status and appends the first actual-set log in one local transaction.
- P4-03 reads previous set performance for the same exercise from local workout
  history, excludes the active session, chooses the latest revision per
  historical set, orders previous exposure by session time, and displays the
  matching set-order result beside the current prescription.
- P4-04 adds a set outcome selector for strength limitation, technique
  limitation, pain, time limitation, equipment limitation, and external
  interruption. The selected outcome is stored on the appended actual-set log
  and is shown in logged and previous-performance summaries.
- P4-05 starts an in-memory rest timer from the completed set's prescribed rest
  duration, displays the countdown in the active workout card, and schedules a
  native Android background notification through the
  `project_atlas/rest_notifications` method channel while the app process is
  alive. Android 13+ notification permission is requested only from an active
  workout path after a program exists.
- P4-05 adds quick load step controls beside the active set load input. The
  controls adjust the current actual-load entry only; prescriptions and
  historical records remain unchanged until the set is explicitly completed.
- P4-06 restores any existing `inProgress` workout session when the Today
  controller starts. It rebuilds set summaries, latest actual logs, previous
  performance context, and the source training-day selection from local tables.
- Restored sessions are marked in presentation state so the Today screen can
  show a local-restore message. Actual-set log identifiers no longer depend on
  a process-local serial alone, avoiding duplicate IDs when a restarted
  controller logs another set with the same clock value.
- P4-07 adds a presentation/application read model for set, exercise, and
  session execution status. Persisted workout lifecycle remains separate from
  calculated execution status: set status compares the latest actual log to
  the prescription and outcome, exercise status aggregates its set statuses,
  and session status aggregates exercise statuses without automatically failing
  the whole workout for one exercise issue.
- P4-08 adds the Progress branch workout-history read model. It composes local
  workout sessions, session sets, linked prescriptions, and append-only actual
  log revisions into chronological session cards, selected set details, and
  exercise-level personal-record cards. Personal records are display-only and
  are derived from the latest clean actual log for each set; logs with limiting
  outcomes are excluded from record calculation.
- P4-09 adds a Progress-branch correction flow for historical set results. A
  correction validates the replacement repetitions, load, RIR, and outcome,
  appends the next `actual_set_logs` revision, links it to the previous latest
  log with `supersedes_log_id`, and refreshes history without updating or
  deleting older logs.
- P4-10 adds Phase 4 resilience acceptance coverage. Widget tests block Dart
  network client creation while starting a workout, logging a set, reviewing
  history, and appending a correction. File-backed recovery tests close and
  reopen the database around an active session and a corrected historical log
  to prove latest-revision read models recover without data loss.
- P4-11 produces Build C2, a development-only Android debug APK for the
  offline workout MVP slice. The build packages manual program publication,
  Today session start, set logging, outcomes, active rest timers, active
  session recovery, calculated statuses, Progress history, personal records,
  append-only corrections, and the P4-10 offline/recovery test coverage.
- Explicit session-finish or cancel actions and durable rest-timer replay after
  process death remain outside Build C2. The current recovery boundary is the
  local durability of active sessions, completed sets, actual-log revisions,
  and latest-revision history read models. P4-12 owns branch publication and CI
  verification.
- P7-05 moves the Today root from a route-entry card to a daily coach
  dashboard. It keeps the P4 active-workout implementation under
  `/today/workout`, adds root-level quick start or resume, and derives local
  streak and weekly consistency without writing analytics rows or altering
  progression logic.
- P7-06 changes the `/today/workout` active-session layout from a full program
  and all-sets view into a current-set execution surface. Program selection,
  day planning, and the start button are hidden while a session is in progress;
  one set logger remains editable, rest state is shown above it, and the rest
  of the session is summarized as status chips.
- P7-07 changes the Program root from route-only cards into a read-only active
  plan hub. It derives active plan, day, exercise, and set counts from the
  existing `ProgramRepository`; training-day cards route to the builder instead
  of embedding inline editing, and the recommendation inbox remains a
  schema-free clear state until durable recommendation persistence exists.

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
- P3-10 extends the same rig contract with 30 compound exercise source-level
  animation records and binds them to catalog media metadata.

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
- Bounded body-measurement morph signals are recorded in
  [body morph targets](BODY_MORPH_TARGETS.md).
- Morph visual range clamps are recorded in
  [body morph visual ranges](BODY_MORPH_VISUAL_RANGES.md).
- Morph boundary and visual regression coverage is recorded in
  [morph boundary and visual regression tests](MORPH_BOUNDARY_VISUAL_REGRESSION.md).
- Personalized anatomy disclosure rules are recorded in
  [body visual estimate label](BODY_VISUAL_ESTIMATE_LABEL.md).
- Training-derived anatomy heatmaps are recorded in
  [anatomy training heatmaps](ANATOMY_TRAINING_HEATMAPS.md).
- Progress trend rules are recorded in
  [progress trends](PROGRESS_TRENDS.md).
- Build C4 local validation is recorded in
  [the Phase 6 validation record](PHASE_6_VALIDATION.md).

## Local-First Repository Flow

- Presentation and application layers depend on repository interfaces rather
  than Drift types.
- Repository writes commit to SQLite first; Drift watch streams then publish the
  resulting local state.
- Aggregate writes use transactions so a program version or session plan cannot
  become partially visible.
- Onboarding preference writes are profile-scoped, replace the one local
  preference row for that profile, and stay available without connectivity.
- Availability window writes are profile-scoped and replace the local recurring
  weekly windows for that profile.
- Actual set corrections append revisions instead of replacing earlier results.
- P6-01 measurement writes store nullable normalized body measurements in
  kilograms and centimeters while preserving existing measurement records.
- P6-02 measurement writes can also store nullable body-fat percentage and
  method metadata while preserving existing measurement records.
- P6-03 measurement writes run blocking data-quality validation before SQLite
  insertion. Warning-level guidance remains available to the presentation layer
  without blocking persistence.
- P6-04 reads measurement records into schema-free morph target signals. P6-05
  clamps those signals into schema-free visual multipliers. Neither path writes
  morph rows, mutates renderer state, or stores derived visual state. P6-06 adds
  a schema-free label and visible disclosure that the result is only a visual
  estimate. P6-07 adds a schema-free heatmap read model over completed workout
  set logs and bundled muscle mappings, then applies normalized scores to the
  renderer controller only when the user selects a heatmap mode. P6-08 adds a
  schema-free Progress trend read model over measurements and completed clean
  workout logs without storing derived analytics. P6-09 adds schema-free
  measurement-history comparison and explicit CSV/JSON report-copy actions that
  do not write files or create restore behavior. P6-10 adds no runtime data
  flow; it extends tests around morph boundaries, visual range interpolation,
  deterministic clamped snapshots, and disclosure layout anchors. P6-11 adds
  no runtime data flow; it packages the validated Phase 6 slice into a
  development-only Android debug APK.
- Riverpod provides interface-typed repositories from one lifecycle-managed
  database instance.
- Detailed contracts and ownership rules are recorded in
  [the local-first data flow](LOCAL_DATA_FLOW.md).
- Measurement reference points and validation rules are recorded in
  [measurement guidance and validation](MEASUREMENT_GUIDANCE.md).
- Measurement-history comparison and report-copy rules are recorded in
  [measurement history comparison and export](MEASUREMENT_HISTORY_EXPORT.md).

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
- Detailed controls and the P8-10 implementation contract are recorded in
  [backup and encrypted export security](SECURITY_AND_EXPORT.md).
