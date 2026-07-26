# Decision Log

## Record Format

Each decision records its identifier, date, status, context, choice, consequences, and any superseded decision.

## D-001 — Platform Strategy

- Date: 2026-07-06
- Status: Accepted
- Decision: Build Android first with a shared architecture that can support iOS.
- Consequence: Shared product and domain code remains portable; platform integrations use explicit adapters.

## D-002 — Application Framework

- Date: 2026-07-06
- Status: Accepted
- Decision: Use Flutter and Dart for the application, Riverpod for state and dependency management, GoRouter for navigation, and Drift over SQLite for local persistence.
- Consequence: The personal release can remain offline-first while preserving a cross-platform path.

## D-003 — Anatomy Rendering

- Date: 2026-07-06
- Status: Accepted
- Decision: Use GLB/glTF assets with Filament platform renderers and a typed Flutter bridge.
- Consequence: The renderer is platform-specific while anatomy semantics and product behavior remain shared.

## D-004 — Program Adaptation

- Date: 2026-07-06
- Status: Accepted
- Decision: Use a deterministic, versioned rules engine and schedule constraint solver.
- Consequence: Recommendations remain testable, explainable, offline, and reproducible.

## D-005 — Repetitions and RIR

- Date: 2026-07-06
- Status: Accepted
- Decision: Model fixed/ranged repetitions independently from optional RIR tracking.
- Consequence: Fixed-repetition prescriptions can still capture effort when the user enables it.

## D-006 — Recommendation Approval

- Date: 2026-07-06
- Status: Accepted
- Decision: Require user confirmation for load, set, exercise, and schedule changes.
- Consequence: The system never silently rewrites the active program.

## D-007 — Personal Release Cost Boundary

- Date: 2026-07-06
- Status: Accepted
- Decision: Keep the personal release local-only with no paid services or required backend.
- Consequence: Accounts and multi-device synchronization remain behind the Phase 9 cost gate.

## D-008 — Repository Publication

- Date: 2026-07-06
- Status: Accepted
- Decision: Publish the code repository under Apache-2.0 while tracking third-party assets under their own compatible terms.
- Consequence: Asset provenance and redistribution checks are mandatory before publication.

## D-009 — Audience and Localization

- Date: 2026-07-06
- Status: Accepted
- Decision: Target healthy adults aged 18 and over, with Turkish/English and metric/imperial support from the foundation phase.
- Consequence: Clinical and minor-user requirements remain out of scope for the personal release.

## D-010 — Working Product Name

- Date: 2026-07-06
- Status: Accepted
- Decision: Use Project Atlas as a temporary internal name.
- Consequence: Final branding and the permanent application identifier must be approved before the first store upload.

## D-011 — Temporary Application Identifier

- Date: 2026-07-06
- Status: Accepted
- Decision: Use `project_atlas` as the Dart package name and `app.projectatlas.personal` as the temporary Android and iOS application identifier.
- Consequence: Both identifiers remain non-production values and the application identifier must be replaced before the first store upload.

## D-012 — Foundation Packages

- Date: 2026-07-06
- Status: Accepted
- Decision: Use Riverpod for state and dependency management, GoRouter for declarative navigation, and Drift over SQLite for local relational persistence.
- Consequence: Platform-independent application logic is exposed through providers, navigation is URL-addressable, and database code is generated and verified in tests.
- Compatibility note: Keep development dependency `sqlparser` at `0.44.5` until the current Drift generator resolves successfully with a newer version.

## D-013 — Localization and Unit Storage

- Date: 2026-07-06
- Status: Accepted
- Decision: Use Flutter ARB localization with English and Turkish, store mass in kilograms, and store length in centimeters.
- Consequence: Device locale is used by default, tests can override locale and unit system through providers, and imperial values are converted only at system boundaries.

## D-014 — Continuous Integration Baseline

- Date: 2026-07-06
- Status: Accepted
- Decision: Run generated-source verification, formatting, static analysis, tests with coverage, and an Android debug build on every push and pull request using a read-only GitHub Actions workflow.
- Consequence: Stale generated files and quality regressions block integration; successful runs retain only coverage and a non-release debug APK for 14 days.

## D-015 — Design Token Baseline

- Date: 2026-07-07
- Status: Accepted
- Decision: Use explicit light/dark semantic colors, the platform system font, a four-pixel spacing scale, and shared component tokens through Material 3 themes.
- Consequence: Feature code avoids raw visual values, normal text roles remain testable at 4.5:1 contrast, controls start at 48 logical pixels, and no font asset or font license is added.

## D-016 — Primary Navigation Structure

- Date: 2026-07-07
- Status: Accepted
- Decision: Use five localized GoRouter branches inside a state-preserving indexed shell for Today, Program, Anatomy, Progress, and Settings.
- Consequence: Each feature receives a stable deep-link root and independent navigation history; selecting the active destination returns it to its root.

## D-017 — Core Relational Schema

- Date: 2026-07-07
- Status: Accepted
- Decision: Establish schema version 2 with profile-owned programs, workout sessions, ordered session sets, and measurement-history records; preserve workout history when a program is deleted.
- Consequence: Core relationships and lifecycle rules are enforced by SQLite, while program prescriptions, actual set logs, and detailed body measurements remain independently extensible.

