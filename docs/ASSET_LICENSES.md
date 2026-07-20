# Asset and License Register

## Document Status

- Status: BodyParts3D source, 56-region reduction, Blender GLB pipeline, and P3-10 procedural exercise media contracts selected; no binary anatomy or exercise media asset is bundled yet
- Code license target: Apache-2.0

## Asset Policy

- Every binary or source asset must have verified distribution rights before entering the repository.
- Assets with non-commercial, no-derivatives, or unknown terms are rejected.
- Share-alike assets require an explicit compatibility review and separate tracking.
- Legally required copyright, license, and source notices are preserved.
- Runtime packages include only the minimum files needed by the application.

## Required Asset Metadata

- Stable asset identifier
- Repository path
- Asset type and purpose
- Source URL
- Copyright holder or author
- License identifier and version
- Required attribution text
- Source and processed-file hashes
- Modification summary
- Redistribution and modification permissions
- Review date and reviewer

## Asset Inventory

| Asset ID | Path | Source | License | Attribution | Hash | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `anatomy-source-bodyparts3d-v4-isa-obj99` | Not bundled; external source archive | [BodyParts3D IS-A OBJ archive](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/isa_BP3D_4.0_obj_99.zip) | Current catalog: `CC-BY-4.0`; embedded OBJ notice retained conservatively: `CC-BY-SA-2.1-JP` | BodyParts3D, © The Database Center for Life Science licensed under CC Attribution 4.0 International; BodyParts3D, (c) The Database Center for Life Science licensed under CC Attribution-Share Alike 2.1 Japan | `sha256:40665852c49f218326590e204db91064a1ecfc3c6f8cbd7bbbcaac62c7cd409e` | Source selected; 56-region reduction mapped; GLB pipeline validated; processed outputs remain external |

| `exercise-media-procedural-p3-10` | `tool/exercise_catalog/foundational_exercise_media.v1.json`; `tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json` | Original procedural thumbnail metadata and source-level keyframe contract | Project source distribution | No third-party attribution required | `sha256:c904e0e6dfd3b40f3c3e71fb895bc7d626367f5a01029082b98a15c9b991d72b`; `sha256:214343fbce9a9a6302c2b932de468b6401ced98fdc5cdcf1a6968419991edd44` | P3-10 complete; no binary image, motion-capture, Blender, FBX, GLB, or runtime animation asset bundled |

The selected archive and its required metadata are documented in
[the anatomy source selection record](ANATOMY_ASSET_SELECTION.md). Raw source
archives remain outside the repository. Any processed asset introduced later
must receive its own inventory row, repository path, processed-file hash, and
modification summary before it is committed.

The current official BodyParts3D catalog license page lists `CC-BY-4.0`.
Reviewed OBJ headers in the source archive also contain an older
`CC-BY-SA-2.1-JP` notice. Until the publisher's intended precedence is
clarified, processed geometry must preserve both attribution records and be
treated as a share-alike asset for repository review and distribution planning.

The P2-04 processing contract and validated GLB output hashes are recorded in
[the anatomy Blender pipeline](ANATOMY_PIPELINE.md).

P2-09 adds only source-level rig and keyframe JSON contracts for prototype
exercise animation. No third-party motion-capture file, Blender file, FBX, GLB,
or other binary animation asset is bundled in that step.

P3-10 adds original procedural thumbnail metadata for all 120 foundational
exercises and source-level keyframe contracts for 30 compound exercises. The
Flutter catalog renders thumbnails procedurally at runtime, so no third-party
image file is committed.

## Active Validation

- Fail validation when a bundled asset has no manifest entry.
- Fail validation for missing hashes or required attribution.
- Reject forbidden license categories.
- Validate GLB files and enforce geometry and file-size budgets.

The active P2-08 budget gate is recorded in
[the anatomy asset budgets](ANATOMY_ASSET_BUDGETS.md). CI validates the budget
contract on every run and scans the repository for committed GLB/glTF files
that lack an anatomy pipeline manifest.
