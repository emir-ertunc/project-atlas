# Design System

## Principles

- Use semantic roles instead of feature-level raw color values.
- Keep normal-size text at or above a 4.5:1 contrast ratio.
- Use the device system font so text follows platform rendering and language support.
- Base layout spacing on four logical pixels.
- Keep interactive controls at least 48 logical pixels in both dimensions.
- Support light and dark appearance from the same token structure.

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

P1-03 will add the behavioral accessibility layer for text scaling, focus,
semantics, and touch-target verification across complete screens.
