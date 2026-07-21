# Morph Boundary and Visual Regression Tests

## Document Status

- Status: P6-10 implemented

## Scope

P6-10 completes test coverage around the P6-04 morph target, P6-05 visual
range, and P6-06 visual-estimate disclosure contracts. It does not add database
columns, renderer mesh deformation, real anatomy assets, screenshot artifacts,
medical interpretation, or training-progression behavior.

## Boundary Coverage

The boundary test suite verifies:

- minimum and maximum valid P6-03 reference-range measurements
- all generated normalized morph values remain finite and inside `[-1, 1]`
- all clamped visual values remain finite and inside their configured visual
  ranges
- every height-normalized circumference and torso target falls back to the
  broad reference range when height is absent
- missing height does not fabricate stature or mass-height targets
- all visual ranges interpolate monotonically from minimum to neutral to maximum
- non-finite normalized inputs reset to neutral and record the invalid-input
  clamp status

## Visual Regression Coverage

The project does not yet use file-based golden screenshots. P6-10 instead locks
the renderer-facing visual contract with deterministic tests that are stable in
CI:

- a representative clamped morph snapshot records target ID, morph channel,
  normalized value, visual value, clamp status, and confidence
- the anatomy panel widget verifies that the visual-estimate disclosure remains
  visible above the fallback viewport at a fixed test size

These tests catch accidental changes to morph normalization, visual range
multipliers, clamp behavior, disclosure placement, and fallback anatomy preview
structure without requiring platform-specific screenshot baselines.

## Acceptance Checks

- Domain tests cover morph boundary values and visual range interpolation.
- Snapshot-style tests cover representative clamped visual output.
- Widget tests cover visual-estimate disclosure layout anchors.
- Full test coverage passes with no schema migration or generated database
  change required by P6-10.