## D-018 — Local-First Repository Boundary

- Date: 2026-07-07
- Status: Accepted
- Decision: Expose platform-independent repository contracts through Riverpod and keep Drift types inside local implementations; commit aggregate writes transactionally before emitting watch-stream state.
- Consequence: Features remain testable without a network or platform database API, partial aggregates are not observable, and a future synchronization layer can be added without replacing domain-facing contracts.

## D-019 — Migration and Recovery Verification

- Date: 2026-07-07
- Status: Accepted
- Decision: Validate every supported schema origin against clean current SQLite metadata and verify process recovery with file-backed committed and interrupted transactions.
- Consequence: Missing upgrade indexes, structural drift, data loss, and partial workout writes are detected before integration.

## D-020 — Backup and Portable Export Security

- Date: 2026-07-07
- Status: Accepted
- Decision: Exclude all local application data from uncontrolled platform backup and require explicit exports to use a versioned Argon2id and AES-256-GCM authenticated container.
- Consequence: Automatic backup and device transfer do not copy raw health records; portable recovery remains possible only through a user-controlled, passphrase-protected export with authenticated restore.

## D-021 — Anatomy Source Asset

- Date: 2026-07-08
- Status: Accepted
- Decision: Use the BodyParts3D 4.0 IS-A Tree OBJ dataset as the coordinated source for skeleton and muscle geometry.
- Consequence: Skeleton and muscle regions share one coordinate system and stable FMA/BodyParts3D mappings; processed distributions must preserve attribution, license links, modification notice, and source-to-output hashes. The current catalog license is recorded as CC-BY-4.0, while reviewed OBJ headers also contain an older CC-BY-SA-2.1-JP notice; processed geometry is handled conservatively with both notices until the publisher's intended precedence is clarified.

## D-022 — Anatomy Render Region Reduction

- Date: 2026-07-08
- Status: Accepted
- Decision: Reduce 166 BodyParts3D elements into 28 bilateral working groups, producing 56 independent render regions without reusing source geometry.
- Consequence: The spike stays within the 40-80 region budget and preserves unilateral picking and provenance; missing source coverage is recorded instead of being represented by anatomically incorrect substitute geometry.

## D-023 — Stable Muscle Region Identity

- Date: 2026-07-08
- Status: Accepted
- Decision: Identify every unilateral muscle region with an immutable lowercase ASCII semantic ID ending in `_right` or `_left`, while storing English and Turkish names as editable display data.
- Consequence: Renderer picking, exercise mappings, history, heatmaps, analytics, and exports can share stable identity without depending on source mesh names, numeric slots, or localized text.

## D-024 — Blender Anatomy Asset Pipeline

- Date: 2026-07-15
- Status: Accepted
- Decision: Use a Blender 5.1.2 command-line pipeline to read the external BodyParts3D source ZIP, extract the selected P2-02 elements, merge them into P2-03 semantic regions, clean and triangulate geometry, generate three GLB LODs, and validate output metadata before downstream renderer work.
- Consequence: P2 anatomy assets are reproducible from source without committing raw or processed binary geometry. GLB nodes expose stable semantic region IDs, the manifest records source and output hashes, and P2-05 can depend on GLB node names and extras rather than source OBJ filenames.

## D-025 — Android Anatomy Renderer Bridge

- Date: 2026-07-20
- Status: Accepted
- Decision: Register a Flutter Android platform view backed by a native Filament `SurfaceView`, expose renderer capabilities through a typed method channel, and keep actual anatomy GLB assets external until a later bundling gate.
- Consequence: Flutter can mount the anatomy renderer behind a stable view type while Android owns Engine, Renderer, Scene, Camera, swapchain, and frame-loop lifecycle. Interaction, GLB loading, picking, and heatmap highlighting can evolve behind the same Flutter navigation contract.

## D-026 — Anatomy Interaction Contract

- Date: 2026-07-20
- Status: Accepted
- Decision: Keep gesture interpretation, fallback interaction, and product state in Flutter while Android applies bounded camera pose, semantic selection, normalized picking, and heatmap state for the registered Filament platform view.
- Consequence: Rotation, zoom, tap selection, and heatmap preview are testable without a native renderer, while Android remains the owner of platform rendering state. Because the runtime GLB is not bundled yet, native picking and heatmap highlighting use deterministic semantic IDs until later asset packaging binds the same contract to GLB mesh hits and materials.

## D-027 — Anatomy Asset Budget Gate

- Date: 2026-07-20
- Status: Accepted
- Decision: Enforce anatomy GLB file size, geometry, primitive draw-call upper bound, material count, and license metadata budgets in CI before any processed runtime anatomy asset can be bundled.
- Consequence: Processed GLB files cannot enter the repository without an anatomy pipeline manifest and matching legal metadata. The current P2-04 reference outputs remain below the P2-08 limits, and future pipeline or asset changes must either stay within the budgets or document an explicit re-budgeting decision.

## D-028 — Shared Rig and Prototype Exercise Clips

