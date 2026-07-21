# Progress Trends

## Document Status

- Status: P6-08 implemented; P6-09 measurement-history comparison is documented
  separately
- Rule set version: `progress_trends.v1`

## Scope

P6-08 adds display-only progress trends for:

- body measurements
- training volume
- load
- repetitions
- estimated strength

The feature is a local read model. It does not add database columns, persist
derived analytics, mutate workout history, change prescriptions, create
recommendations, or diagnose health, recovery, injury, or body composition.

## Measurement Trends

Measurement trends are derived from `measurement_records` for the local profile.
Each supported field becomes a trend only when at least two usable values exist.
Values are sorted by `measured_at`, and the trend compares the oldest usable
point to the latest usable point.

Supported fields:

- height
- weight
- torso length
- chest
- waist
- hips
- left and right upper arm
- left and right forearm
- left and right thigh
- left and right calf
- body-fat percentage

Length values remain stored in centimeters and are converted only for display.
Mass values remain stored in kilograms and are converted only for display.
Body-fat values remain percentages.

## Training Trends

Training trends are derived from completed workout set slots and their latest
actual-log revisions. A set contributes only when its latest log is clean:

- no strength, technique, pain, time, equipment, or external-interruption
  outcome
- at least one positive repetition or load value

This keeps trend displays aligned with personal-record read models and prevents
interruption or pain evidence from being presented as clean performance
progress.

Training points are grouped by exercise and workout session. When multiple sets
for the same exercise exist in a session:

| Trend | Session aggregation |
| --- | --- |
| Volume | Sum of `repetitions * loadKilograms` across loaded sets |
| Load | Highest load in the session |
| Repetitions | Highest repetition count in the session |
| Estimated strength | Highest estimated strength in the session |

Trends are shown only when a metric has at least two session points for the
same exercise.

## Estimated Strength

Estimated strength uses the Epley formula:

```text
estimated_strength = load_kg * (1 + repetitions / 30)
```

Repetition input is clamped to `1..30` for the estimate. The result is a
training estimate for trend display only. It is not a true one-repetition max,
not a coaching command, and not a progression decision.

## UI Behavior

The Progress screen now shows a Trends section above workout history when trend
data exists. Measurement and training trends are grouped separately. Training
trends are grouped by exercise and display the available volume, load,
repetition, and estimated-strength rows.

The empty workout-history state remains available when no workout sessions
exist. If measurement trends exist without workout history, the Progress screen
can show the Trends section and still show the workout-history empty state.

## Acceptance Checks

- Domain tests verify measurement trends, training metric aggregation,
  estimated-strength calculation, outcome filtering, and insufficient-data
  behavior.
- Application tests verify that the Progress read model combines measurement
  and workout history into one trend set.
- Widget tests verify that the Progress screen renders measurement and training
  trend rows with localized labels and unit formatting.

Measurement-history comparison and report-copy behavior is covered in
[measurement history comparison and export](MEASUREMENT_HISTORY_EXPORT.md).
