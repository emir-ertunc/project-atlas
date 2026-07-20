# Core Data Model

## Scope

Schema version 4 establishes the local relational foundation for profiles,
programs, immutable program versions, version-scoped training-day snapshots,
prescribed sets, workout sessions, actual set revisions, and measurement
history. The Drift database is the source of truth for the personal release,
and SQLite foreign key enforcement is enabled whenever the database opens.

Individual body-measurement fields remain Phase 6 extensions. The current
measurement table provides the stable event identity, timestamp, source, and
history relationship needed for those additions.

## Identifier and Time Conventions

- Domain records use client-generated text identifiers of up to 64 characters.
- Exercise references allow stable catalog identifiers of up to 128 characters.
- Drift stores timestamps as SQLite date-time values. Repository boundaries
  normalize instants to UTC before returning domain records.
- Mass values are stored in kilograms. Imperial conversion occurs only at input
  and presentation boundaries.
- Enum values are persisted by their Dart names. Renaming an enum value requires
  an explicit database migration.

## Tables

### `profiles`

Stores the local owner identity and preferences. The unit system is either
`metric` or `imperial`; an optional locale supports the Turkish and English
interface baseline.

### `programs`

Stores the stable identity, name, and lifecycle state of a training program.
Each program belongs to one profile. Program edits that change training content
create a new version rather than rewriting historical prescriptions.

### `program_versions`

Stores numbered draft, active, or retired versions belonging to a program. A
program cannot contain the same version number twice. Repository operations
insert a version and its complete prescription in one transaction and do not
expose an update operation for version content.

### `program_version_training_days`

Stores the ordered training-day names that belong to one immutable program
version. The day order is unique inside a version and is referenced by
`prescribed_sets.training_day_order`, keeping day labels stable even when a
later draft renames or reorders days.

### `prescribed_sets`

Stores one set target within a program version, including training-day,
exercise, and set order; minimum and maximum repetitions; optional target RIR;
optional load in kilograms; rest duration; and progression mode.

Fixed repetitions use equal minimum and maximum values. Ranged repetitions
require the maximum to be at least the minimum. RIR is independently optional
and constrained to 0–10. Set position is unique within a version and training
day.

### `workout_sessions`

Stores planned and historical workout instances. Each session belongs to a
profile and can reference both a program and the exact program version from
which it was created. Deleting program templates clears those optional links
while preserving the session. A completed time range cannot end before it
starts.

### `session_sets`

Stores the ordered set slots belonging to a workout session. A slot can point
to its prescribed set, while retaining its own exercise identity and order.
Deleting a prescription clears that optional link without deleting workout
history. Deleting a session deletes its set slots.

### `actual_set_logs`

Stores append-only actual performance revisions for a session set. A record can
contain repetitions, load, RIR, or a limitation/interruption outcome and may
reference the log it supersedes. Revision numbers are unique within a session
set. The repository exposes insertion only, so corrections append evidence
instead of overwriting an earlier result or its prescription.

P4-02 uses the existing schema for active workout logging. Completing a set
updates the related `session_sets.status` to `completed` and inserts revision
`1` into `actual_set_logs` in the same repository transaction. Later correction
flows add higher revisions instead of mutating this first record.

P4-03 does not add schema. Previous-performance context is a read model over
`workout_sessions`, `session_sets`, and `actual_set_logs`, using the latest log
revision per historical set while excluding the currently active session.

P4-04 also does not add schema. The existing `actual_set_logs.outcome` column
stores the selected strength, technique, pain, time, equipment, or external
interruption outcome. An outcome-only log is valid because the table already
requires at least one actual value or outcome.

P4-05 does not add schema. Rest timers are volatile active-workout UI state
derived from `prescribed_sets.rest_seconds`; quick load controls only edit the
pending actual-load input before the existing completion transaction writes an
`actual_set_logs.load_kilograms` value.

P4-06 does not add schema. Active-session recovery reuses `workout_sessions`
rows with `inProgress` status, their `session_sets`, and latest
`actual_set_logs` revisions after the database is reopened. The controller
derives the restored training day from the linked `prescribed_sets` rows when
those links still exist. New actual-log identifiers include the set identity,
revision, and recorded time so a restarted controller cannot collide with a
process-local serial from a previous app run.

P4-07 does not add schema. Set, exercise, and session execution statuses are
calculated read-model values over the existing lifecycle fields, linked
prescription, and latest actual log. Persisted `workout_sessions.status` and
`session_sets.status` continue to describe storage lifecycle only; target-met,
needs-review, interruption, pain, and not-comparable states are derived at the
application boundary.

P4-08 does not add schema. Workout history, selected set details, and personal
records are read models over `workout_sessions`, `session_sets`,
`prescribed_sets`, and the latest `actual_set_logs` revision for each set.
Personal records are not stored separately in this phase; they are derived from
completed clean logs that include repetitions or load and do not include a
limiting outcome.

P4-09 does not add schema. Historical corrections append a new
`actual_set_logs` row for the same `session_set_id` with revision number
`latest + 1` and `supersedes_log_id` pointing at the previous latest log.
Earlier rows remain unchanged and remain visible in the selected set revision
history. Read models continue to use the highest revision as the current
historical value.

P4-10 does not add schema. It verifies the Phase 4 storage contract by reopening
a file-backed database after active workout logging and after a historical
correction. The recovered data must include the in-progress session, completed
set lifecycle, all actual-log revisions, the supersedes relationship, and the
latest-revision values used by history and personal-record read models.

### `measurement_records`

Stores the timestamped header and provenance for one measurement event. Each
record belongs to a profile and is deleted with that profile. Height, weight,
body-fat metadata, and regional measurements are added in Phase 6.

## Relationship Summary

```text
profiles
  |-- programs
  |     `-- program_versions
  |           |-- program_version_training_days
  |           `-- prescribed_sets
  |-- workout_sessions
  |     `-- session_sets
  |           `-- actual_set_logs
  `-- measurement_records

workout_sessions -- optional reference --> programs / program_versions
session_sets ---- optional reference --> prescribed_sets
actual_set_logs - optional supersedes --> earlier actual_set_logs
```

Profile-owned program, session, and measurement records use cascade deletion.
Program-template deletion cascades through versions and prescriptions but sets
historical session links to null. Session deletion cascades through session
sets and actual logs.

## Indexes

- Programs by profile and status
- Program versions by program and status
- Program-version training days by version and day order
- Prescribed sets by version and training day
- Sessions by profile and scheduled time, program, and program version
- Session sets by session and exercise, and by prescribed set
- Actual logs by session set and recorded time
- Measurements by profile and measured time

These indexes cover the first expected planning, execution, and history queries.
Query-specific indexes are added only when profiling demonstrates a need.
