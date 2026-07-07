# Core Data Model

## Scope

Schema version 3 establishes the local relational foundation for profiles,
programs, immutable program versions, prescribed sets, workout sessions,
actual set revisions, and measurement history. The Drift database is the source
of truth for the personal release, and SQLite foreign key enforcement is
enabled whenever the database opens.

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

### `measurement_records`

Stores the timestamped header and provenance for one measurement event. Each
record belongs to a profile and is deleted with that profile. Height, weight,
body-fat metadata, and regional measurements are added in Phase 6.

## Relationship Summary

```text
profiles
  |-- programs
  |     `-- program_versions
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
- Prescribed sets by version and training day
- Sessions by profile and scheduled time, program, and program version
- Session sets by session and exercise, and by prescribed set
- Actual logs by session set and recorded time
- Measurements by profile and measured time

These indexes cover the first expected planning, execution, and history queries.
Query-specific indexes are added only when profiling demonstrates a need.
