# Database Reliability

## Migration Policy

Every persisted schema change increments `schemaVersion` and adds an explicit
upgrade path. Migrations preserve existing user records, add required indexes,
and leave foreign key enforcement enabled when the database opens.

The migration test suite covers supported schema origins:

- Version 1, which contains no application tables
- Version 2, which contains profiles, programs, workout sessions, session sets,
  and measurement history
- Version 3, which predates immutable training-day snapshots
- Version 4, which predates onboarding preferences
- Version 5, which predates weekly availability windows

Each path is opened through the production migration strategy and compared with
a newly created current database. The comparison covers tables, columns,
defaults, primary keys, foreign keys, unique indexes, and query indexes. SQLite
foreign key and integrity checks must also pass after migration. Synthetic
legacy records verify that upgrades retain existing data.

## Process Recovery

SQLite transaction commit is the durability boundary. A committed in-progress
workout, its completed set slots, and actual set logs must survive database
closure and reopening. Changes in a transaction that never commits must be
rolled back by SQLite when the connection ends.

The recovery test exercises both outcomes on a file-backed database:

1. Save an in-progress session, completed set, and actual result.
2. Close and reopen the database and verify all committed state.
3. Start a transaction that changes the set and adds another result.
4. End the connection without committing.
5. Reopen and verify the committed state is restored with no partial result.

Phase 4 adds application-level recovery coverage on top of the database
transaction tests. The workout recovery test starts an in-progress session,
logs a completed set, closes and reopens the database, verifies Today restores
the active session and latest log, appends a Progress correction, closes and
reopens again, and verifies both the superseded and latest actual-log revisions
remain available.

## Change Requirements

- Never reuse an existing schema version for a changed table definition.
- Add the new origin-to-current migration case before accepting a schema change.
- Compare a migrated database with a clean current database, including indexes.
- Preserve committed workout history; destructive migrations require an
  explicit product decision and tested data transformation.
- Keep fixtures synthetic and free of personal health or training data.
