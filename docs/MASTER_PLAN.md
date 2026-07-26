# Project Atlas Master Plan

## Working Protocol

- Complete one checklist item per user command unless the user explicitly groups tasks.
- Read `AGENTS.md` and the documents relevant to the active item before editing.
- Do not begin the next item automatically.
- Mark an item complete only after its acceptance checks pass.
- After a completed checklist item, update this file and include the current phase progress plus the next open checklist item in the completion response.
- Record architectural or product changes in `DECISIONS.md`.
- Every phase ends with validation, an owner-authored commit, a pushed branch, a pull request, and a green CI result.

## Phase 0 — Governance, Tooling, and Project Skeleton

- [x] P0-01 Create the repository rules in `AGENTS.md`.
- [x] P0-02 Create the master plan and technical document skeletons.
- [x] P0-03 Add Apache-2.0 licensing, notices, README, and a secure `.gitignore`.
- [ ] P0-04 Install and validate Flutter, Android Studio, JDK, Android SDK, and a physical-device workflow.
- [x] P0-05 Create the Flutter application with a temporary package identifier.
- [x] P0-06 Add Riverpod, GoRouter, Drift, and the initial test infrastructure.
- [x] P0-07 Add Turkish/English localization and metric/imperial unit infrastructure.
- [x] P0-08 Create CI checks for analysis, tests, and a debug Android build.
- [x] P0-09 Configure the project owner's Git identity and connect the public remote.
- [x] P0-10 Produce and install the first debug APK. **Build C0**
- [x] P0-11 Commit Phase 0 with the project owner's identity.
- [x] P0-12 Push the phase branch, open a pull request, and verify green CI.

## Phase 1 — Design System and Local Data Core

- [x] P1-01 Define accessible colors, typography, spacing, and component tokens.
- [x] P1-02 Create the main navigation: Today, Program, Anatomy, Progress, and Settings.
- [x] P1-03 Implement accessibility foundations for contrast, type scaling, and touch targets.
- [x] P1-04 Create the Drift schema for profiles, programs, sessions, sets, and measurements.
- [x] P1-05 Separate program versions, prescribed sets, and actual set logs.
- [x] P1-06 Create repository interfaces and the local-first data flow.
- [x] P1-07 Add database migration and process-recovery tests.
- [x] P1-08 Exclude sensitive files from device backups and design encrypted export.
- [x] P1-09 Run phase validation and update the technical documentation.
- [x] P1-10 Commit, push, open the pull request, and verify CI.

## Phase 2 — Anatomy and Asset Technical Spike

- [x] P2-01 Select redistributable skeleton and muscle source assets.
- [x] P2-02 Reduce the source anatomy into 40-80 meaningful left/right muscle regions.
- [x] P2-03 Define stable semantic muscle identifiers and Turkish/English names.
- [x] P2-04 Create the Blender cleanup, retopology, LOD, and GLB export pipeline.
- [x] P2-05 Create the Android Filament renderer and Flutter platform bridge.
- [x] P2-06 Implement rotation, zoom, picking, and muscle heatmap highlighting.
- [x] P2-07 Measure load time, frame rate, and memory on a mid-range Android device.
- [x] P2-08 Add CI budgets for GLB size, geometry, draw calls, and license metadata.
- [x] P2-09 Create a shared rig and short animation prototype for ten core exercises.
- [x] P2-10 Apply LOD or fallback behavior if performance thresholds are missed.
- [x] P2-11 Produce the profileable anatomy APK. **Build C1**
- [x] P2-12 Commit, push, open the pull request, and verify CI.

## Phase 3 — Exercise Catalog and Manual Program Builder

- [x] P3-01 Define the inventory for 120 foundational exercises.
- [x] P3-02 Add muscle-region and movement-pattern categories.
- [x] P3-03 Add equipment, level, laterality, and exercise-type filters.
- [x] P3-04 Write original instructions, form cues, common errors, and substitutions.
- [x] P3-05 Verify primary, secondary, and stabilizer muscle mappings.
- [x] P3-06 Build catalog search, filters, list, and exercise detail screens.
- [x] P3-07 Build program creation, training-day editing, and exercise ordering.
- [x] P3-08 Add fixed/range repetitions, independent RIR, sets, load, and rest inputs.
- [x] P3-09 Add program drafts, immutable versions, copying, and archiving.
- [x] P3-10 Complete animations for 30 compound exercises and thumbnails for the catalog.
- [x] P3-11 Verify catalog and program creation in airplane mode.
- [x] P3-12 Commit, push, open the pull request, and verify CI.
- Phase 3 validation record:
  [`docs/PHASE_3_VALIDATION.md`](PHASE_3_VALIDATION.md)

