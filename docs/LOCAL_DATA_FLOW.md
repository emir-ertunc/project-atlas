# Local-First Data Flow

## Source of Truth

The Drift database is the only source of truth for the personal release. A
write completes locally before the application reports success, and repository
watch streams emit the resulting database state. No network connection or
remote fallback participates in this path.

## Repository Boundary

Application and presentation code depend on repository interfaces and
platform-independent records. Drift rows, companions, queries, and database
enums remain inside the local repository implementations.

The foundation provides these contracts:

- `ProfileRepository` for profile preferences
- `OnboardingRepository` for profile-scoped adaptive onboarding preferences
- `AvailabilityRepository` for recurring weekly fixed and flexible windows
- `ProgramRepository` for programs, immutable versions, and prescriptions
- `WorkoutRepository` for session plans and append-only actual set logs
- `MeasurementRepository` for measurement history
- `ExerciseRepository` for the exercise catalog boundary

The exercise catalog is bundled as local read-only JSON metadata. P3-11 verifies
the catalog asset paths, catalog browsing, and manual builder exercise selection
with Dart network client creation blocked. All other foundation contracts have
Drift-backed implementations and Riverpod providers.

## Read and Write Path

```text
Presentation / application use case
  -> repository interface
  -> Drift repository
  -> local SQLite transaction
  -> Drift watch stream
  -> updated presentation state
```

Program versions and their prescribed sets are inserted in one transaction.
Workout sessions and their ordered set slots are also saved in one transaction.
Invalid child records reject the complete operation, so observers never receive
a partially constructed aggregate.

P5-01 adds `OnboardingRepository` as a profile-scoped local preference boundary.
The Settings screen reads and writes primary goal, training experience,
equipment, preferred session length, and preferred weekdays through an
application controller. Saving onboarding first ensures the local profile
exists, then inserts or replaces the one onboarding preference row for that
profile. These inputs are durable planning facts only; program generation,
availability solving, and progression updates remain later Phase 5 work.

P5-02 adds a pure domain read model over those preferences. The calibration
builder calculates a conservative two-to-four-week block in memory and the
Settings screen displays it after onboarding is saved. No calibration write
path exists yet, so the block cannot mutate programs, sessions, prescriptions,
or progression state.

P5-03 adds `AvailabilityRepository` for recurring weekly availability. The
Settings screen builds availability drafts from saved onboarding weekdays, lets
each period be fixed or flexible, and writes the complete profile set through a
replace operation. The write creates the local profile when needed and commits
the recurring windows to SQLite. It does not solve schedules, move sessions, or
create recommendations.

P5-04 adds an in-memory program planning path. The Settings screen reads saved
onboarding preferences, saved availability windows, and the bundled exercise
catalog, then calls the deterministic planner to build a `ProgramDraft`.
Applying the plan updates only the existing Program builder controller state.
No repository write occurs until the user explicitly saves a draft or publishes
an immutable version from the Program screen.

P5-05 adds a read-only missed-session replacement path. The Settings screen
reuses the generated program preview and saved availability windows, then calls
the deterministic replacement rule to propose one safe spare window. The result
is presentation state only; it does not insert workout sessions, update
availability, save recommendations, or publish a new program version.

P5-06 adds a read-only bounded progression path. A domain rule evaluates an
explicit load increase, hold, or decrease request against the current
prescription and a local equipment increment policy. The result is an in-memory
decision that can be applied to a copied prescription by a later review flow,
but P5-06 does not write recommendations, update program versions, or inspect
workout history.

P5-07 adds a read-only exposure-qualification path. A domain rule evaluates
exercise exposure summaries supplied by a future application read model and
returns a smallest-load-increase candidate only when the two most recent
matching exposures qualify. The result is still in memory and does not write a
recommendation row, update `prescribed_sets`, publish a program version, or
change workout history.

P5-08 adds a read-only performance-miss response path. A domain rule evaluates
pre-classified exposure signals supplied by a future application read model and
returns either hold, not-comparable, or a bounded decrease candidate. The result
is in memory only and does not write a recommendation row, update
`prescribed_sets`, publish a program version, or change workout history.

P5-09 adds a read-only progression signal classification path. A domain rule
evaluates raw exposure evidence supplied by a future application read model and
returns the pre-classified signal consumed by P5-08. Time, equipment, and
external interruptions become not-comparable signals rather than persisted
failure streaks. The result is in memory only and does not write a
recommendation row, update `prescribed_sets`, publish a program version, or
change workout history.

