# Exercise Catalog Plan

## Document Status

- Status: Phase 3 complete; catalog, manual program builder, media bindings,
  offline verification, branch publication, and CI verification recorded
- Initial catalog target: 120 foundational exercises
- Canonical inventory:
  [`foundational_exercises.v1.json`](../tool/exercise_catalog/foundational_exercises.v1.json)
- Canonical categories:
  [`foundational_exercise_categories.v1.json`](../tool/exercise_catalog/foundational_exercise_categories.v1.json)
- Canonical filters:
  [`foundational_exercise_filters.v1.json`](../tool/exercise_catalog/foundational_exercise_filters.v1.json)
- Canonical content:
  [`foundational_exercise_content.v1.json`](../tool/exercise_catalog/foundational_exercise_content.v1.json)
- Canonical muscle mappings:
  [`foundational_exercise_muscle_mappings.v1.json`](../tool/exercise_catalog/foundational_exercise_muscle_mappings.v1.json)
- Canonical media:
  [`foundational_exercise_media.v1.json`](../tool/exercise_catalog/foundational_exercise_media.v1.json)
- Canonical compound animation contract:
  [`compound_exercise_animation_prototypes.v1.json`](../tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json)

## P3-01 Inventory Scope

P3-01 defines stable exercise identity and localized names only. It does not
store product-facing categories, filter metadata, muscle mappings,
instructions, substitutions, thumbnails, animation bindings, or media licenses
inside the identity inventory. Those fields are kept in separate contracts as
their checklist items are implemented.

Every inventory entry contains:

- `display_order`
- stable lowercase ASCII `snake_case` `id`
- internal `inventory_group` used only to balance this planning list
- Turkish and English display names

The inventory contains the ten exercise IDs already used by the P2 animation
prototype contract, so later animation expansion can grow from the same stable
identity set.

## P3-01 Inventory Groups

| Planning group | Count |
| --- | ---: |
| Squat and knee-dominant | 12 |
| Hinge and posterior chain | 12 |
| Horizontal push | 12 |
| Vertical push | 8 |
| Horizontal pull | 12 |
| Vertical pull | 8 |
| Single-leg lower body | 10 |
| Hip and glute isolation | 8 |
| Arm isolation and dips | 14 |
| Calves and tibialis | 6 |
| Core | 12 |
| Loaded carry and conditioning | 6 |
| Total | 120 |

## P3-02 Category Scope

P3-02 adds a separate category contract for broad catalog navigation and future
filtering. The contract references the P3-01 exercise IDs and the P2 semantic
muscle ontology without mutating the identity inventory.

The category contract contains:

- 31 movement-pattern categories with Turkish and English names
- 15 broad muscle-region categories with Turkish and English names
- one category assignment record for each of the 120 foundational exercises
- semantic muscle group references from the P2 anatomy ontology

The P3-02 categories are intentionally broad. They do not define equipment,
level, laterality, exercise type, written instructions, substitutions,
thumbnails, animation bindings, media licenses, or primary/secondary/stabilizer
activation maps. Filter metadata is owned by P3-03; content, detailed muscle
mapping, and media remain owned by later P3 items.

### Movement Pattern Families

| Family | Movement pattern IDs |
| --- | --- |
| Lower-body compound | `squat`, `hinge`, `single_leg_squat`, `lateral_lunge`, `single_leg_hinge` |
| Lower-body isolation | `knee_extension`, `knee_flexion`, `hip_extension`, `hip_abduction`, `hip_adduction`, `hip_external_rotation` |
| Upper-body push | `horizontal_push`, `chest_fly`, `vertical_push`, `shoulder_abduction` |
| Upper-body pull | `horizontal_pull`, `shoulder_horizontal_abduction`, `vertical_pull`, `shoulder_extension` |
| Arms and ankle | `elbow_flexion`, `elbow_extension`, `ankle_plantar_flexion`, `ankle_dorsiflexion` |
| Core | `core_anti_extension`, `core_anti_lateral_flexion`, `core_anti_rotation`, `core_flexion`, `hip_flexion`, `core_rotation` |
| Work capacity | `loaded_carry`, `conditioning` |

### Muscle Region Categories