- Date: 2026-07-20
- Status: Accepted
- Decision: Define P2 exercise animation work as a source-level shared humanoid rig and ten loopable keyframe prototypes using semantic muscle IDs and bounded high-level controls, without committing motion-capture files or binary runtime animation assets.
- Consequence: Exercise animation behavior can be validated in CI before final mesh skinning and artist cleanup. Later animation work can bind the same controls to runtime clips while preserving stable muscle-region references and avoiding unlicensed motion assets.

## D-029 — Anatomy Renderer Performance Fallback

- Date: 2026-07-20
- Status: Accepted
- Decision: Default the anatomy screen to a Flutter semantic fallback after the P2-07 mid-range Android measurement missed launch and frame-pacing thresholds; keep native Filament profiling available only through an explicit `interactive_lite` runtime override using `lod2`.
- Consequence: Normal builds avoid mounting the native platform view until bundled assets and device measurements meet the threshold. The fallback preserves camera, heatmap, and semantic selection behavior, while the Android renderer uses a dirty-frame loop when native profiling is requested.

## D-030 — Foundational Exercise Inventory Identity

- Date: 2026-07-20
- Status: Accepted
- Decision: Define the initial exercise catalog as 120 immutable lowercase ASCII IDs with Turkish and English display names in a versioned inventory-only JSON contract.
- Consequence: Program prescriptions, animation expansion, search, filters, and future history records can reference stable exercise IDs before detailed categories, muscle mappings, instructions, or media assets are added. P3-01 planning groups are internal coverage buckets and must not be treated as final product categories.

## D-031 — Exercise Category Contract Separation

- Date: 2026-07-20
- Status: Accepted
- Decision: Store P3-02 movement-pattern and broad muscle-region categories in a separate versioned JSON contract that references the P3-01 exercise inventory and P2 semantic muscle ontology.
- Consequence: Catalog navigation and future filters can use stable category IDs without mutating exercise identity records. Broad muscle categories stay distinct from the P3-05 primary, secondary, and stabilizer activation maps, and P3-03 equipment, level, laterality, and exercise-type metadata remain separately owned.

## D-032 — Exercise Filter Contract Separation

- Date: 2026-07-20
- Status: Accepted
- Decision: Store equipment, level, laterality, and exercise-type filters in a separate P3-03 JSON contract that references the P3-01 inventory and P3-02 category contract.
- Consequence: Catalog search and future program-builder filters can compose identity, category, and filter data without overloading a single exercise record. Filter assignments remain distinct from instructional content, detailed muscle activation maps, prescribed-set data, and media-review state.

## D-033 — Exercise Content Contract Separation

- Date: 2026-07-20
- Status: Accepted
- Decision: Store original setup, execution, form-cue, common-error, substitution, and regression content in a separate P3-04 JSON contract that references the inventory, category, and filter contracts.
- Consequence: Exercise details can resolve complete localized content for every foundational exercise while preserving stable identity, category, and filter contracts. Detailed muscle activation maps, program prescriptions, thumbnails, animation bindings, license records, and review state remain independently owned by later checklist items.

## D-034 — Exercise Muscle Mapping Contract Separation

- Date: 2026-07-20
- Status: Accepted
- Decision: Store primary, secondary, and stabilizer muscle-region mappings in a separate P3-05 JSON contract using side-qualified P2 semantic muscle region IDs.
- Consequence: Catalog details, anatomy heatmaps, future volume summaries, and exercise analytics can share stable region identifiers without mixing muscle mappings into identity, category, filter, or content records. The P3-05 verification is structural and does not replace the later qualified trainer review gate.

## D-035 — Local Exercise Catalog Composition

- Date: 2026-07-20
- Status: Accepted
- Decision: Bundle the P3 catalog JSON contracts and P2 muscle ontology as local read-only metadata, compose them into an immutable app model through Riverpod, and expose the first catalog UI from the Program branch with a nested exercise-detail route.
- Consequence: Search, filters, list cards, and detail sections work offline from the canonical contracts without introducing a backend or duplicating the 120-exercise inventory in Dart constants. The Program branch can add builder workflows in P3-07 while preserving the same exercise identity and detail route.

## D-036 — Manual Program Builder Draft Boundary

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P3-07 as a local in-memory program draft inside the Program branch, with Builder and Catalog tabs sharing the same exercise catalog identity model.
- Consequence: Program creation, training-day editing, exercise selection, and exercise ordering can be tested before prescription inputs and persistence are added. P3-08 remains responsible for sets, repetitions, RIR, load, and rest; P3-09 remains responsible for draft persistence, immutable versions, copying, and archiving.

## D-037 — Manual Prescription Input Boundary

- Date: 2026-07-20
- Status: Accepted
- Decision: Add P3-08 prescription inputs to the in-memory program builder as exercise-level targets with fixed or ranged repetitions, optional RIR, optional load, set count, and rest duration.
- Consequence: The builder can capture a complete local exercise prescription before persistence is introduced. Fixed repetitions are stored as equal minimum and maximum repetitions, RIR stays independently optional, load remains normalized to kilograms, and P3-09 remains responsible for saving drafts and publishing immutable versions.

## D-038 â€” Program Version Snapshot Persistence

