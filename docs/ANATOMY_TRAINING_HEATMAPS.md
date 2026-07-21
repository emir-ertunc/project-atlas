# Anatomy Training Heatmaps

## Document Status

- Status: P6-07 implemented
- Rule set version: `anatomy_training_heatmaps.v1`

## Scope

P6-07 shows training-derived heatmaps on the Anatomy screen:

- trained-muscle exposure
- weekly volume
- fatigue proxy

The feature is read-only. It derives heatmaps from local completed workout sets
and bundled exercise-catalog muscle mappings, then sends normalized scores to
the existing anatomy renderer heatmap API. It does not add database columns,
write derived state, change prescriptions, publish recommendations, or diagnose
health or injury status.

## Data Sources

The application provider reads:

- the local profile ID
- `WorkoutRepository.getSessions`
- `WorkoutRepository.getSessionSets`
- `WorkoutRepository.getActualSetLogs`
- the bundled `ExerciseCatalog`

Only completed `session_sets` with at least one actual-set log are considered.
When a set has corrections, the highest actual-log revision is used. Cancelled
sessions, planned sessions, future logs, and logs outside the trailing seven-day
window are ignored.

Exercise IDs must resolve in the bundled catalog. Unknown exercise IDs are
reported in the in-memory `ignoredExerciseIds` audit set and do not contribute
to a heatmap.

## Muscle Weighting

The rule uses the P3-05 exercise muscle mapping contract:

| Mapping role | Weight |
| --- | ---: |
| Primary | `1.00` |
| Secondary | `0.65` |
| Stabilizer | `0.35` |

If a region appears in more than one role for the same exercise, the strongest
role weight wins so one set cannot double-count the same region.

## Heatmap Signals

### Trained muscle

Trained-muscle exposure counts role-weighted completed set evidence. Numeric
repetitions count as one set. Load-only evidence counts as partial evidence.
Outcome-only strength, technique, or pain entries count as attempted hard-set
evidence. Time, equipment, and external interruptions count as low exposure.

### Weekly volume

Weekly volume sums role-weighted local volume units in the trailing seven-day
window. Loaded sets use `repetitions * loadKilograms`. Unloaded or bodyweight
sets with repetitions use repetitions as the volume unit. Logs without
repetitions do not add weekly-volume units.

### Fatigue proxy

Fatigue is a training-load visualization, not a medical or recovery diagnosis.
It combines:

- trained-set evidence
- set outcome multiplier
- low-RIR multiplier
- recency multiplier across the trailing seven-day window

Strength and technique limitations increase the proxy moderately. Pain reports
increase the proxy only as an on-screen training-load warning signal; pain
progression decisions remain owned by the Phase 5 safety rules.

## Normalization and Renderer Contract

Each heatmap is normalized independently to renderer scores in `0.0..1.0`. The
highest raw region in a selected heatmap receives `1.0`; other regions are
scaled proportionally. Empty evidence returns empty maps.

The renderer continues to receive a `Map<String, double>` keyed by stable P2
semantic muscle region IDs. Existing Flutter fallback picking and Android
platform-view heatmap handling remain unchanged.

## UI Behavior

The Anatomy screen loads heatmaps through Riverpod and passes the async state to
the renderer panel. The panel displays a training heatmap card with three
selectable modes:

- Trained muscles
- Weekly volume
- Fatigue

Selecting a mode applies that normalized map to the shared
`AnatomyInteractionController`. Loading, failure, and empty states are
localized in English and Turkish.

## Acceptance Checks

- Domain tests cover role weighting, score normalization, unknown exercise
  handling, time-window filtering, session-lifecycle filtering, empty evidence,
  and invalid windows.
- Widget tests verify that the Anatomy panel displays the heatmap modes and
  applies trained, volume, and fatigue maps to renderer state.
- Static analysis and full Flutter tests must pass before marking P6-07
  complete.