| Category ID | P2 semantic groups |
| --- | --- |
| `chest` | `pectoralis_major`, `pectoralis_minor`, `serratus_anterior` |
| `shoulders` | `deltoid_anterior`, `deltoid_lateral`, `deltoid_posterior`, `rotator_cuff` |
| `upper_back` | `trapezius`, `rhomboids`, `teres_major` |
| `spinal_erectors` | `erector_spinae` |
| `biceps` | `biceps_brachii`, `brachialis` |
| `triceps` | `triceps_brachii` |
| `forearms` | `forearm_flexors_pronators`, `forearm_extensors_supinators` |
| `glutes` | `gluteus_maximus`, `gluteus_medius_minimus`, `hip_external_rotators_deep` |
| `hip_adductors` | `hip_adductors` |
| `hip_flexors` | `iliopsoas` |
| `quadriceps` | `quadriceps` |
| `hamstrings` | `hamstrings` |
| `calves` | `gastrocnemius`, `soleus`, `fibularis` |
| `tibialis` | `tibialis_anterior` |
| `core` | `external_oblique`, `erector_spinae` |

## P3-03 Filter Scope

P3-03 adds a third versioned catalog contract for user-facing filters. The
filter contract references both the P3-01 inventory and the P3-02 category
contract, then assigns equipment, level, laterality, and exercise type to each
of the 120 foundational exercises.

The filter contract contains:

- 29 equipment filter values
- 4 level filter values: `beginner`, `novice`, `intermediate`, `advanced`
- 5 laterality filter values: `bilateral`, `unilateral`, `alternating`,
  `side_specific`, `not_applicable`
- 7 exercise-type filter values: `compound`, `isolation`,
  `bodyweight_compound`, `core_stability`, `core_dynamic`, `loaded_carry`,
  `conditioning`
- one filter assignment record for each foundational exercise

Filter records contain only:

- `exercise_id`
- `equipment_ids`
- `level_id`
- `laterality_id`
- `exercise_type_id`

They intentionally do not contain movement-pattern categories, broad
muscle-region categories, written instruction content, substitutions,
primary/secondary/stabilizer muscle-region activation maps, prescribed sets,
loads, repetitions, rest periods, thumbnails, animation bindings, media
licenses, or review status.

## P3-04 Content Scope

P3-04 adds a fourth versioned catalog contract for original movement content.
The content contract references the P3-01 inventory, P3-02 categories, and
P3-03 filters, then resolves every foundational exercise to:

- localized setup guidance
- localized execution guidance
- localized form cues
- localized common errors
- substitution exercise IDs
- regression exercise IDs

Instruction, cue, and error text is written as reusable movement-pattern
blocks. Each of the 120 exercise content records points to the movement-pattern
block defined by its P3-02 category assignment and adds exercise-specific
substitution and regression references. This keeps content maintainable while
still giving every exercise a complete resolved detail payload.

P3-04 content records intentionally do not define detailed
primary/secondary/stabilizer muscle-region activation maps, prescribed sets,
loads, repetitions, RIR, rest periods, thumbnails, animation bindings, media
license records, or content-review status.

## P3-05 Muscle Mapping Scope

P3-05 adds a fifth versioned catalog contract for detailed structural muscle
mapping. The contract references the P3-01 inventory, P3-02 categories, P3-03
filters, P3-04 content, and P2 semantic muscle ontology, then assigns every
foundational exercise to side-qualified:

- `primary_region_ids`
- `secondary_region_ids`
- `stabilizer_region_ids`

The mapping contract uses the 56 stable P2 muscle-region identifiers, not
localized names or broad P3-02 category labels. A reusable generator,
[`build_foundational_muscle_mappings.py`](../tool/exercise_catalog/build_foundational_muscle_mappings.py),
keeps the mapping file reproducible from movement-pattern templates and
exercise-specific overrides.

The P3-05 verification is structural and contract-level:

- every exercise has exactly one muscle mapping record
- every mapped region ID exists in the P2 ontology
- region roles do not overlap inside one exercise
- primary regions stay compatible with broad P3-02 muscle categories
- P2 animation prototype primary and secondary regions remain represented
- all 28 P2 semantic muscle groups are exercised somewhere in the catalog

This is not a qualified trainer review. P8-03 still owns external content and
movement-form review before a broader release.

## P3-06 Catalog Screen Scope

P3-06 adds the first application-facing, read-only catalog experience on top of
the P3-01 through P3-05 contracts. The Program branch now opens the exercise
catalog until the manual program builder is implemented in P3-07.

The application catalog model:

- loads the inventory, categories, filters, content, muscle mappings, and P2
  muscle ontology as local bundled JSON metadata;
- composes the separate contracts into one immutable 120-exercise view model;
- keeps the P3 contracts as the canonical catalog source instead of copying the
  exercise list into Dart constants;