- Date: 2026-07-20
- Status: Accepted
- Decision: Persist manual program builder changes by creating complete version snapshots through the repository layer, including version-scoped training-day names and expanded prescribed-set rows.
- Consequence: Saving or publishing never rewrites earlier program versions. Published versions retire previous active versions for the same program, copied programs restart as local drafts with new persisted identity on save, and archived programs preserve their immutable version history.

## D-039 — Procedural Catalog Media and Compound Animation Contract

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P3-10 exercise media as original procedural thumbnail metadata for all 120 catalog exercises plus a 30-exercise compound source-level animation contract that reuses the P2 shared rig.
- Consequence: The catalog can display thumbnails and animation availability without bundling third-party image files or runtime animation binaries. Final 120-exercise runtime animations, artist review, and equipment-contact review remain Phase 7 responsibilities.

## D-040 — Airplane-Mode Catalog and Builder Boundary

- Date: 2026-07-20
- Status: Accepted
- Decision: Treat P3 airplane-mode acceptance as an application-level no-network boundary: local catalog assets must be present and bundled, catalog browsing must work with Dart network client creation blocked, and the manual builder must create a draft and add a catalog exercise without network access.
- Consequence: Catalog and manual program creation stay compatible with offline personal use. Save, publish, copy, and archive behavior remains covered by the P3-09 local persistence lifecycle tests, while P3-12 remains responsible for the phase commit, push, pull request, and CI verification.

## D-041 — Today Session Start Boundary

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P4-01 as a Today-screen local session-start flow that reads the active published program version, lets the user select a training day before the scheduling engine exists, and stores the selected prescription as an `inProgress` workout session with planned session-set slots.
- Consequence: Active workout execution starts from immutable program-version data without adding a new schema or synchronization dependency. Set-level actual logging, previous-performance display, session status calculation, timers, recovery, and history remain explicitly deferred to later Phase 4 checklist items.

## D-042 — Active Set Logging Transaction Boundary

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P4-02 set completion as a single local repository transaction that updates the session-set status to `completed` and appends the matching actual-set log revision.
- Consequence: The active workout UI can record actual repetitions, load, and optional RIR without adding schema or backend dependencies. Completed set slots and actual result logs remain consistent, while previous-performance context, interruption outcomes, rest timers, session rollups, and historical correction revisions stay assigned to later Phase 4 checklist items.

## D-043 — Previous Performance Read Model

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P4-03 previous-performance context as a repository read model over local workout sessions, session sets, and actual set logs, excluding the active session and selecting the latest actual-log revision for each historical set slot.
- Consequence: The active workout screen can show previous same-exercise performance beside the current prescription without schema changes or session-completion dependencies. Matching is set-order based for this slice; broader history views, session status rollups, and correction management remain later Phase 4 responsibilities.

## D-044 — Active Set Outcome Logging

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P4-04 as an active-set outcome selector that writes the selected strength, technique, pain, time, equipment, or external-interruption outcome to the append-only actual-set log.
- Consequence: Numeric set results and non-numeric limitations share the same local transaction and history read path. Outcome-only logs are allowed for interrupted sets, while progression interpretation, pain guidance, rest timers, session rollups, and historical correction management remain assigned to later checklist items.

## D-045 — Active Rest Timer and Quick Load Boundary

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P4-05 rest timers as volatile active-workout state derived from prescribed rest seconds, with a native Android method-channel bridge for best-effort background alerts while the app process is alive.
- Consequence: Rest countdowns and notifications do not require schema changes and do not affect progression rules yet. Quick load controls adjust only the pending actual-load input; the repository records a value only through the existing set-completion transaction. Process-restored timers, session rollups, and history correction remain later Phase 4 responsibilities.

## D-046 — Active Workout Process Recovery

- Date: 2026-07-20
- Status: Accepted
- Decision: Restore P4-06 active workout execution from the local database by loading an existing `inProgress` session, its set slots, latest actual logs, and linked prescription when the Today controller starts.
- Consequence: A restarted app can continue the same active workout without losing completed set evidence or showing the wrong source training day. Recovery remains schema-free, rest countdowns stay volatile, and session status rollups plus history correction remain later Phase 4 responsibilities.

## D-047 — Active Workout Execution Statuses

- Date: 2026-07-20
- Status: Accepted
- Decision: Calculate P4-07 set, exercise, and session execution statuses as non-persisted application read-model values derived from set lifecycle, linked prescription, latest actual log, and outcome.
- Consequence: Set-level target misses, interruptions, and pain reports can be surfaced separately from exercise and session status without changing the database schema or overwriting append-only logs. Session status can require review without automatically marking the whole workout failed, while progression interpretation remains assigned to later rules.

## D-048 — Workout History and Personal Record Read Model

- Date: 2026-07-20
- Status: Accepted
- Decision: Implement P4-08 history, set detail, and personal-record views as a Progress-branch read model over local sessions, session sets, linked prescriptions, and latest actual-log revisions.
- Consequence: Historical review stays offline and schema-free while preserving append-only correction semantics. Personal records are recalculated from clean latest logs and exclude limiting outcomes; editing historical entries remains assigned to P4-09.

## D-049 — Append-Only Historical Corrections

