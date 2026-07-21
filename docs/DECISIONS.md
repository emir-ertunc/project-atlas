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
- Consequence: Accounts and multi-device synchronization remain behind the Phase 8 cost gate.

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