- searches across exercise IDs, localized exercise names, metadata names,
  instruction text, form cues, common errors, and resolved muscle-region names;
- applies multi-select filters for movement pattern, broad muscle region,
  equipment, level, laterality, and exercise type;
- treats selections inside one filter group as OR matches and selections across
  different groups as AND constraints.

The user interface includes:

- a localized search field and result-count summary;
- horizontally scrollable filter chip rows for every P3-02 and P3-03 facet;
- exercise cards with movement, muscle-region, equipment, and level summaries;
- a nested detail route at `/program/exercise/:exerciseId`;
- detail sections for setup, execution, form cues, common errors,
  substitutions, regressions, and primary/secondary/stabilizer muscles;
- safe missing-exercise and catalog-load error states.

P3-06 intentionally does not add thumbnail or animation media. Those assets
remain owned by P3-10 and later media-review checkpoints.

## P7-09 Modern Catalog Presentation Scope

P7-09 rebuilds the application-facing catalog and exercise detail screens
without changing the canonical P3 contracts. The catalog still searches the same
local immutable metadata and uses the same movement, muscle, equipment, level,
laterality, and type filters.

The redesigned catalog UI contains:

- a compact search hero with result count;
- a bottom-sheet filter editor with active filter chips on the main page;
- media-led result cards using the existing procedural thumbnail painter and
  animation badge;
- muscle, equipment, level, and media-status summaries;
- direct add-to-program actions backed by the existing local program builder
  draft controller.

The redesigned detail UI contains:

- a large media hero before instruction text;
- primary muscle chips before setup and execution sections;
- compact metadata chips for level, type, equipment, and laterality;
- substitution and regression chips that keep the existing detail-route
  navigation;
- the same add-to-program action as the catalog result cards.

P7-09 does not add new exercise records, licensed media files, runtime GLB
animations, trainer-reviewed movement changes, schema changes, or progression
rules.

## P3-07 Manual Program Builder Scope

P3-07 adds the first manual program-building workflow on top of the local
catalog. The Program branch now exposes two tabs:

- Builder: creates and edits a local in-memory program draft.
- Catalog: preserves the P3-06 search, filter, list, and detail experience.

The builder model stores only:

- program draft name;
- ordered training days;
- selected training day;
- ordered exercise IDs for each training day.

The builder supports:

- creating a local program draft with one initial training day;
- renaming the program draft;
- adding, selecting, renaming, and deleting training days;
- adding exercises from the local catalog to the selected day;
- preventing duplicate exercise IDs inside the same training day;
- removing exercises from the selected day;
- reordering exercises with explicit move controls and reorderable list
  support.

P3-07 deliberately does not persist drafts, publish immutable program versions,
copy programs, or archive programs; those lifecycle behaviors remain owned by
P3-09.

## P3-08 Manual Prescription Input Scope

P3-08 expands each exercise in the local program draft from a bare exercise ID
into an ordered exercise prescription. The builder remains local and in-memory,
but every exercise row can now capture:

- set count;
- fixed repetitions, represented as equal minimum and maximum repetitions;
- ranged repetitions, represented as minimum and maximum repetitions;
- optional target RIR, independent from the fixed/ranged repetition mode;
- optional load stored internally in kilograms;
- rest duration stored in seconds.

The local controller normalizes inputs before they enter draft state:

- sets are clamped to 1-20;
- repetitions are clamped to 1-100 and maximum repetitions cannot be lower than
  minimum repetitions;
- RIR is optional and clamped to 0-10 when enabled;
- load is optional and cannot be negative;
- rest is clamped to 0-1200 seconds.

The UI shows a compact prescription summary for each exercise and supports
metric or imperial load entry through the existing unit system. P3-09 owns the
first persistence and lifecycle behavior for these draft prescriptions.

## P3-09 Program Lifecycle Persistence Scope

P3-09 persists builder drafts into the local Drift database without adding a
network account or synchronization layer.

The lifecycle model supports:

- local unsaved drafts;
- saved draft snapshots;
- published immutable versions;
- copied local drafts that clear the original persisted identity;
- archived programs that keep historical versions intact.

The snapshot graph contains:

- the stable program record;
- one numbered program version;
- ordered training-day name snapshots for that version;
- one prescribed-set row per expanded set target.

Saving a draft always creates a new draft version instead of mutating an older
version. Publishing creates a new active version and retires any earlier active
version for the same program. Empty editable program shells can be saved as
drafts when they contain at least one training day, while exercise targets can
be added later.