- Date: 2026-07-20
- Status: Accepted
- Decision: Correct historical set results by appending a new `actual_set_logs` revision for the same session set and linking it to the previous latest log through `supersedesLogId`.
- Consequence: The Progress screen can fix incorrect historical repetitions, load, RIR, or outcome without destructive edits. Latest-revision read models update immediately, while earlier evidence remains available in revision history for later rule review and export.

## D-050 — Phase 4 Resilience Acceptance

- Date: 2026-07-20
- Status: Accepted
- Decision: Verify Phase 4 workout execution, history review, and historical correction with application-level airplane-mode tests and file-backed process-recovery tests.
- Consequence: Session start, set logging, Progress history, append-only corrections, and personal-record recalculation are proven local-only and recoverable before the workout MVP build checkpoint. Rest-timer replay and completed-session lifecycle remain separate later tasks.

## D-051 — Adaptive Onboarding Preference Boundary

- Date: 2026-07-21
- Status: Accepted
- Decision: Store P5-01 onboarding as one local profile-scoped preference row containing goal, experience level, available equipment, preferred session length, and preferred weekdays.
- Consequence: Later calibration, availability, and generator features can read stable local inputs without inferring them from workout history. Saving onboarding creates the local profile if needed, but does not generate or change a training program.

## D-052 — Conservative Calibration Read Model

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement the P5-02 calibration block as a deterministic read model derived from onboarding preferences, lasting two to four weeks with reduced volume, minimum RIR guardrails, experience-based session caps, no load increases, and explicit exit requirements.
- Consequence: The app can preview a safe starting block before schedule solving or program generation exists. Calibration remains non-mutating in this step, so later Phase 5 rules must explicitly create recommendations before any program or prescription changes.

## D-053 — Weekly Availability Window Boundary

- Date: 2026-07-21
- Status: Accepted
- Decision: Store P5-03 weekly availability as profile-scoped recurring windows with weekday, fixed or flexible period type, start minute, and end minute.
- Consequence: Future schedule solving can distinguish hard availability from flexible placement ranges without inferring time windows from preferred days alone. Saving availability remains non-mutating for programs and sessions until later recommendation and scheduling checklist items.

## D-054 — Deterministic Program Draft Planner

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-04 as a deterministic local planner that converts onboarding preferences, the conservative calibration block, saved weekly availability, and bundled exercise catalog constraints into an editable Program builder draft.
- Consequence: The app can create an initial structured program without network services or silent activation. The planner respects volume, recovery spacing, equipment, and schedule bounds, while save, publish, missed-session replacement, progression changes, and recommendation review remain separate user-controlled checklist items.

## D-055 — Missed-Session Replacement Preview

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-05 as a deterministic preview that proposes the earliest spare weekly availability window after a missed generated program day while preserving goal-specific recovery spacing around remaining planned sessions.
- Consequence: Missed-session handling becomes explainable and local without silently moving workouts. The result remains presentation state only; persistence, acceptance, editing, undo, and calendar/session mutation remain assigned to later recommendation review and scheduling work.

## D-056 — Bounded Load Progression Rule

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-06 as a deterministic domain rule that turns an explicit increase, hold, or decrease request into a bounded loaded-prescription proposal using equipment increments, maximum percentage changes, and a minimum load floor.
- Consequence: Later progression features can reuse one guarded load-change boundary instead of duplicating percentage caps and rounding rules. The rule remains non-mutating and does not yet decide qualification, miss streaks, interruption filtering, pain handling, persistence, or review actions.

## D-057 — Smallest Load Increase After Two Qualifying Exposures

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-07 as a deterministic domain rule that proposes one smallest available load increment only when the two most recent matching exposures for an exercise qualify, then routes the change through the bounded progression rule.
- Consequence: Load increases now require repeatable evidence before a recommendation candidate exists. The rule remains non-mutating and does not skip recent non-qualifying evidence; holds, reductions, interruption streak filtering, pain guidance, persistence, and review actions remain assigned to later Phase 5 items.

## D-058 — Isolated Miss Hold and Repeated Miss Decrease

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-08 as a deterministic domain rule that holds after no data, non-miss latest evidence, or one isolated performance miss, and proposes a bounded decrease only after the two most recent matching exposures are both performance misses.
- Consequence: One bad exposure cannot reduce a prescription, while repeated misses can create a conservative decrease candidate. The rule consumes pre-classified signals and remains non-mutating; raw outcome filtering, pain handling, persistence, explanations, and review actions remain assigned to later Phase 5 items.

## D-059 — Interruption Filtering for Performance Failure Streaks

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-09 as a deterministic progression signal classifier that converts raw set evidence into target-met, performance-miss, or not-comparable signals while keeping time, equipment, and external interruptions out of performance-failure streaks.
- Consequence: Interrupted exposures cannot trigger a repeated-miss load reduction even when their numeric results are low. The classifier remains non-mutating, and pain safety guidance, persistence, explanations, and review actions remain assigned to later Phase 5 items.

## D-060 — Pain Progression Guard

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-10 as a deterministic domain guard that detects pain outcomes in matching exercise exposure evidence, blocks loaded progression for that exercise, and returns typed safety guidance while delegating the unchanged load result to the bounded progression hold path.
- Consequence: Pain is handled as a safety state rather than a performance miss or earned reduction trigger. The guard remains non-mutating and does not persist safety state, change program versions, create recommendation-review records, or prescribe rehabilitation.

