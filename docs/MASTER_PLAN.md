# Project Atlas Master Plan

## Working Protocol

- Complete one checklist item per user command unless the user explicitly groups tasks.
- Read `AGENTS.md` and the documents relevant to the active item before editing.
- Do not begin the next item automatically.
- Mark an item complete only after its acceptance checks pass.
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
- [ ] P0-12 Push the phase branch, open a pull request, and verify green CI.

## Phase 1 — Design System and Local Data Core

- [ ] P1-01 Define accessible colors, typography, spacing, and component tokens.
- [ ] P1-02 Create the main navigation: Today, Program, Anatomy, Progress, and Settings.
- [ ] P1-03 Implement accessibility foundations for contrast, type scaling, and touch targets.
- [ ] P1-04 Create the Drift schema for profiles, programs, sessions, sets, and measurements.
- [ ] P1-05 Separate program versions, prescribed sets, and actual set logs.
- [ ] P1-06 Create repository interfaces and the local-first data flow.
- [ ] P1-07 Add database migration and process-recovery tests.
- [ ] P1-08 Exclude sensitive files from device backups and design encrypted export.
- [ ] P1-09 Run phase validation and update the technical documentation.
- [ ] P1-10 Commit, push, open the pull request, and verify CI.

## Phase 2 — Anatomy and Asset Technical Spike

- [ ] P2-01 Select redistributable skeleton and muscle source assets.
- [ ] P2-02 Reduce the source anatomy into 40–80 meaningful left/right muscle regions.
- [ ] P2-03 Define stable semantic muscle identifiers and Turkish/English names.
- [ ] P2-04 Create the Blender cleanup, retopology, LOD, and GLB export pipeline.
- [ ] P2-05 Create the Android Filament renderer and Flutter platform bridge.
- [ ] P2-06 Implement rotation, zoom, picking, and muscle heatmap highlighting.
- [ ] P2-07 Measure load time, frame rate, and memory on a mid-range Android device.
- [ ] P2-08 Add CI budgets for GLB size, geometry, draw calls, and license metadata.
- [ ] P2-09 Create a shared rig and short animation prototype for ten core exercises.
- [ ] P2-10 Apply LOD or fallback behavior if performance thresholds are missed.
- [ ] P2-11 Produce the profileable anatomy APK. **Build C1**
- [ ] P2-12 Commit, push, open the pull request, and verify CI.

## Phase 3 — Exercise Catalog and Manual Program Builder

- [ ] P3-01 Define the inventory for 120 foundational exercises.
- [ ] P3-02 Add muscle-region and movement-pattern categories.
- [ ] P3-03 Add equipment, level, laterality, and exercise-type filters.
- [ ] P3-04 Write original instructions, form cues, common errors, and substitutions.
- [ ] P3-05 Verify primary, secondary, and stabilizer muscle mappings.
- [ ] P3-06 Build catalog search, filters, list, and exercise detail screens.
- [ ] P3-07 Build program creation, training-day editing, and exercise ordering.
- [ ] P3-08 Add fixed/range repetitions, independent RIR, sets, load, and rest inputs.
- [ ] P3-09 Add program drafts, immutable versions, copying, and archiving.
- [ ] P3-10 Complete animations for 30 compound exercises and thumbnails for the catalog.
- [ ] P3-11 Verify catalog and program creation in airplane mode.
- [ ] P3-12 Commit, push, open the pull request, and verify CI.

## Phase 4 — Active Workout and History

- [ ] P4-01 Build the Today screen and session start flow.
- [ ] P4-02 Add set-level repetition, load, RIR, and completion logging.
- [ ] P4-03 Show previous performance beside the current prescription.
- [ ] P4-04 Add strength, technique, pain, time, equipment, and interruption outcomes.
- [ ] P4-05 Add rest timers, background notifications, and quick load editing.
- [ ] P4-06 Restore active sessions after process termination.
- [ ] P4-07 Calculate separate set, exercise, and session statuses.
- [ ] P4-08 Build history, set details, and personal-record views.
- [ ] P4-09 Correct historical entries through revisions instead of destructive edits.
- [ ] P4-10 Complete airplane-mode and process-recovery tests.
- [ ] P4-11 Produce the workout MVP APK. **Build C2**
- [ ] P4-12 Commit, push, open the pull request, and verify CI.

## Phase 5 — Adaptive Programming and Availability Engine

