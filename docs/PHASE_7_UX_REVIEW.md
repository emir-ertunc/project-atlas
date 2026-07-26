# Phase 7 UX Review

## Scope

P7-14 validates the redesigned primary flows before the modern UX preview
build. The review focuses on deterministic screenshot baselines, large-text
rendering, touch targets, and coverage gaps that need another pass during the
P8 accessibility and device validation work.

No screenshot artifact uses real personal health, body-measurement, or workout
data. Seeded records are synthetic test data.

## Golden Screenshot Baselines

The P7 golden baselines live in `test/app/goldens/p7` and are exercised by
`test/app/project_atlas_ux_golden_test.dart`.

| State | Locale | Theme | Text scale | Artifact |
| --- | --- | --- | --- | --- |
| Today empty | English | Light | 1.0 | `today_empty.en.light.1x.png` |
| Today active plan | Turkish | Light | 1.0 | `today_active.tr.light.1x.png` |
| Today pending review | English | Dark | 2.0 | `today_pending.en.dark.2x.png` |
| Active workout | Turkish | Dark | 1.0 | `active_workout.tr.dark.1x.png` |
| Program empty | Turkish | Light | 2.0 | `program_empty.tr.light.2x.png` |
| Program active plan | English | Dark | 1.0 | `program_active.en.dark.1x.png` |
| Anatomy missing measurement | English | Dark | 2.0 | `anatomy_missing.en.dark.2x.png` |
| Progress overview | Turkish | Light | 1.0 | `progress_overview.tr.light.1x.png` |
| Profile hub | English | Dark | 1.0 | `profile_hub.en.dark.1x.png` |
| Profile setup | Turkish | Light | 2.0 | `profile_setup.tr.light.2x.png` |

## Large-Text and Touch-Target Checks

`test/app/project_atlas_accessibility_test.dart` now verifies:

- the shell navigation labels and semantics;
- Today, Program, Anatomy, Progress, and Profile root routes at 2.0 text scale;
- primary action touch targets for Today quick start, Program route cards,
  Anatomy controls and measurement prompt, Progress route cards, and Profile
  route cards;
- deterministic Anatomy measurement and heatmap provider state so route-level
  layout checks do not depend on database or renderer timing.

## Visual Review Matrix

| Surface | P7-14 coverage | Notes |
| --- | --- | --- |
| Today empty | Golden, large text, touch target | Empty coaching state and Program handoff reviewed. |
| Today active plan | Golden, widget tests | Synthetic active program and streak state reviewed. |
| Today pending review | Golden, widget tests | Pending active-workout review state reviewed in dark mode at 2.0 text scale. |
| Active workout before set | Golden, widget tests | Active set focus and queue reviewed. |
| Active workout after set and rest | Widget tests | Covered by set completion and rest timer tests. |
| Workout interruption | Widget tests | Covered by interruption outcome tests. |
| Program empty | Golden, large text, touch target | Empty hub and builder/catalog route cards reviewed. |
| Program active plan | Golden, widget tests | Active overview and training-day preview reviewed. |
| Recommendation inbox | Widget tests | Program hub route and placeholder inbox covered. |
| Program builder | Widget tests | First step, exercise picker, ordering, prescription, lifecycle, and publish confirmation covered by focused tests. The child route is excluded from golden baselines because the standard golden harness is unstable for this input-heavy route. |
| Catalog search and detail | Widget tests | Search, filters, empty results, detail, muscles, substitutions, and add-to-program actions remain covered by focused widget tests. Program child routes are excluded from P7 goldens for the same harness stability reason as builder. |
| Anatomy default and missing measurement | Golden, large text, touch target | Missing-measurement prompt, visual-first viewport, controls, and disclosure reviewed. |
| Anatomy heatmap and selected region | Widget tests | Renderer panel tests cover heatmap and region interaction states. |
| Progress overview | Golden, widget tests | Path, milestones, records, trend, and measurement cards reviewed. |
| Progress trend and measurement review | Widget tests | Focused review routes remain covered by Progress tests. |
| Profile hub | Golden, touch target | Profile route cards reviewed in dark mode. |
| Profile setup | Golden, widget tests | Guided setup first step reviewed at 2.0 text scale; full save flow covered by Settings tests. |

## Outcome

P7-14 is accepted for the modern UX preview build. The remaining broader
accessibility matrix, device screenshots, and Program child-route visual
regression hardening stay in the later P8 accessibility and overflow pass.