## D-061 — Plateau and Deload Data Gate

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-11 as a deterministic domain gate that allows future plateau checks only after four comparable matching exposures across at least 21 days, and future deload checks only after three comparable matching exposures across at least 14 days, while requiring the latest matching exposure to be comparable.
- Consequence: Plateau and deload recommendations cannot be inferred from one-off performance, stale history, pain, interruptions, or missing evidence. The gate remains non-mutating and does not diagnose plateaus, recommend deloads, persist recommendation state, change program versions, or implement explanation and review flows.

## D-062 — Recommendation Explanation Envelope

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-12 as a deterministic explanation envelope that converts existing adaptive recommendation candidates into typed change summaries, reason codes, triggering evidence references, and undo metadata without applying the candidate.
- Consequence: Future review surfaces can explain what would change, why it was proposed, which data triggered it, and what previous load should be restored if an accepted load change is undone. The envelope remains non-mutating and does not persist recommendation state, localize final copy, apply changes, or implement accept, reject, edit, and undo flows.

## D-063 — Recommendation Review Flow State Machine

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-13 as a deterministic in-memory review state machine that opens explained adaptive recommendation candidates and supports accept, reject, load edit, and undo actions against copied prescription state.
- Consequence: Recommendation review behavior is now testable before durable recommendation persistence or UI wiring. Accepted load changes update only the copied prescription, rejected candidates leave it unchanged, edits replace the proposed load before acceptance, and undo restores the previous load only after an accepted load change.

## D-064 — Golden-Persona Twelve-Week Simulation Coverage

- Date: 2026-07-21
- Status: Accepted
- Decision: Implement P5-14 as test-only golden-persona coverage that runs three synthetic twelve-week adaptive programming histories through the Phase 5 domain rules.
- Consequence: Clean progression, repeated-miss with interruption, and pain-safety behavior are verified as integrated flows before the adaptive-programming beta APK build. The coverage remains non-mutating and does not introduce runtime simulation engines, persisted fixtures, durable recommendation state, or program-version publishing.

## D-065 — Build C3 Adaptive-Programming Beta APK

- Date: 2026-07-21
- Status: Accepted
- Decision: Produce Build C3 as a development-only Android debug APK that packages Phase 5 adaptive onboarding, calibration, weekly availability, generated program drafts, missed-session replacement previews, bounded progression, recommendation explanation and review rules, and golden-persona simulation coverage.
- Consequence: The adaptive-programming beta can be installed and tested without release signing or external services. The APK artifact stays excluded from source control, while durable recommendation persistence, program-version publication from recommendations, branch publication, pull request creation, and CI verification remain separate work.

## D-066 — Body Measurement Storage Fields

- Date: 2026-07-21
- Status: Accepted
- Decision: Extend measurement events with nullable height, weight, torso, and side-specific limb fields stored in kilograms and centimeters.
- Consequence: Existing measurement records migrate forward without synthetic values, while later Phase 6 work can build guidance, body-fat metadata, visual estimates, and trends on a stable local schema. These fields remain separate from load progression decisions.

## D-067 — Body-Fat and Measurement Method Metadata

- Date: 2026-07-21
- Status: Accepted
- Decision: Extend measurement events with nullable body-fat percentage, body-measurement method, and body-fat measurement method fields.
- Consequence: Existing measurement records migrate forward without inferred body-fat values or method labels. Future progress and anatomy estimate features can preserve provenance for tape, scale, caliper, impedance, visual-estimate, imported, or other measurement inputs without using these fields as direct load-progression triggers.

## D-068 — Measurement Guidance and Validation Boundary

- Date: 2026-07-21
- Status: Accepted
- Decision: Define field-level measurement guidance, reference points, broad warning ranges, method-metadata warnings, side-to-side warnings, and blocking repository validation in a schema-free core measurement contract.
- Consequence: New measurement writes reject unusable events without adding database columns. Warning-level issues remain available for later presentation review, while measurement guidance and validation do not trigger program generation, scheduling, progression, pain, plateau, or recommendation changes.

## D-069 — Bounded Regional Body Morph Signals

- Date: 2026-07-21
- Status: Accepted
- Decision: Derive in-memory regional morph target signals from validated body measurements, bounded to `[-1, 1]` and keyed by stable P2 anatomy region identifiers.
- Consequence: Body measurements can now drive deterministic anatomy estimate inputs without persisting morph state or mutating renderer state. These morph signals remain separate from training progression and health classification, and P6-05 maps them into bounded visual ranges before renderer use.

## D-070 — Body Morph Visual Range Clamps

- Date: 2026-07-21
- Status: Accepted
- Decision: Map P6-04 normalized morph target signals into target-specific minimum, neutral, and maximum visual multipliers through a versioned in-memory range contract.
- Consequence: Renderer-facing anatomy estimates receive bounded visual values without adding database columns, storing derived morph state, or changing training progression. Missing visual ranges are reported explicitly instead of silently applying fallback deformations.

## D-071 — Body Visual Estimate Disclosure