## Phase 4 — Active Workout and History

- [x] P4-01 Build the Today screen and session start flow.
- [x] P4-02 Add set-level repetition, load, RIR, and completion logging.
- [x] P4-03 Show previous performance beside the current prescription.
- [x] P4-04 Add strength, technique, pain, time, equipment, and interruption outcomes.
- [x] P4-05 Add rest timers, background notifications, and quick load editing.
- [x] P4-06 Restore active sessions after process termination.
- [x] P4-07 Calculate separate set, exercise, and session statuses.
- [x] P4-08 Build history, set details, and personal-record views.
- [x] P4-09 Correct historical entries through revisions instead of destructive edits.
- [x] P4-10 Complete airplane-mode and process-recovery tests.
- [x] P4-11 Produce the workout MVP APK. **Build C2**
- [x] P4-12 Commit, push, open the pull request, and verify CI.
- Phase 4 validation record:
  [`docs/PHASE_4_VALIDATION.md`](PHASE_4_VALIDATION.md)

## Phase 5 — Adaptive Programming and Availability Engine

- [x] P5-01 Build onboarding for goals, experience, equipment, session length, and day preferences.
- [x] P5-02 Add a conservative two-to-four-week calibration block.
- [x] P5-03 Implement weekly availability windows with fixed and flexible periods.
- [x] P5-04 Generate programs from volume, recovery, equipment, and schedule constraints.
- [x] P5-05 Propose a safe replacement window for a missed session.
- [x] P5-06 Implement bounded increase, hold, and decrease rules.
- [x] P5-07 Propose the smallest available load increase after two qualifying exposures.
- [x] P5-08 Hold after an isolated miss and reduce only after repeated performance misses.
- [x] P5-09 Keep time and equipment interruptions out of performance failure streaks.
- [x] P5-10 Stop progression and show safety guidance when pain is reported.
- [x] P5-11 Require sufficient data before plateau or deload recommendations.
- [x] P5-12 Explain what changed, why, which data triggered it, and how to undo it.
- [x] P5-13 Add accept, reject, edit, and undo flows for recommendations.
- [x] P5-14 Complete golden-persona and twelve-week simulation tests.
- [x] P5-15 Produce the adaptive-programming beta APK. **Build C3**
- [x] P5-16 Commit, push, open the pull request, and verify CI.
- Phase 5 validation record:
  [`docs/PHASE_5_VALIDATION.md`](PHASE_5_VALIDATION.md)

## Phase 6 — Measurements, Personalized Anatomy, and Progress

- [x] P6-01 Add height, weight, torso, and left/right limb measurements.
- [x] P6-02 Add optional body-fat value and measurement-method fields.
- [x] P6-03 Add measurement guidance, reference points, and validation.
- [x] P6-04 Create bounded regional morph targets from body measurements.
- [x] P6-05 Clamp morph values to artist-validated visual ranges.
- [x] P6-06 Label the result as a visual estimate rather than a medical scan.
- [x] P6-07 Show trained-muscle, weekly-volume, and fatigue heatmaps.
- [x] P6-08 Add measurement, volume, load, repetition, and estimated-strength trends.
- [x] P6-09 Add comparison and export for measurement history.
- [x] P6-10 Complete morph-boundary and visual-regression tests.
- [x] P6-11 Produce the anatomy alpha APK. **Build C4**
- [x] P6-12 Commit, push, open the pull request, and verify CI.
- Phase 6 validation record:
  [`docs/PHASE_6_VALIDATION.md`](PHASE_6_VALIDATION.md)

## Phase 7 — Modern UX Redesign and Simplicity Reset

P6 review showed that the app is functional but too primitive, too long, and
too hard to understand. Phase 7 keeps the completed local engine and rebuilds
the experience around compact, modern, high-quality task flows.

