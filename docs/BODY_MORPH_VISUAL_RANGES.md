# Body Morph Visual Ranges

## Scope

P6-05 maps normalized P6-04 morph target signals into conservative visual
deformation ranges before any renderer consumes them. It does not add database
columns, change measurement validation, integrate the anatomy renderer, create a
medical or diagnostic interpretation. P6-06 wraps the clamped output with a
required visual-estimate label. P6-10 adds boundary and visual regression tests
for the range contract.

The runtime source is
`lib/features/anatomy/domain/body_morph_visual_ranges.dart`.

## Output Contract

The range contract version is `body_morph_visual_ranges.v1`.

Each visual range defines:

- Stable P6-04 target definition ID
- Matching morph channel
- Minimum visual multiplier for a normalized value of `-1`
- Neutral visual multiplier for a normalized value of `0`
- Maximum visual multiplier for a normalized value of `1`

The clamp output preserves:

- P6-04 rule-set version
- P6-03 measurement validation result
- Target confidence
- Source measurement fields
- Affected P2 anatomy region identifiers

## Clamp Behavior

The mapping is linear on each side of neutral:

- Positive normalized values move from neutral toward maximum.
- Negative normalized values move from neutral toward minimum.
- Values outside the expected `[-1, 1]` domain are clamped to the configured
  minimum or maximum.
- Non-finite normalized values are reset to neutral and marked with an invalid
  input clamp status.

If a target has no visual range entry, the clamp layer does not fabricate a
fallback value. It records the missing target ID so the renderer or presentation
layer can fail closed instead of applying an unknown deformation.

## Current Range Set

The current ranges are intentionally conservative visual multipliers. They are
safe pre-renderer bounds, not health categories or body-composition
classifications.

| Target definition | Minimum | Neutral | Maximum |
| --- | ---: | ---: | ---: |
| `stature_height_scale` | 0.94 | 1.00 | 1.06 |
| `mass_height_scale` | 0.96 | 1.00 | 1.04 |
| `torso_length_scale` | 0.95 | 1.00 | 1.05 |
| `chest_girth_scale` | 0.95 | 1.00 | 1.06 |
| `waist_girth_scale` | 0.94 | 1.00 | 1.07 |
| `hip_girth_scale` | 0.95 | 1.00 | 1.06 |
| `upper_arm_girth_left_scale` | 0.92 | 1.00 | 1.09 |
| `upper_arm_girth_right_scale` | 0.92 | 1.00 | 1.09 |
| `forearm_girth_left_scale` | 0.93 | 1.00 | 1.08 |
| `forearm_girth_right_scale` | 0.93 | 1.00 | 1.08 |
| `thigh_girth_left_scale` | 0.94 | 1.00 | 1.07 |
| `thigh_girth_right_scale` | 0.94 | 1.00 | 1.07 |
| `calf_girth_left_scale` | 0.93 | 1.00 | 1.08 |
| `calf_girth_right_scale` | 0.93 | 1.00 | 1.08 |
| `body_fat_soft_tissue_estimate` | 0.95 | 1.00 | 1.06 |

## Acceptance Rules

- Every P6-04 morph target definition must have exactly one visual range.
- The range channel must match the target definition channel.
- Range values must be finite and ordered as minimum <= neutral <= maximum.
- Clamped output must never exceed the configured visual range.
- Blocking measurement validation still produces no morph or visual targets.
- P6-06 must label downstream personalized anatomy output as a visual estimate,
  not a medical scan.
- P6-10 must keep deterministic visual snapshot coverage for representative
  clamped output and monotonic interpolation coverage for every range.