- Date: 2026-07-21
- Status: Accepted
- Decision: Label personalized anatomy output as a measurement-based visual estimate rather than a medical scan through a versioned disclosure contract and visible anatomy-screen copy.
- Consequence: The anatomy experience can personalize visuals while explicitly avoiding diagnostic, scan, exam, or medical-assessment claims. The label preserves validation and missing-range state, adds no database columns, and does not affect training progression.

## D-072 — Training-Derived Anatomy Heatmaps

- Date: 2026-07-21
- Status: Accepted
- Decision: Derive trained-muscle, weekly-volume, and fatigue anatomy heatmaps in memory from completed local workout sets, latest actual-log revisions, and bundled exercise-catalog muscle mappings.
- Consequence: The Anatomy screen can visualize recent training distribution without adding database schema, storing derived analytics, changing prescriptions, or creating medical/recovery diagnoses. Heatmaps reuse the existing renderer `setHeatmap` contract with normalized P2 semantic muscle-region scores.

## D-073 — Progress Trend Read Model

- Date: 2026-07-21
- Status: Accepted
- Decision: Derive Progress-screen measurement, volume, load, repetition, and estimated-strength trends in memory from local measurement records, completed clean set logs, and latest actual-log revisions.
- Consequence: Progress trends can show local changes without adding schema, persisting analytics, mutating history, or bypassing Phase 5 recommendation rules. Estimated strength remains display-only and must not be treated as a true max test, diagnosis, or automatic progression trigger.

## D-074 — Measurement History Comparison and Report Copy

- Date: 2026-07-21
- Status: Accepted
- Decision: Derive Progress-screen measurement-history comparisons and copyable CSV/JSON report text in memory from local measurement records.
- Consequence: Users can review first-to-latest body-measurement changes, latest left/right circumference differences, and copy a measurement report without adding schema, writing plaintext files, creating restore/import behavior, or exposing `profile_id`. The feature remains separate from the encrypted backup container planned for P8-10.

## D-075 — Morph Boundary and Visual Regression Coverage

- Date: 2026-07-21
- Status: Accepted
- Decision: Complete P6-10 as automated test coverage for morph boundary values, visual range interpolation, deterministic clamped morph snapshots, and visual-estimate disclosure layout anchors.
- Consequence: The personalized anatomy estimate contracts are now protected against unbounded numeric output, accidental visual multiplier drift, missing-height fallback regressions, and disclosure layout regressions without adding schema, renderer mesh deformation, screenshot artifacts, or training-rule behavior.

## D-076 — Build C4 Personalized Anatomy Alpha APK

- Date: 2026-07-21
- Status: Accepted
- Decision: Produce Build C4 as a development-only Android debug APK that opens to the Anatomy branch and packages Phase 6 measurement storage, body-fat provenance, measurement guidance, bounded morph targets, visual range clamps, visual-estimate disclosure, training heatmaps, Progress trends, measurement-history comparison, report copy, and morph-boundary coverage.
- Consequence: The personalized anatomy alpha can be installed and tested without release signing or external services. The APK artifact stays excluded from source control, while renderer mesh deformation, reviewed runtime GLB packaging, encrypted backup restore, branch publication, pull request creation, and CI verification remain separate work.

## D-077 — Modern UX Simplicity Reset

- Date: 2026-07-26
- Status: Accepted
- Decision: Insert Phase 7 as a modern UX redesign before personal release, keeping the completed local engine while rebuilding root tabs as compact dashboards and moving complex tasks into focused routes, sheets, or guided step flows.
- Consequence: The next open checklist item remains P7-01, but P7 now starts with UX quality-bar and app-map work instead of exercise animation production. Content quality, notifications, encrypted export, signing, and release-candidate work move to Phase 8. Consumer expansion moves behind the Phase 9 cost gate.

## D-078 — Phase 7 UX Acceptance Bar

- Date: 2026-07-26
- Status: Accepted
- Decision: Define P7-01 as a documentation gate that establishes measurable UX thresholds, a focused app map, and screen-by-screen acceptance criteria before rebuilding Phase 7 screens.
- Consequence: Later Phase 7 implementation work must prove compact root dashboards, short focused flows, one-handed workout logging, localized copy fit, accessibility, and offline behavior before each redesigned screen can be marked complete.

## D-079 — Modern Component Foundation

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-02 as a reusable presentation component layer with compact dashboard cards, status chips, progress rings, dense form sections, dense text fields, and shared motion tokens.
- Consequence: Later Phase 7 screens can rebuild around consistent compact cards, state chips, progress indicators, focused edit surfaces, and controlled motion without changing local data contracts, navigation structure, progression rules, measurement rules, or renderer behavior.

## D-080 — Dashboard Root and Focused Route Split

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-03 by keeping the five primary destinations as dashboard roots and moving complex workout, Program, catalog, Progress, and Settings tasks into focused child routes.
- Consequence: Root tabs are no longer long editing surfaces. Existing local behavior remains available under child routes, while later Phase 7 items can redesign each focused flow without changing repository contracts, schema, progression rules, measurement rules, or renderer behavior.

## D-081 — Guided Setup Wizard

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-04 by replacing the long Settings setup page with a compact guided wizard for goal, experience, equipment, weekly availability, measurement preference, and final review.
- Consequence: Setup now saves onboarding preferences and weekly availability through the existing local repositories while keeping measurement preference as non-persisted UI state for this flow. The change adds no database schema, progression-rule change, generated-program mutation, or measurement-value write.

