# Phase 7 Validation

## Result

- Date: 2026-07-27
- Scope: Phase 7 modern UX redesign through P7-16, including compact
  dashboard roots, focused child routes, guided setup and program creation,
  daily coach dashboard, active workout focus flow, modern Program, Catalog,
  Anatomy, Progress, and Profile surfaces, local achievement feedback,
  concise Turkish and English microcopy, UX golden coverage, accessibility
  checks, Build C4.5 APK production, pull request publication, and CI
  verification.
- Result: Publication and CI validation passed
- Remaining Phase 7 checklist items: None

## Publication

- Branch: `codex/phase-7-modern-ux`
- Pull request: `https://github.com/emir-ertunc/project-atlas/pull/8`
- Base branch: `codex/phase-6-measurements-progress`
- Head commit after CI fix:
  `1993847bda9f5fe7837bb4a6a07b0a8070cd6bdd`
- CI workflow: `Quality and Android debug build`
- CI result:
  - Pull request event:
    `https://github.com/emir-ertunc/project-atlas/actions/runs/30222938514`
  - Push event:
    `https://github.com/emir-ertunc/project-atlas/actions/runs/30222937199`

The initial CI run exposed cross-platform golden-image rasterization drift on
Linux after the Windows-generated P7 baselines were committed. The P7 golden
suite now uses a 1% precision tolerance for this test file only. The observed
runner diffs were below that tolerance, while larger visual regressions still
produce the normal golden failure artifacts.

## Build C4.5 Artifact

- Package: `app.projectatlas.personal`
- Version name: `0.1.0`
- Version code: `1`
- Application label: `Project Atlas`
- Minimum SDK: `24`
- Target SDK: `36`
- File: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 198,958,092 bytes
- SHA-256:
  `2353AF93E68EABA8FE081A0DFA6CEECF6C8548DEE20B33818366D63C46B32F4F`
- Build source: ASCII `subst` workspace at `P:\`, mapped to the existing
  repository path
- Build define: `PROJECT_ATLAS_INITIAL_LOCATION=/today`
- Distribution status: Development-only debug artifact; excluded from source
  control

Build C4.5 opens to the redesigned Today dashboard so the modern UX preview
starts on the daily coach surface. The APK remains unsigned for release-store
distribution and is intended only for local development or direct debug
installation.

## Local Validation Coverage

- Resolved Flutter dependencies.
- Regenerated localization output.
- Verified static analysis.
- Ran the full Flutter test suite serially so golden and native-asset tests do
  not conflict over local build artifacts.
- Built the Android debug APK from the ASCII workspace.
- Verified APK package metadata with `aapt dump badging`.
- Checked patch whitespace.
- Scanned changed text/code files for prohibited attribution phrases.
- Published the Phase 7 branch.
- Opened the Phase 7 pull request.
- Verified pull request and push CI workflow runs.

## Commands

| Command | Result |
| --- | --- |
| `flutter pub get` | Passed |
| `flutter gen-l10n` | Passed |
| `dart analyze` | Passed |
| `flutter test --concurrency=1 --reporter compact` | Passed, 273 tests |
| `flutter build apk --debug --dart-define=PROJECT_ATLAS_INITIAL_LOCATION=/today` | Passed from `P:\` |
| `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk` | Passed |
| `git diff --check` | Passed |
| P7-15 attribution scan | Passed |
| P7-15 sensitive-material scan | Passed |
| P7-16 `dart analyze` | Passed |
| `flutter test --concurrency=1 --reporter compact test/app/project_atlas_ux_golden_test.dart` | Passed, 10 tests |
| P7-16 `flutter test --concurrency=1 --reporter compact` | Passed, 273 tests |
| P7-16 attribution scan | Passed |
| P7-16 sensitive-material scan | Passed |
| `git push -u origin codex/phase-7-modern-ux` | Passed |
| `gh pr create --draft --base codex/phase-6-measurements-progress --head codex/phase-7-modern-ux` | Passed |
| `gh pr checks 8 --watch --interval 10` | Passed |

## Build C4.5 Product Boundary

Build C4.5 packages the modern UX preview slice implemented through P7-14:

- compact premium dashboard cards, status chips, progress rings, dense forms,
  and shared motion tokens
- five root destinations treated as dashboards instead of long editing pages
- guided setup wizard for goal, experience, equipment, availability, and
  measurement preference
- Today daily coach dashboard with quick start or resume, streak, weekly
  consistency, and review queue
- focused active workout route with one current set, compact previous
  performance, quick edits, rest state, and set queue
- Program hub with active-plan overview, training days, recommendation inbox,
  builder entry, and catalog entry
- guided Program builder with setup, day editing, catalog selection,
  prescription editing, and publish review
- modern Catalog and detail surfaces with compact filters, media hierarchy,
  muscle chips, substitutions, and add-to-program action
- visual-first Anatomy root with overlay heatmap controls, missing-measurement
  prompt, selected-region feedback, and visual-estimate disclosure
- Progress path dashboard with streaks, milestones, personal records, trends,
  and measurement comparison
- Profile hub with focused setup and preference routes
- local achievement feedback without social ranking, points, or progression
  rule changes
- Turkish and English microcopy tightened for compact cards and large-text
  rendering
- UX golden baselines, route-level 2.0 text-scale checks, and primary-action
  touch-target checks

Build C4.5 does not add release signing, account synchronization, external
services, durable recommendation storage, notification reminder rollout,
calendar integration, encrypted restore, or store-ready package identifiers.
Those remain later-phase work.
