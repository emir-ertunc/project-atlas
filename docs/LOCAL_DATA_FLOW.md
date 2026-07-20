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

Actual set results use insert-only repository operations. Corrections append a
new revision that may reference the previous log; they do not overwrite the
prescription or an earlier result.

## Provider Ownership

Riverpod owns the application database and exposes each implementation through
its interface type. Tests can replace the database provider with an isolated
in-memory database without changing repository consumers.

## Offline Acceptance

Airplane-mode acceptance is verified at the application boundary by blocking
Dart `HttpClient` creation during catalog and manual program-builder widget
flows. Catalog data is read from bundled local asset paths, and builder draft
creation remains local until an explicit save or publish action persists a
version snapshot through the repository layer.

## Future Synchronization Boundary

Repository records use stable client-generated identifiers and contain no
Drift-specific types. A future synchronization layer can observe or decorate
the same contracts, but it must not bypass local commits or make core workflows
depend on connectivity.