P5-10 adds a read-only pain progression guard path. A domain rule evaluates
raw exposure evidence supplied by a future application read model and returns
an in-memory hold decision plus typed safety guidance when a matching exercise
contains a pain outcome. The result does not write a recommendation row, update
`prescribed_sets`, publish a program version, persist safety state, or change
workout history.

P5-11 adds a read-only plateau and deload data gate path. A domain rule
evaluates classified matching exercise exposures supplied by a future
application read model and returns an in-memory eligibility decision based on
comparable exposure count, observation span, and the latest matching signal.
The result does not write a recommendation row, update `prescribed_sets`,
publish a program version, persist gate state, or change workout history.

P5-12 adds a read-only recommendation explanation path. A domain rule consumes
existing in-memory recommendation candidates and returns typed change summaries,
reason codes, triggering evidence references, and undo metadata for a later
review flow. The result does not write a recommendation row, update
`prescribed_sets`, publish a program version, restore previous values, or
change workout history.

P5-13 adds a read-only recommendation review path. A domain state machine
opens explained recommendation candidates and returns copied prescription state
after accept, reject, edit, or undo actions. The result does not write a
recommendation row, update `prescribed_sets`, publish a program version, or
change workout history.

P5-14 adds test-only twelve-week simulation coverage. The tests compose
in-memory exposure evidence, recommendation candidates, explanations, review
state, and copied prescriptions without touching repositories. The simulations
do not write recommendation rows, update `prescribed_sets`, publish program
versions, persist fixtures, or change workout history.

P5-15 adds no new data flow. Build C3 packages the existing local onboarding,
availability, program-planning, missed-session preview, and adaptive rule
paths into a development-only Android debug APK. It does not add a
recommendation write path, mutate active program versions, or introduce network
or account dependencies.

P6-01 extends the existing `MeasurementRepository` write path. A measurement
event can now carry nullable height, weight, torso, and side-specific limb
values in addition to timestamp, source, notes, and profile ownership. Values
are validated at the repository boundary as positive finite numbers and are
stored locally in kilograms and centimeters. Existing measurement records
migrate forward with the new fields set to null.

P6-02 extends the same measurement write path with optional body-fat percentage,
body-measurement method, and body-fat measurement method. Body-fat percentage is
validated as greater than 0 and less than 100 when present. Method fields are
stored as local enum metadata and are not used to mutate training prescriptions.
Existing measurement records migrate forward with the new fields set to null.

P6-03 adds a schema-free measurement guidance and validation boundary before
the same repository write. Blocking validation rejects new measurement events
with no numeric value, non-finite values, non-positive length or mass values, or
body-fat percentage outside the open 0-100 range. Warning-level issues, such as
missing method metadata, broad reference-range checks, or left/right side
differences, are returned by the domain validator for later presentation review
but do not block persistence.

P6-04 adds a read-only morph target derivation path. A loaded
`MeasurementRecord` is converted in memory into bounded regional morph signals
keyed by stable target definitions and P2 anatomy region IDs. This path reuses
measurement validation, produces no targets when blocking validation fails, and
does not insert morph rows, update measurement history, or mutate renderer
state. P6-05 adds a second read-only step that maps the normalized targets into
target-specific visual ranges and records missing range definitions instead of
fabricating fallback deformations.

P6-06 adds a presentation-facing label around that in-memory clamped result. It
preserves blocking validation and missing range status, displays a
visual-estimate disclosure on the anatomy screen, and does not write derived
state, update measurement history, or mutate renderer state.

P6-07 adds a read-only training heatmap path. The Anatomy screen reads the
local exercise catalog and completed workout set evidence through repository
providers, selects the latest actual-log revision per completed set, and builds
trained-muscle, weekly-volume, and fatigue maps in memory for the trailing
seven-day window. Applying a heatmap updates only the renderer controller's
transient heatmap state; it does not write workout history, measurement
history, prescriptions, recommendations, or derived analytics rows.

P6-08 adds a read-only Progress trend path. The Progress read model now reads a
snapshot of local measurement history plus workout sessions, completed set
slots, linked prescriptions, and latest actual-log revisions. It derives
measurement, volume, load, repetition, and estimated-strength trends in memory.
Trend rendering updates only presentation state and does not write
measurements, workouts, prescriptions, recommendations, exports, or derived
analytics rows.

P6-09 adds a read-only measurement-history comparison and report-copy path. The
Progress read model reuses the local measurement snapshot, compares first and
latest usable field values, derives latest left/right circumference differences,
and generates CSV/JSON text only when the user taps an explicit copy action.
The feature writes no files, creates no restore/import path, omits `profile_id`
from copied text, and does not mutate measurement history or derived analytics
state.

