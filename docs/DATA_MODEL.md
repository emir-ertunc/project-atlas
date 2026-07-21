# Core Data Model

## Scope

Schema version 8 establishes the local relational foundation for profiles,
onboarding preferences, weekly availability windows, programs, immutable
program versions, version-scoped training-day snapshots, prescribed sets,
workout sessions, actual set revisions, and measurement history. The Drift
database is the source of truth for the personal release, and SQLite foreign
key enforcement is enabled whenever the database opens.

P6-01 extends measurement history with nullable body-measurement values, P6-02
adds nullable body-fat percentage plus measurement-method metadata, P6-03 adds
schema-free measurement guidance and validation, P6-04 adds schema-free bounded
regional morph target derivation, and P6-05 adds schema-free visual range
clamping. P6-06 adds schema-free visual-estimate labeling. P6-07 adds
schema-free training heatmaps from workout history and catalog muscle mappings.
P6-08 adds schema-free progress trends from measurement history and completed
clean workout logs. P6-09 adds schema-free measurement-history comparison and
copyable CSV/JSON report generation. P6-10 adds test-only morph-boundary and
visual-regression coverage. P6-11 produces Build C4 without adding schema,
persisted derived visual state, sample personal data, or release signing.
The current
measurement table now provides stable event identity, timestamp, source, height,
weight, torso, left/right limb values, body-fat value, and method provenance
needed by later
visual-estimate and trend features.

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

### `onboarding_preferences`

Stores the P5-01 adaptive onboarding inputs for one profile: primary training
goal, self-reported training experience, available equipment identifiers,
preferred session length in minutes, and preferred weekdays. The profile ID is
the primary key, so saving preferences replaces the one local preference row for
that profile. The row is deleted when its profile is deleted.

The session-length value is constrained to 20-180 minutes. Equipment and
weekday selections are stored as comma-separated enum names and validated at
the repository boundary to be non-empty and unique. These values are inputs for
later calibration, availability, and generator work; they do not create a
program or progression decision in P5-01.

P5-02 does not add schema. The conservative calibration block is a deterministic
read model derived from `onboarding_preferences`; it is not stored separately
and does not create program, session, or prescription rows.

### `availability_windows`

Stores P5-03 recurring weekly availability for one profile. Each row has a
weekday, `fixed` or `flexible` period type, start minute, and end minute.
Minutes are counted from the beginning of the local day, with `0` representing
00:00 and `1440` representing 24:00.

Fixed periods represent hard appointment-like training availability. Flexible
periods represent ranges where a later schedule solver may place the session.
The table rejects empty or reversed windows and is deleted with the owning
profile. Exact duplicate windows for the same profile, weekday, type, and time
range are not allowed.

P5-04 does not add schema. The program planner composes
`onboarding_preferences`, `availability_windows`, and bundled exercise catalog
metadata into an editable in-memory `ProgramDraft`. Existing `programs`,
`program_versions`, `program_version_training_days`, and `prescribed_sets`
rows are created only if the user later saves or publishes from the Program
screen.

P5-05 does not add schema. Missed-session replacement proposals are calculated
in memory from the generated program preview and `availability_windows`. The
feature does not create workout sessions, recommendation rows, availability
edits, or program-version snapshots.

P5-06 does not add schema. Bounded progression decisions are calculated in
memory from an existing loaded exercise prescription and a local load policy.
The feature does not create recommendation rows, update `prescribed_sets`, or
write program-version snapshots.

P5-07 does not add schema. Smallest-load-increase proposals are calculated in
memory from exercise exposure summaries and the existing prescription. The
feature does not add exposure tables, recommendation rows, or program-version
mutation.

P5-08 does not add schema. Isolated-miss holds and repeated-miss decrease
candidates are calculated in memory from pre-classified exposure signals and
the existing prescription. The feature does not add streak tables,
recommendation rows, or program-version mutation.

P5-09 does not add schema. Progression signal classification is calculated in
memory from raw exposure evidence and the existing prescription. The feature
does not add streak tables, interruption tables, recommendation rows, or
program-version mutation.

P5-10 does not add schema. Pain progression guard decisions are calculated in
memory from raw exposure evidence and the existing prescription. The feature
does not add safety tables, recommendation rows, or program-version mutation.

P5-11 does not add schema. Plateau and deload data-gate decisions are
calculated in memory from classified exposure signals and the existing
prescription. The feature does not add plateau tables, deload tables,
recommendation rows, or program-version mutation.

P5-12 does not add schema. Recommendation explanation envelopes are calculated
in memory from existing recommendation candidates and triggering evidence IDs.
The feature does not add explanation tables, undo tables, recommendation rows,
or program-version mutation.