- [ ] P5-01 Build onboarding for goals, experience, equipment, session length, and day preferences.
- [ ] P5-02 Add a conservative two-to-four-week calibration block.
- [ ] P5-03 Implement weekly availability windows with fixed and flexible periods.
- [ ] P5-04 Generate programs from volume, recovery, equipment, and schedule constraints.
- [ ] P5-05 Propose a safe replacement window for a missed session.
- [ ] P5-06 Implement bounded increase, hold, and decrease rules.
- [ ] P5-07 Propose the smallest available load increase after two qualifying exposures.
- [ ] P5-08 Hold after an isolated miss and reduce only after repeated performance misses.
- [ ] P5-09 Keep time and equipment interruptions out of performance failure streaks.
- [ ] P5-10 Stop progression and show safety guidance when pain is reported.
- [ ] P5-11 Require sufficient data before plateau or deload recommendations.
- [ ] P5-12 Explain what changed, why, which data triggered it, and how to undo it.
- [ ] P5-13 Add accept, reject, edit, and undo flows for recommendations.
- [ ] P5-14 Complete golden-persona and twelve-week simulation tests.
- [ ] P5-15 Produce the adaptive-programming beta APK. **Build C3**
- [ ] P5-16 Commit, push, open the pull request, and verify CI.

## Phase 6 — Measurements, Personalized Anatomy, and Progress

- [ ] P6-01 Add height, weight, torso, and left/right limb measurements.
- [ ] P6-02 Add optional body-fat value and measurement-method fields.
- [ ] P6-03 Add measurement guidance, reference points, and validation.
- [ ] P6-04 Create bounded regional morph targets from body measurements.
- [ ] P6-05 Clamp morph values to artist-validated visual ranges.
- [ ] P6-06 Label the result as a visual estimate rather than a medical scan.
- [ ] P6-07 Show trained-muscle, weekly-volume, and fatigue heatmaps.
- [ ] P6-08 Add measurement, volume, load, repetition, and estimated-strength trends.
- [ ] P6-09 Add comparison and export for measurement history.
- [ ] P6-10 Complete morph-boundary and visual-regression tests.
- [ ] P6-11 Produce the anatomy alpha APK. **Build C4**
- [ ] P6-12 Commit, push, open the pull request, and verify CI.

## Phase 7 — Content Quality, Notifications, and Personal Release

- [ ] P7-01 Complete short 3D animations for all 120 foundational exercises.
- [ ] P7-02 Verify start/end poses and equipment contact for every animation.
- [ ] P7-03 Prepare muscle mappings and movement form for qualified trainer review.
- [ ] P7-04 Add workout reminders and time-zone handling.
- [ ] P7-05 Add user-approved calendar insertion without broad calendar access.
- [ ] P7-06 Request notification permission only after the first program is created.
- [ ] P7-07 Complete screen-reader, large-text, keyboard, and touch-target testing.
- [ ] P7-08 Complete Turkish/English overflow and unit-conversion testing.
- [ ] P7-09 Complete startup, runtime, and 3D memory optimization.
- [ ] P7-10 Add encrypted backup export and restore.
- [ ] P7-11 Finalize the product name, repository name, and permanent application identifier.
- [ ] P7-12 Produce a signed release-candidate APK and AAB. **Build C5**
- [ ] P7-13 Commit, push, open the pull request, tag, and publish the release.

## Phase 8 — Consumer Expansion: Explicit Cost Gate

This phase is outside the zero-cost personal release and requires a new approval before work begins.

- [ ] P8-01 Define privacy policy, data deletion, export, and account lifecycle requirements.
- [ ] P8-02 Re-evaluate backend provider, operating cost, and service limits.
- [ ] P8-03 Add accounts and multi-device synchronization through an outbox model.
- [ ] P8-04 Complete conflict, tombstone, idempotency, and two-device tests.
- [ ] P8-05 Add optional Health Connect integration.
- [ ] P8-06 Add optional busy/free calendar access with explicit consent.
- [ ] P8-07 Add production crash and ANR monitoring and a store testing track.
- [ ] P8-08 Complete qualified training and health-safety review.
- [ ] P8-09 Produce the store release AAB. **Build C6**
- [ ] P8-10 Commit, push, open the pull request, tag, and publish the release.

## Build Checkpoints

| Checkpoint | Deliverable | Phase |
| --- | --- | --- |
| C0 | Installable project skeleton APK | 0 |
| C1 | Profileable anatomy spike APK | 2 |
| C2 | Offline workout MVP APK | 4 |
| C3 | Adaptive-programming beta APK | 5 |
| C4 | Personalized anatomy alpha APK | 6 |
| C5 | Signed personal release APK/AAB | 7 |
| C6 | Consumer store release AAB | 8 |