P6-10 adds no new read or write path. It extends automated coverage around the
existing morph target derivation, visual range clamp, and visual-estimate
disclosure contracts.

P6-11 adds no new read or write path. Build C4 packages the existing local
measurement, visual-estimate, heatmap, trend, comparison, and report-copy paths
into a development-only Android debug APK without adding remote services,
stored derived analytics, plaintext file export, or restore behavior.

P4-01 starts an active workout by copying the selected active program version's
training-day prescription into a local session plan. The write creates the
`workout_sessions` row with `inProgress` status and all planned `session_sets`
inside the existing `WorkoutRepository.saveSessionPlan` transaction.

P4-02 completes individual set slots through
`WorkoutRepository.completeSessionSet`. The repository updates exactly one
`session_sets` row to `completed` and inserts the matching `actual_set_logs`
revision in the same transaction, so the UI cannot observe a completed set
without its actual result or a log without the corresponding completion state.

P4-03 derives previous performance from the same local tables through
`WorkoutRepository.getExercisePerformanceHistory`. The read excludes the active
session, filters by profile and exercise ID, selects the latest actual-log
revision for each historical set slot, orders exposure by session time before
log-record time, and lets the application layer match previous results to the
current set order.

P4-04 extends the same set-completion transaction with the optional
`actual_set_logs.outcome` value. The UI can save a numeric actual result with
or without an outcome, or save an outcome-only record when a set is limited by
pain, technique, strength, time, equipment, or an external interruption.

P4-05 keeps rest timers outside the persistent data model. The active workout
screen derives the timer duration from the completed set's prescribed rest
seconds, keeps countdown state in Riverpod, and schedules a best-effort Android
notification through a platform channel. Quick load controls adjust only the
pending input; the repository receives the value only when the user completes
the set.

P4-06 restores an interrupted active workout by rebuilding Today state from
the same local repository reads used by normal startup. A new controller
instance treats an existing `inProgress` session as restored, reloads completed
sets and latest actual logs, and resolves the selected training day from the
session's linked prescription when possible. Volatile rest countdown state is
not replayed by this recovery path.

P4-07 calculates set, exercise, and session execution status after repository
reads complete. The calculation uses only local records already loaded for the
active workout: planned/completed set lifecycle, linked prescription, latest
actual log, and outcome. The repository does not persist these derived
statuses, so future history and correction flows can recalculate them from the
append-only evidence.

P4-08 uses the Progress branch to read local workout history without adding a
write path. The history controller loads sessions for the local profile,
fetches their set slots and latest log revisions, resolves prescriptions from
the linked program version when available, and derives the same execution
statuses used by Today. Personal-record summaries are recalculated from clean
latest logs and exclude pain, interruption, strength, and technique outcome
records so later progression rules can interpret those signals separately.

P4-09 adds the first historical correction write path. The Progress correction
controller accepts corrected repetitions, load, RIR, and outcome for a
completed logged set, validates the same value ranges as active set logging,
and calls the insert-only repository operation with the next revision number.
The new revision references the previous latest log through `supersedesLogId`.
The controller then invalidates the history read model so set details, status,
and personal records resolve from the new latest revision while the revision
history still shows the older evidence.

P4-10 verifies resilience at the application boundary. The workout flow is
tested inside an environment that throws if Dart creates an HTTP client, proving
that session start, set logging, Progress history, and history correction do
not require network access. A separate file-backed recovery test starts a
session, logs a set, closes the database, reopens it, appends a correction,
closes and reopens again, and verifies Today and Progress both resolve the
latest revision while preserving earlier logs.

Actual set results use insert-only repository operations. Corrections append a
new revision that references the previous log; they do not overwrite the
prescription or an earlier result.

## Provider Ownership

Riverpod owns the application database and exposes each implementation through
its interface type. Tests can replace the database provider with an isolated
in-memory database without changing repository consumers.

## Offline Acceptance

Airplane-mode acceptance is verified at the application boundary by blocking
Dart `HttpClient` creation during catalog, manual program-builder, and Phase 4
workout widget flows. Catalog data is read from bundled local asset paths, and
onboarding preferences, availability windows, workout session plans, set logs,
history reads, history corrections, and measurement writes including body-fat
and method metadata remain local SQLite operations.

## Future Synchronization Boundary

Repository records use stable client-generated identifiers and contain no
Drift-specific types. A future synchronization layer can observe or decorate
the same contracts, but it must not bypass local commits or make core workflows
depend on connectivity.