## D-082 — Today Daily Coach Dashboard

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-05 by rebuilding the Today root as a daily coach dashboard with a next-workout mission, root-level quick start or resume, local streak, weekly consistency, and a compact review queue card.
- Consequence: Today now derives streak and weekly consistency from local completed workout sessions and the active program's training-day count without persisting analytics or changing training progression. The review queue card is a schema-free status surface until durable recommendation inbox storage exists, while the focused active-workout route remains the existing set-logging surface for P7-06.

## D-083 — Focused Active Workout Route

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-06 by rebuilding `/today/workout` as a focused set-by-set route that shows one editable current set, compact previous performance, quick load/repetition/RIR edits, one complete-set action, visible rest state, and a compact status queue for non-focused sets.
- Consequence: Active workout execution becomes one-handed and less cluttered without changing database schema, repository transactions, progression rules, rest-timer semantics, or outcome handling. Program selection and start controls stay outside the active-session state because Today root now owns daily workout entry.

## D-084 — Program Active Plan Hub

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-07 by rebuilding the Program root as a read-only hub with active-plan overview, compact training-day cards, recommendation inbox entry, and separate route cards for builder and catalog work.
- Consequence: Program navigation becomes easier to scan without changing program persistence, publication, prescription editing, catalog data, recommendation rules, or schema. Inline editing remains outside the root and continues through the existing focused child routes.

## D-085 - Guided Program Builder

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-08 by rebuilding `/program/builder` as a guided five-step creation flow for setup, training days, catalog search and ordering, prescription targets, and publish review.
- Consequence: Manual program creation becomes more compact and reviewable without changing the draft controller, persisted program schema, catalog contract, prescription model, or progression rules. Publishing now requires a presentation-layer confirmation before the existing immutable-version write is executed.

## D-086 - Modern Exercise Catalog and Detail

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-09 by rebuilding `/program/catalog` and `/program/exercise/:exerciseId` with compact filter discovery, media-led cards, muscle chips, substitution chips, and direct add-to-program actions.
- Consequence: Exercise discovery becomes faster and more program-oriented without changing the canonical catalog JSON contracts, exercise media contract, persisted program schema, or progression rules. Add-to-program writes only to the existing local builder draft state.

## D-087 - Visual-First Anatomy Review

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-10 by rebuilding the Anatomy root around a large first-position anatomy viewport, overlay heatmap controls, tap-to-inspect selected-region feedback, compact missing-measurement guidance, and a visible visual-estimate disclosure.
- Consequence: Anatomy becomes easier to scan without changing the native renderer bridge, semantic muscle IDs, measurement schema, morph-boundary rules, training heatmap derivation, or medical-safety disclosure contract. Missing-measurement prompting is presentation-only and depends on whether saved records contain usable positive measurement values.

## D-088 - Compact Progress Path Dashboard

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-11 by rebuilding the Progress root as a compact path dashboard with local streak and seven-day consistency indicators, milestone chips, personal-record preview, trend preview, and measurement-comparison preview.
- Consequence: Progress becomes easier to scan without changing workout history storage, append-only correction behavior, personal-record derivation, progress-trend rules, measurement-history export, or training progression. Streaks and milestones are presentation-only summaries derived from existing local read models; durable achievement feedback remains scoped to P7-12.

## D-089 - Local Achievement Feedback Read Model

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-12 as a shared local achievement feedback read model for completed-workout streaks, seven-day consistency, local milestones, and compact non-social feedback labels.
- Consequence: Today and Progress now use the same local derivation for streak and milestone feedback without adding achievement storage, points, social comparison, notification triggers, schema changes, or training-progression inputs.

## D-090 - Concise Core Microcopy

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-13 by rewriting core Turkish and English labels, helper text, empty states, and coaching copy around short action-first language for Today, Program, Builder, Catalog, Anatomy, Progress, and Profile.
- Consequence: The redesigned surfaces use shorter labels and clearer next actions while preserving conservative safety, pain, visual-estimate, export, and progression language. The Settings route remains technically compatible, but user-facing navigation now uses Profile.

## D-091 - P7 UX Golden and Accessibility Review

- Date: 2026-07-26
- Status: Accepted
- Decision: Implement P7-14 with deterministic golden baselines for stable primary redesigned states, route-level 2.0 text-scale checks, broader primary-action touch-target checks, and a documented screenshot review matrix.
- Consequence: The modern UX preview can proceed with automated coverage for the main dashboards and active workout. Program builder and catalog child routes remain covered by focused widget tests until the later P8 accessibility and overflow pass hardens screenshot capture for input-heavy child routes.

## D-092 - Modern UX Preview Build C4.5

- Date: 2026-07-27
- Status: Accepted
- Decision: Produce P7-15 as a development-only Android debug APK that opens to the redesigned Today dashboard and packages the completed modern UX preview slice through P7-14.
- Consequence: The APK can be installed for local review without release signing, external services, account synchronization, store-ready identifiers, or durable recommendation storage. Publication, pull request creation, and CI verification remain scoped to P7-16.
