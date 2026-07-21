# Body Morph Targets

## Scope

P6-04 defines deterministic regional morph target signals from stored body
measurements. It does not add database columns, renderer application, trend
charts, or export behavior. P6-05 maps these normalized signals into bounded
visual ranges before renderer consumption. P6-10 adds boundary and visual
regression tests for these contracts.

The runtime source is `lib/features/anatomy/domain/body_morph_targets.dart`.

## Output Contract

Each generated target contains:

- Rule-set version: `body_morph_targets.v1`
- Stable target definition ID
- Morph channel
- Normalized value in `[-1, 1]`
- Confidence level
- Source measurement fields
- Affected P2 semantic anatomy region identifiers

The value is a pre-renderer signal:

- `-1` means the source measurement is at or beyond the low-side rule bound.
- `0` means neutral for this deterministic rule set.
- `1` means the source measurement is at or beyond the high-side rule bound.

P6-05 maps these neutral signals into the versioned visual range contract
documented in [body morph visual ranges](BODY_MORPH_VISUAL_RANGES.md).
P6-06 labels the clamped result with the disclosure documented in
[body visual estimate label](BODY_VISUAL_ESTIMATE_LABEL.md).

## Morph Channels

- `statureScale`
- `massScale`
- `torsoLength`
- `circumference`
- `softTissueEstimate`

The mass scale uses weight and height as a non-diagnostic mass-to-height signal.
It is not a training-progression rule or a health classification.

## Regional Mapping

The target definitions map measurement fields to stable anatomy region IDs:

| Measurement source | Target coverage |
| --- | --- |
| Height | Current targetable anatomy regions |
| Weight + height | Current targetable anatomy regions |
| Torso length | Trapezius, erector spinae, external oblique, serratus anterior |
| Chest | Pectoralis, serratus anterior, anterior deltoid |
| Waist | External oblique, erector spinae |
| Hips | Glutes, adductors, iliopsoas, deep hip external rotators |
| Upper arm | Biceps, brachialis, triceps on the matching side |
| Forearm | Forearm flexor/pronator and extensor/supinator groups on the matching side |
| Thigh | Quadriceps, hamstrings, adductors on the matching side |
| Calf | Gastrocnemius, soleus, tibialis anterior, fibularis on the matching side |
| Body fat | Trunk, hip, arm, forearm, thigh, and calf soft-tissue estimate regions |

All region IDs must remain valid according to
`tool/anatomy/muscle_region_ontology.v1.json`.

## Normalization Rules

Height, body-fat percentage, and mass-to-height targets use direct or composite
signals with deterministic neutral values and full-scale deltas.

Circumference and torso-length targets use height-normalized ratios when height
is available. If height is missing, they fall back to the broad P6-03 reference
range for that measurement field and mark the target confidence as
`broadRangeFallback`.

Generated values are bounded to `[-1, 1]` before they leave the domain rule.
This bound protects downstream consumers from unbounded numeric input, but it
is not the final mesh deformation clamp. The P6-05 visual range layer converts
the normalized value into target-specific minimum, neutral, and maximum visual
multipliers.

## Validation Behavior

The morph builder reuses the P6-03 measurement validator. If a measurement
event has blocking issues, no morph targets are produced. Warning-level issues
do not prevent target generation, because the future UI may still let the user
review and accept those warnings.

## P6-10 Test Coverage

Boundary tests verify minimum and maximum valid measurements, missing-height
fallback behavior, finite normalized values, and the invariant that generated
signals stay inside `[-1, 1]`. Visual regression tests are documented in
[morph boundary and visual regression tests](MORPH_BOUNDARY_VISUAL_REGRESSION.md).