P3-09 does not add catalog thumbnails, animation bindings, media license
records, airplane-mode acceptance testing, commit, push, pull request, or CI
verification. Those remain owned by P3-10, P3-11, and P3-12.

## P3-10 Exercise Media and Compound Animation Scope

P3-10 adds the first media contract for the exercise catalog without adding
third-party image, motion-capture, Blender, FBX, GLB, or other binary media
files.

The media contract contains:

- one procedural thumbnail binding for every foundational exercise;
- one animation binding for each of 30 selected compound or bodyweight-compound
  exercises;
- one original procedural media license record;
- review status for every media row.

The 30 source-level animation records are stored in
[`compound_exercise_animation_prototypes.v1.json`](../tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json).
They reuse the P2 shared humanoid rig, P2 semantic muscle-region identifiers,
bounded rig controls, contact anchors, and loopable keyframe structure.

The selected animation set covers:

- squat;
- hinge;
- hip extension;
- horizontal push;
- vertical push;
- horizontal pull;
- vertical pull;
- single-leg squat.

The Flutter catalog model now loads media metadata with the rest of the local
catalog and verifies that every available animation binding references the
P3-10 compound animation contract. Catalog list cards and exercise detail
screens render thumbnails through a procedural Flutter painter, so the app has
visible catalog thumbnails without committing external image assets. Exercises
with available P3-10 animations show a play badge on the thumbnail.

P3-10 does not claim final artist-reviewed animation quality. P8-01 and P8-02
still own complete 120-exercise runtime animation coverage, start/end pose
review, equipment-contact review, and any final binary runtime exports.

## P3-11 Airplane-Mode Verification Scope

P3-11 adds automated airplane-mode acceptance coverage for the local catalog and
manual program builder. The verification blocks Dart `HttpClient` creation
during the tested flows, so any accidental runtime network dependency fails the
test immediately.

The test coverage verifies that:

- every local catalog asset path used by the catalog loader exists on disk;
- every local catalog asset path is still declared in `pubspec.yaml`;
- the local catalog contracts compose into the expected 120-exercise model;
- the Program Catalog tab opens while network clients are blocked;
- catalog search finds `barbell_bench_press` from local metadata;
- the catalog card renders its procedural thumbnail and animation badge;
- the Program Builder creates a local draft while network clients are blocked;
- the exercise picker adds `barbell_bench_press` from the same local catalog to
  the draft.

P3-11 intentionally does not add a backend, account layer, synchronization
service, connectivity permission, or external asset fetch. P3-09 already owns
the save, publish, copy, and archive lifecycle tests.

## P3-12 Phase Publication and Validation Scope

P3-12 closes Phase 3 with a pushed branch, draft pull request, local validation
run, Android debug build, and green CI checks. The validation record is stored
in [`PHASE_3_VALIDATION.md`](PHASE_3_VALIDATION.md).

Phase 3 is complete at the checklist level. Full 120-exercise runtime animation
exports, external movement review, notification work, adaptive programming, and
active workout logging remain explicitly deferred to later phases.

## Exercise Record Requirements

Every exercise requires:

- Stable identifier
- Turkish and English names
- Movement pattern category and exercise type
- Primary, secondary, and stabilizer muscles
- Equipment and difficulty
- Unilateral or bilateral designation
- Original setup and execution instructions
- Common mistakes and form cues
- Substitutions and regressions
- Default load increment metadata
- Thumbnail and animation identifiers
- Content review status
- Asset license references

## Per-Exercise Checklist Template

- [ ] Define metadata and stable identifier.
- [ ] Write Turkish and English content.
- [ ] Map muscles and substitutions.
- [ ] Create or approve thumbnail poses.
- [ ] Create or approve the short animation.
- [ ] Verify equipment contact and movement range.
- [ ] Record asset provenance and distribution rights.
- [ ] Complete content and movement review.

The 120 named exercise entries are defined in the P3-01 inventory contract,
their broad movement and muscle-region categories are defined in the P3-02
category contract, their first filter metadata is defined in the P3-03 filter
contract, and their setup, execution, form-cue, common-error, substitution, and
regression content is defined in the P3-04 content contract. Their detailed
primary, secondary, and stabilizer muscle-region maps are defined in the P3-05
muscle mapping contract. Each entry receives the remaining checklist items as
media and review phases are implemented.

## Content Rules

- Do not copy proprietary descriptions.
- Do not include assets with non-commercial, no-derivatives, or unknown terms.
- Keep movement instructions concise, neutral, and safety-aware.
- Use the same muscle ontology as the anatomy renderer.