P5-13 does not add schema. Recommendation review state is calculated in memory
from an explanation envelope and the current prescription. The feature does not
add review tables, recommendation rows, undo tables, or program-version
mutation.

P5-14 does not add schema. Golden-persona and twelve-week simulation coverage
uses synthetic in-memory test fixtures only. The feature does not add
simulation tables, fixture tables, recommendation rows, or program-version
mutation.

P5-15 does not add schema. Build C3 packages the existing Phase 5 adaptive
programming slice into a development-only Android debug APK. The build does not
add recommendation tables, persistence state, sample personal data, or
program-version mutation.

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

Stores one timestamped body-measurement event. Each record belongs to a profile
and is deleted with that profile.

P6-01 adds nullable normalized body-measurement values:

- `height_centimeters`
- `weight_kilograms`
- `torso_length_centimeters`
- `chest_circumference_centimeters`
- `waist_circumference_centimeters`
- `hip_circumference_centimeters`
- `left_upper_arm_circumference_centimeters`
- `right_upper_arm_circumference_centimeters`
- `left_forearm_circumference_centimeters`
- `right_forearm_circumference_centimeters`
- `left_thigh_circumference_centimeters`
- `right_thigh_circumference_centimeters`
- `left_calf_circumference_centimeters`
- `right_calf_circumference_centimeters`

P6-02 adds nullable body-fat and method metadata:

- `body_fat_percentage`
- `body_measurement_method`
- `body_fat_measurement_method`

All body-measurement values are optional for backwards compatibility and must
be positive when present. Body-fat percentage is optional and must be greater
than 0 and less than 100 when present. Method values are optional enum values;
`body_measurement_method` records how the circumference, height, or weight
facts were captured, while `body_fat_measurement_method` records how the
body-fat estimate was captured. Existing timestamp, source, notes, and creation
fields remain unchanged.

P6-03 does not add columns. It defines field-level reference points, capture
instructions, broad warning ranges, missing-method warnings, and left/right
side-difference warnings in application code. Repository writes block only
invalid measurement events: no numeric value, non-finite value, non-positive
length or mass value, or body-fat percentage outside the open 0-100 range.

P6-04 also does not add columns. It derives transient regional morph target
signals from a loaded `MeasurementRecord`, reuses P6-03 validation, and returns
bounded values in `[-1, 1]` keyed by stable target definitions and P2 anatomy
region IDs. P6-05 remains schema-free as well: it maps those normalized signals
into target-specific visual minimum, neutral, and maximum multipliers. The
values are not stored, not exported, and not applied to renderer meshes in this
step. P6-06 also adds no columns: it wraps the clamped output with a
non-diagnostic visual-estimate label and preserves blocking-validation and
missing-range state.

P6-07 also adds no columns. Anatomy heatmaps are derived in memory from
completed `session_sets`, their latest `actual_set_logs` revisions, and bundled
exercise-catalog muscle mappings. The derived trained-muscle, weekly-volume,
and fatigue scores are not stored, exported, or used to mutate measurement,
workout, prescription, or recommendation rows.

P6-08 also adds no columns. Progress trends are derived in memory from
`measurement_records`, completed `session_sets`, and the latest clean
`actual_set_logs` revisions. The derived measurement, volume, load, repetition,
and estimated-strength trends are not stored, exported, or used to mutate
measurement, workout, prescription, or recommendation rows.

P6-09 also adds no columns. Measurement-history comparisons and CSV/JSON report
text are derived in memory from `measurement_records`. The read model compares
first and latest usable field values, derives latest left/right side
differences for paired circumference fields, and omits `profile_id` from report
text. It does not write plaintext files, add restore/import behavior, persist
derived comparisons, or mutate measurement rows.

P6-10 also adds no columns. Morph-boundary and visual-regression tests exercise
the existing measurement, morph target, visual range, and anatomy disclosure
contracts without adding tables, indexes, migrations, fixtures with personal
data, or stored derived visual state.

P6-11 also adds no columns. Build C4 packages the existing Phase 6 measurement,
visual-estimate, heatmap, trend, comparison, and test contracts into a
development-only Android debug APK without changing table definitions,
migrations, stored analytics, export containers, or bundled personal data.

## Relationship Summary

```text
profiles
  |-- onboarding_preferences
  |-- availability_windows
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
- Onboarding preferences by profile primary key
- Availability windows by profile and weekday
- Program versions by program and status
- Program-version training days by version and day order
- Prescribed sets by version and training day
- Sessions by profile and scheduled time, program, and program version
- Session sets by session and exercise, and by prescribed set
- Actual logs by session set and recorded time
- Measurements by profile and measured time

These indexes cover the first expected planning, execution, and history queries.
Query-specific indexes are added only when profiling demonstrates a need.
