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
