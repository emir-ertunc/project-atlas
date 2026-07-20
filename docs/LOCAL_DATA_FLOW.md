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
workout session plans, set logs, history reads, and history corrections remain
local SQLite operations.

## Future Synchronization Boundary

Repository records use stable client-generated identifiers and contain no
Drift-specific types. A future synchronization layer can observe or decorate
the same contracts, but it must not bypass local commits or make core workflows
depend on connectivity.