- [x] P7-01 Define the modern UX quality bar, app map, and screen-by-screen redesign acceptance criteria.
- [x] P7-02 Upgrade the design system to compact premium cards, status chips, progress rings, motion tokens, and dense form components.
- [x] P7-03 Refactor app navigation so root tabs are dashboards and complex tasks open focused routes, sheets, or step flows.
- [x] P7-04 Rebuild onboarding and setup as a short guided wizard for goal, experience, equipment, availability, and measurement preferences.
- [x] P7-05 Rebuild Today as a daily coach dashboard with next workout, streak, weekly consistency, pending recommendation, and quick start.
- [x] P7-06 Rebuild the active workout screen as a focused set-by-set flow with one primary action, compact previous performance, quick edits, and rest state.
- [x] P7-07 Rebuild Program as a hub with active-plan overview, training-day cards, recommendation inbox, and separate edit routes.
- [x] P7-08 Rebuild program creation as a guided builder with catalog search, day editing, exercise ordering, prescription editing, and clear publish review.
- [x] P7-09 Rebuild the exercise catalog and detail screens with compact filters, strong media hierarchy, muscle chips, substitutions, and add-to-program actions.
- [x] P7-10 Rebuild Anatomy as a visual-first screen with overlay heatmap controls, tap-to-inspect regions, compact measurement prompts, and visible estimate disclosure.
- [x] P7-11 Rebuild Progress as a compact progress path with streaks, milestones, personal records, trends, and measurement comparison cards.
- [x] P7-12 Add local consistency streaks, milestones, and non-social achievement feedback without changing training progression rules.
- [x] P7-13 Rewrite core Turkish and English microcopy for shorter labels, clearer empty states, and action-first coaching language.
- [x] P7-14 Complete UX golden tests, large-text checks, touch-target checks, and screenshot review for the redesigned primary flows.
- [x] P7-15 Produce the modern UX preview APK. **Build C4.5**
- [ ] P7-16 Commit, push, open the pull request, and verify CI.
- Phase 7 UX review record:
  [`docs/PHASE_7_UX_REVIEW.md`](PHASE_7_UX_REVIEW.md)
- Phase 7 validation record:
  [`docs/PHASE_7_VALIDATION.md`](PHASE_7_VALIDATION.md)

## Phase 8 — Content Quality, Notifications, and Personal Release

- [ ] P8-01 Complete short 3D animations for all 120 foundational exercises.
- [ ] P8-02 Verify start/end poses and equipment contact for every animation.
- [ ] P8-03 Prepare muscle mappings and movement form for qualified trainer review.
- [ ] P8-04 Add workout reminders and time-zone handling.
- [ ] P8-05 Add user-approved calendar insertion without broad calendar access.
- [ ] P8-06 Request notification permission only after the first program is created.
- [ ] P8-07 Complete screen-reader, large-text, keyboard, and touch-target testing.
- [ ] P8-08 Complete Turkish/English overflow and unit-conversion testing.
- [ ] P8-09 Complete startup, runtime, and 3D memory optimization.
- [ ] P8-10 Add encrypted backup export and restore.
- [ ] P8-11 Finalize the product name, repository name, and permanent application identifier.
- [ ] P8-12 Produce a signed release-candidate APK and AAB. **Build C5**
- [ ] P8-13 Commit, push, open the pull request, tag, and publish the release.

## Phase 9 — Consumer Expansion: Explicit Cost Gate

This phase is outside the zero-cost personal release and requires a new approval before work begins.

- [ ] P9-01 Define privacy policy, data deletion, export, and account lifecycle requirements.
- [ ] P9-02 Re-evaluate backend provider, operating cost, and service limits.
- [ ] P9-03 Add accounts and multi-device synchronization through an outbox model.
- [ ] P9-04 Complete conflict, tombstone, idempotency, and two-device tests.
- [ ] P9-05 Add optional Health Connect integration.
- [ ] P9-06 Add optional busy/free calendar access with explicit consent.
- [ ] P9-07 Add production crash and ANR monitoring and a store testing track.
- [ ] P9-08 Complete qualified training and health-safety review.
- [ ] P9-09 Produce the store release AAB. **Build C6**
- [ ] P9-10 Commit, push, open the pull request, tag, and publish the release.

## Build Checkpoints

| Checkpoint | Deliverable | Phase |
| --- | --- | --- |
| C0 | Installable project skeleton APK | 0 |
| C1 | Profileable anatomy spike APK | 2 |
| C2 | Offline workout MVP APK | 4 |
| C3 | Adaptive-programming beta APK | 5 |
| C4 | Personalized anatomy alpha APK | 6 |
| C4.5 | Modern UX preview APK | 7 |
| C5 | Signed personal release APK/AAB | 8 |
| C6 | Consumer store release AAB | 9 |
