# Measurement Guidance and Validation

## Scope

P6-03 defines the first local measurement guidance and validation contract. It
does not add database columns, visual morph targets, trend charts, exports, or
medical interpretation.

The runtime source is `lib/core/measurements/measurement_guidance.dart`.

## Guidance Contract

Each stored measurement field has:

- Stable field identifier matching the repository record.
- Storage column name.
- English and Turkish title.
- English and Turkish reference point.
- English and Turkish capture instruction.
- Value kind: centimeters, kilograms, or percentage.
- Broad reference range used for warning-level data quality checks.
- Optional side and pair metadata for left/right comparison.

## Reference Points

| Field | Reference point |
| --- | --- |
| Height | Floor to crown of head while standing tall. |
| Weight | Scale reading under repeatable conditions. |
| Torso length | Base of neck to top of hip line along the front torso. |
| Chest | Chest circumference at nipple line or the widest consistent point. |
| Waist | Natural waist between lower ribs and hip bones. |
| Hips | Widest repeatable point of hips and glutes. |
| Upper arm | Midpoint between shoulder tip and elbow on each side. |
| Forearm | Widest repeatable point below the elbow on each side. |
| Thigh | Midpoint between hip crease and kneecap on each side. |
| Calf | Widest repeatable calf point on each side. |
| Body fat | A clearly labeled estimate from the selected method. |

## Blocking Validation

Repository writes block only data that cannot produce a valid measurement event:

- No numeric measurement value is present.
- A value is not finite.
- A length or mass value is zero or negative.
- Body-fat percentage is not greater than 0 and less than 100.

These checks prevent unusable local records while preserving broad support for
different body sizes and measurement methods.

## Warning Validation

Warnings do not block persistence. They are intended for later UI review:

- A value falls below or above the broad reference range for its field.
- Body measurements are present without a body-measurement method.
- Body-fat percentage is present without a body-fat measurement method.
- A left/right limb pair differs by more than the configured warning
  percentage.

Warnings are data-quality prompts, not training decisions. They do not change
program generation, scheduling, progression, pain handling, plateau gates, or
recommendation review.

## Morph Target Consumer

P6-04 reuses this validator before deriving bounded regional morph targets.
Blocking validation issues prevent morph target generation. Warning-level issues
remain available to later presentation review but do not prevent in-memory
target derivation.
