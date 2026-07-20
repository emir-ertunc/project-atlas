# Anatomy Rig and Animation Prototype

## Purpose

P2-09 defines a shared humanoid rig contract and short source-level animation
prototypes for ten core exercises. This step does not commit binary animation,
motion-capture, GLB, FBX, or Blender files. The output is a validated source
contract that later asset work can convert into runtime clips.

## Files

- Rig contract:
  [`shared_humanoid_rig.v1.json`](../tool/anatomy/animation/shared_humanoid_rig.v1.json)
- Ten-exercise animation set:
  [`core_exercise_animation_prototypes.v1.json`](../tool/anatomy/animation/core_exercise_animation_prototypes.v1.json)
- Thirty-exercise compound animation set:
  [`compound_exercise_animation_prototypes.v1.json`](../tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json)
- Validator:
  [`validate_animation_contract.py`](../tool/anatomy/animation/validate_animation_contract.py)

## Shared Rig Contract

The shared rig uses:

- Meters as the unit.
- Y-up coordinates.
- A neutral humanoid rest pose with pelvis, spine, head, bilateral upper-limb,
  and bilateral lower-limb joints.
- Twenty-five bounded animation controls for root position, trunk position,
  hip, knee, ankle, shoulder, elbow, forearm, scapula, grip width, and bar
  height.
- Equipment anchors for floor, barbell, bench, pull-up bar, dumbbells, and
  cable handle.
- Muscle-region bindings that reference stable P2-03 semantic region IDs.

The control layer is intentionally higher-level than final renderer bones. It
keeps exercise clips portable while the final mesh skinning and artist cleanup
remain future work.

## Prototype Exercises

| Exercise ID | Pattern | Primary purpose |
| --- | --- | --- |
| `barbell_back_squat` | Squat | Bilateral lower-body flexion and extension |
| `barbell_deadlift` | Hinge | Hip hinge and posterior-chain extension |
| `barbell_bench_press` | Horizontal push | Chest, anterior shoulder, and elbow extension |
| `standing_overhead_press` | Vertical push | Shoulder flexion and elbow extension |
| `bent_over_barbell_row` | Horizontal pull | Scapular retraction and elbow flexion |
| `pull_up` | Vertical pull | Vertical pulling and body elevation |
| `push_up` | Horizontal push | Bodyweight press pattern |
| `reverse_lunge` | Single-leg squat | Unilateral lower-body prototype |
| `dumbbell_biceps_curl` | Elbow flexion | Isolation elbow flexion |
| `cable_triceps_pushdown` | Elbow extension | Isolation elbow extension |

Every prototype is a two-second loop at 30 FPS. The first and last keyframes
match exactly so a renderer can loop clips without a visible snap. Each
exercise declares setup, finish, movement pattern, equipment, contact anchors,
and primary/secondary semantic muscle regions.

## P3-10 Compound Exercise Extension

P3-10 adds 30 compound or bodyweight-compound source-level exercise animations
using the same shared rig. The extension covers squat, hinge, hip extension,
horizontal push, vertical push, horizontal pull, vertical pull, and single-leg
squat patterns.

The 30-exercise set is a contract-level animation source. It contains bounded
keyframes, phase tags, contact anchors, thumbnail pose phases, equipment
references, and muscle-region references. It does not bundle motion-capture
files, Blender files, FBX files, GLB files, or runtime animation binaries.

The catalog media contract binds these 30 animation IDs to exercise records and
assigns procedural thumbnails to all 120 foundational exercises.

## Validation

The local and CI validator checks:

- Rig schema version and versioned rig ID.
- Unique joints, bones, controls, and equipment anchors.
- Control defaults and keyframe values are inside declared limits.
- Rig muscle bindings reference valid P2-03 region IDs.
- The animation set points to the shared rig.
- Exactly ten exercise prototypes are present.
- At least six movement patterns are covered.
- Every exercise has English and Turkish display names.
- Primary and secondary muscle IDs are valid and non-empty.
- Contact anchors exist in the shared rig.
- Keyframes are strictly increasing, start at `0.0`, end at `cycle_seconds`,
  and form a loop.

Run locally:

```bash
python tool/anatomy/animation/validate_animation_contract.py \
  --rig tool/anatomy/animation/shared_humanoid_rig.v1.json \
  --animations tool/anatomy/animation/core_exercise_animation_prototypes.v1.json \
  --ontology tool/anatomy/muscle_region_ontology.v1.json
```

Expected success output:

```text
ANIMATION_CONTRACT_OK rig_controls=25 exercises=10
```

Run the P3-10 compound extension locally:

```bash
python tool/anatomy/animation/validate_animation_contract.py \
  --rig tool/anatomy/animation/shared_humanoid_rig.v1.json \
  --animations tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json \
  --ontology tool/anatomy/muscle_region_ontology.v1.json \
  --expected-exercise-count 30
```

Expected success output:

```text
ANIMATION_CONTRACT_OK rig_controls=25 exercises=30
```

## Downstream Contract

P2-09 is not final animation content. Later phases must:

- Bind the source controls to the final mesh rig.
- Add artist review and cleanup.
- Verify start/end poses and equipment contact per exercise.
- Export runtime clips only after license, size, and performance gates pass.
- Expand from ten prototypes to the full exercise catalog animation set.

No third-party motion data is used in this step.
