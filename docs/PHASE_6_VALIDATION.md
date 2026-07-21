# Phase 6 Validation

## Result

- Date: 2026-07-21
- Scope: Phase 6 measurement storage, body-fat and method provenance,
  measurement guidance and validation, bounded body morph targets, visual range
  clamps, visual-estimate disclosure, training-derived anatomy heatmaps,
  Progress trends, measurement-history comparison and report copy,
  morph-boundary and visual-regression coverage, and Build C4 APK production
- Pull request:
  [#7 Complete Phase 6 measurements and personalized anatomy](https://github.com/emir-ertunc/project-atlas/pull/7)
- Result: Passed
- Remaining Phase 6 checklist items: None

The Phase 6 branch is published as a stacked pull request on top of the Phase 5
branch.

## Build C4 Artifact

- Package: `app.projectatlas.personal`
- Version name: `0.1.0`
- Version code: `1`
- Application label: `Project Atlas`
- Minimum SDK: `24`
- Target SDK: `36`
- File: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 198,872,646 bytes
- SHA-256:
  `7B7A4EB193CB78A1AA3320199C1DA9547B5637387F799626FDBCE82251731393`
- Build source: ASCII `subst` workspace at `P:\`, mapped to the existing
  repository path
- Build define: `PROJECT_ATLAS_INITIAL_LOCATION=/anatomy`
- Distribution status: Development-only debug artifact; excluded from source
  control

The APK opens directly to the Anatomy branch for this checkpoint while keeping
the P2-10 renderer performance policy unchanged. Normal anatomy rendering uses
the Flutter semantic fallback unless a later explicit profiling build enables
the native renderer override.

## Local Validation Coverage

- Resolved Flutter dependencies.
- Regenerated localization and Drift outputs.
- Verified Dart formatting and static analysis.
- Ran the full Flutter test suite with coverage.
- Built the Android debug APK from the ASCII workspace.
- Verified APK package metadata with `aapt dump badging`.
- Checked Markdown structure and patch whitespace.
- Scanned changed P6-11 documentation for prohibited attribution phrases.
- Scanned changed P6-11 documentation for secret-like values and signing
  material.

## Commands

| Command | Result |
| --- | --- |
| `flutter pub get` | Passed from `P:\` |
| `flutter gen-l10n` | Passed from `P:\` |
| `dart run build_runner build --delete-conflicting-outputs` | Passed from `P:\`; the removed option was ignored by the installed build_runner version |
| `dart format --output=none --set-exit-if-changed lib test` | Passed |
| `dart analyze` | Passed |
| `flutter test --coverage --reporter=compact` | Passed, 246 tests |
| `flutter build apk --debug --dart-define=PROJECT_ATLAS_INITIAL_LOCATION=/anatomy` | Passed from `P:\` |
| `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk` | Passed |
| `git diff --check` | Passed |
| P6-11 Markdown structure scan | Passed |
| P6-11 attribution scan | Passed |
| P6-11 secret scan | Passed |
| `git push -u origin <phase-6-branch>` | Passed |
| `gh pr create --draft --base <phase-5-branch> --head <phase-6-branch>` | Passed |
| `gh pr checks 7` | Passed |

## Publication and CI

- Pull request:
  [#7 Complete Phase 6 measurements and personalized anatomy](https://github.com/emir-ertunc/project-atlas/pull/7)
- Base: Phase 5 branch
- Head: Phase 6 branch
- CI workflow: `CI / Quality and Android debug build`
- Push CI result: Passed
- Pull request CI result: Passed

## Build C4 Product Boundary

Build C4 packages the personalized anatomy alpha slice implemented through
P6-10:

- body measurement storage for height, weight, torso, and side-specific limbs
- optional body-fat value and measurement-method provenance
- measurement guidance, reference points, validation, and warnings
- bounded measurement-derived regional morph target signals
- conservative visual range clamps for morph output
- visible non-diagnostic visual-estimate disclosure
- trained-muscle, weekly-volume, and fatigue anatomy heatmaps
- measurement, volume, load, repetition, and estimated-strength trends
- measurement-history first-to-latest comparison and explicit report copy
- morph-boundary and visual-regression coverage

Build C4 remains a debug checkpoint. Renderer mesh deformation, reviewed
runtime GLB packaging, signed release artifacts, encrypted backup restore,
account synchronization, branch publication, pull request creation, and CI
verification remain outside P6-11.
