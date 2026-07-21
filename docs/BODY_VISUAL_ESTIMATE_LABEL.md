# Body Visual Estimate Label

## Scope

P6-06 labels personalized anatomy output as a visual estimate rather than a
medical scan. It adds disclosure copy and a schema-free domain contract around
the P6-05 clamped morph output. It does not add database columns, create
renderer integration, add heatmaps, build trend charts, or perform medical
interpretation.

The runtime source is
`lib/features/anatomy/domain/body_visual_estimate_label.dart`.

The visible disclosure is shown by
`lib/features/anatomy/presentation/anatomy_renderer_panel.dart`.

P6-10 adds a widget-level visual regression anchor that keeps the disclosure
visible above the anatomy fallback viewport at a fixed test size.

## Label Contract

The label contract version is `body_visual_estimate_label.v1`.

Every labeled body visual estimate preserves:

- P6-05 visual range contract version
- P6-05 clamped morph target set
- P6-03 measurement validation state carried through the target set
- Missing visual range state carried through the target set
- Disclosure kind: `measurementBasedVisualEstimate`

The contract explicitly reports:

- `isMedicalScan == false`
- `supportsDiagnosis == false`

## Required Disclosure

The user-facing label must communicate:

- The anatomy output is a visual estimate.
- It is not a medical scan, diagnostic image, exam, or medical assessment.
- It is built from saved measurements and training data.
- It cannot diagnose health, injury, disease, or body composition.
- If the model looks wrong, the user should review the saved measurement inputs.
- Training recommendations remain driven by workout evidence, not anatomy
  appearance.

## Localization

The disclosure is localized in English and Turkish:

- English: "Visual estimate, not a medical scan"
- Turkish: "Görsel tahmin, tıbbi tarama değil"

Both languages must remain professional, direct, and non-diagnostic.

## Acceptance Rules

- The anatomy screen must show the visual-estimate disclosure.
- Domain output must preserve the source clamped target set.
- The labeled result must never expose itself as a medical scan or diagnostic
  output.
- Blocking measurement validation and missing visual range states must be
  preserved.
- The label must not change training progression, scheduling, pain handling, or
  session status rules.
