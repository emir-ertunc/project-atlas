# Asset and License Register

## Document Status

- Status: BodyParts3D source, 56-region reduction, and Blender GLB pipeline selected; no binary anatomy asset is bundled yet
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

## Active Validation

- Fail validation when a bundled asset has no manifest entry.
- Fail validation for missing hashes or required attribution.
- Reject forbidden license categories.
- Validate GLB files and enforce geometry and file-size budgets.

The active P2-08 budget gate is recorded in
[the anatomy asset budgets](ANATOMY_ASSET_BUDGETS.md). CI validates the budget
contract on every run and scans the repository for committed GLB/glTF files
that lack an anatomy pipeline manifest.
