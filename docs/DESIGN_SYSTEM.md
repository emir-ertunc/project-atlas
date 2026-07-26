# Design System

## Principles

- Use semantic roles instead of feature-level raw color values.
- Keep normal-size text at or above a 4.5:1 contrast ratio.
- Use the device system font so text follows platform rendering and language support.
- Base layout spacing on four logical pixels.
- Keep interactive controls at least 48 logical pixels in both dimensions.
- Support light and dark appearance from the same token structure.
- Keep root screens compact and card-based; avoid long stacked menus.
- Use progress rings, streak dots, status chips, and concise cards to show
  state without heavy explanatory text.
- Use focused routes, sheets, and step flows for complex setup and editing.
- Apply motion only when it clarifies state changes or completion; workout
  logging must remain fast.

## Color Roles

Material `ColorScheme` owns standard interface roles. `AppSemanticColors`
extends it with status roles that Material does not provide.

| Role | Light | Dark | Intended use |
| --- | --- | --- | --- |
| Primary | `#006A67` | `#80D5D0` | Main actions and selected states |
| Secondary | `#4A6361` | `#B0CCC9` | Supporting controls and filters |
| Tertiary | `#49617A` | `#B1C9E7` | Data emphasis and secondary charts |
| Success | `#1D6B42` | `#8BD5A4` | Completed and successful outcomes |
| Warning | `#765B00` | `#EAC248` | Attention without failure |
| Information | `#1D5F9E` | `#A4C9FF` | Neutral guidance and explanations |
| Error | `#BA1A1A` | `#FFB4AB` | Invalid input and destructive states |
| Surface | `#F4FBF9` | `#0E1514` | Primary application background |

Every foreground/background pair exposed for text is covered by automated
contrast tests. Anatomy heatmaps and chart scales will be defined separately
with non-color indicators before those features are implemented.

## Typography

The scale uses the platform system font and does not bundle a font asset.

| Role | Size | Weight | Line height |
| --- | ---: | ---: | ---: |
| Display large | 48 | 700 | 1.08 |
| Display medium | 40 | 700 | 1.10 |
| Display small | 34 | 700 | 1.12 |
| Headline large | 32 | 700 | 1.18 |
| Headline medium | 28 | 700 | 1.20 |
| Headline small | 24 | 700 | 1.25 |
| Title large | 22 | 700 | 1.27 |
| Title medium | 16 | 600 | 1.35 |
| Title small | 14 | 600 | 1.40 |
| Body large | 16 | 400 | 1.50 |
| Body medium | 14 | 400 | 1.45 |
| Body small | 12 | 400 | 1.40 |
| Label large | 14 | 600 | 1.30 |
| Label medium | 12 | 600 | 1.30 |
| Label small | 11 | 600 | 1.30 |

## Spacing and Shape

| Token | Value |
| --- | ---: |
| `xxs` | 4 |
| `xs` | 8 |
| `sm` | 12 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `xxl` | 48 |
| `xxxl` | 64 |

Corner radii use 4, 8, 12, 16, and 24 logical pixels. The `full` radius is
reserved for pills and circular controls.

## Component Baseline

| Token | Value |
| --- | ---: |
| Minimum touch target | 48 |
| Standard control height | 48 |
| Large control height | 56 |
| Navigation bar height | 80 |
| Standard icon | 24 |
| Hairline stroke | 1 |
| Selected/focus stroke | 2 |

Buttons, icon buttons, cards, fields, chips, dividers, app bars, and navigation
bars consume these tokens through `AppTheme`. Feature code should read colors
and text styles from `Theme.of(context)` and use spacing/component constants.

## Modern Component Foundation

P7-02 adds the reusable component layer that later Phase 7 screens must use
before creating feature-specific alternatives.

| Component | File | Intended use |
| --- | --- | --- |
| Dashboard card | `AppDashboardCard` | Root dashboard cards with one state, one metric, and optional tap action |
| Status chip | `AppStatusChip` | Compact state labels for workout, recommendation, estimate, fatigue, and review states |
| Progress ring | `AppProgressRing` | Consistency, setup progress, completion, and compact metric progress |
| Dense form section | `AppDenseFormSection` | Short grouped edit surfaces in focused routes, sheets, and guided steps |
| Dense text field | `AppDenseTextField` | Numeric and short text inputs that stay compact but touch-safe |

### Compact Component Tokens

| Token | Value | Use |
| --- | ---: | --- |
| `denseControlHeight` | 48 | Minimum height for dense inputs and compact controls |
| `compactCardMinHeight` | 88 | Small summary cards in dense layouts |
| `dashboardCardMinHeight` | 116 | Root dashboard and hub cards |
| `statusChipHeight` | 32 | Non-interactive compact status chips |
| `interactiveStatusChipHeight` | 48 | Tappable status chips |
| `progressRingStroke` | 6 | Default ring stroke |
| `compactProgressRingSize` | 48 | Inline progress rings |
| `standardProgressRingSize` | 72 | Dashboard progress rings |

Dense does not mean smaller than an accessible target. Interactive controls
stay at or above 48 logical pixels; only non-interactive status display may use
the smaller chip height.

### Motion Tokens

| Token | Duration | Use |
| --- | ---: | --- |
| `micro` | 90 ms | Small pressed, chip, and value-change feedback |
| `fast` | 150 ms | Lightweight visibility and selection changes |
| `standard` | 250 ms | Progress ring and card state transitions |
| `route` | 300 ms | Focused route and sheet transitions |
| `emphasized` | 400 ms | Larger layout state changes |
| `completion` | 520 ms | Set completion, streak continuation, and milestone feedback |

Use `standardCurve` for ordinary state changes, `emphasizedCurve` for layout
changes, and `completionCurve` only for positive completion feedback. Safety,
pain, and body-estimate messages must not use celebratory motion.

### Usage Rules

- Root tabs should compose dashboard cards, status chips, and progress rings
  instead of stacked text sections.
- Complex edits should use dense form sections inside focused routes, sheets,
  or guided steps.
- Status chips are state indicators first. If tapping changes state or opens a
  review surface, use the interactive 48-pixel height.
- Progress rings must expose a semantic label and value. Decorative center text
  must not duplicate the semantics tree.
- Feature-specific widgets may wrap these components, but should not duplicate
  their spacing, shape, touch-target, or motion constants.

## Phase 7 Visual Direction

Phase 7 introduces a modern compact visual system on top of the foundation
tokens:

- dashboard cards for Today, Program, Anatomy, Progress, and Profile;
- metric cards with one primary number, one trend, and one action;
- status chips for workout state, fatigue, recommendation state, and estimate
  confidence;
- progress rings and streak paths for consistency;
- bottom sheets for quick edits, filters, interruptions, and confirmation;
- guided step screens for onboarding, measurement entry, and program creation;
- compact empty states with one next action.

The redesign should feel premium and disciplined rather than playful for its
own sake. Completion feedback may be celebratory, but pain, safety,
body-estimate, and progression messages stay serious and conservative.

## Accessibility Foundation

P1-03 closes the behavioral accessibility baseline for the current complete
screens:

- Normal-size text foreground/background pairs are covered by automated
  4.5:1 WCAG AA contrast tests.
- The application shell is verified at 2.0 text scale across Today, Program,
  Anatomy, Progress, and Settings without render overflow.
- Feature roots provide a focus traversal boundary and expose placeholder
  titles as semantic headers.
- The primary navigation bar and anatomy action controls are covered by
  minimum 48 logical pixel touch-target tests.

Future feature screens must keep these tests green or add equivalent
screen-level accessibility coverage before being marked complete.
