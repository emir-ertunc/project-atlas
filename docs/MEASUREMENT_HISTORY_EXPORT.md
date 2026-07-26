# Measurement History Comparison and Export

## Document Status

- Status: P6-09 implemented
- Export schema version: `measurement_history_export.v1`

## Scope

P6-09 adds a Progress-screen read model for measurement-history comparison and
an explicit measurement-history report copy. The feature reads local
`measurement_records` only. It does not add database columns, write files,
create restore/import behavior, mutate measurement records, create analytics
tables, or change training prescriptions.

This is separate from the full encrypted backup and restore flow planned for
P8-10. P6-09 does not produce a restore-capable backup container.

## Comparison Rules

The comparison model sorts records by `measured_at` ascending. For each
supported body-measurement field, it finds the first and latest usable value:

- length fields must be positive finite centimeter values
- mass fields must be positive finite kilogram values
- body-fat values must be finite percentages greater than 0 and less than 100

A field appears in the comparison section only when at least two usable values
exist. The UI shows the baseline value, latest value, and signed delta using
the active unit system.

For side-specific circumference fields, the model also finds the latest record
that contains both left and right values for each pair:

- upper arm
- forearm
- thigh
- calf

The side comparison reports left value, right value, signed right-minus-left
difference, and absolute percentage difference. It is a measurement review aid,
not a medical, injury, or symmetry diagnosis.

## Export Report

The measurement report can be copied as CSV or JSON from the Progress screen.
The copied text contains personal measurement data and the UI warns the user
before the actions. No plaintext file is written by this feature.

The CSV report contains one row per measurement record and includes:

- schema version
- record ID
- measured and created timestamps
- measurement origin
- body-measurement method
- body-fat method
- all body-measurement numeric fields in normalized storage units
- notes

The JSON report contains the same records plus the derived comparison and
side-comparison summaries. Both formats intentionally omit `profile_id`.

## Non-Goals

- No encrypted backup container
- No restore or import
- No file picker or share-sheet integration
- No cloud sync
- No derived analytics persistence
- No automatic progression decisions from measurements

## Acceptance Checks

- Domain tests verify chronological sorting, first/latest comparisons, latest
  side-pair comparisons, deterministic CSV/JSON output, and omission of profile
  identifiers.
- Application tests verify that the Progress read model exposes measurement
  history together with workout history and trends.
- Widget tests verify the Progress-screen comparison rows, export record count,
  and CSV clipboard action.
