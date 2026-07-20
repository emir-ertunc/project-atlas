# Anatomy Blender Pipeline

## Purpose

P2-04 creates a repeatable pipeline that converts the reviewed BodyParts3D
source archive into cleaned, unilateral muscle-region GLB files for renderer
spike work. The pipeline is a source-processing tool only; no raw BodyParts3D
archive, source OBJ file, or processed GLB file is committed to the repository.

The implementation lives in:

- [`anatomy_pipeline.py`](../tool/anatomy/blender/anatomy_pipeline.py)
- [`run_pipeline.ps1`](../tool/anatomy/blender/run_pipeline.ps1)
- [`validate_outputs.py`](../tool/anatomy/blender/validate_outputs.py)
- [`pipeline_config.v1.json`](../tool/anatomy/blender/pipeline_config.v1.json)

## Required Inputs

| Input | Role |
| --- | --- |
| `isa_BP3D_4.0_obj_99.zip` | External BodyParts3D source archive; verified by SHA-256 before processing |
| `bodyparts3d_region_reduction.v1.json` | P2-02 source-element to render-region mapping |
| `muscle_region_ontology.v1.json` | P2-03 stable semantic muscle identifiers and names |
| `pipeline_config.v1.json` | Cleanup, unit scale, material, LOD, and export settings |

The source archive must remain outside the repository. The current reviewed
archive hash is:

`sha256:40665852c49f218326590e204db91064a1ecfc3c6f8cbd7bbbcaac62c7cd409e`

## Toolchain

- Blender 5.1.2 is the validated command-line toolchain for P2-04.
- The PowerShell wrapper locates Blender, runs the Blender pipeline in
  background mode, and then runs the validator with Blender's bundled Python.
- The validator checks GLB structure, output hashes, LOD counts, region IDs,
  semantic node metadata, geometry counts, and required license records.

Example Windows command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File tool\anatomy\blender\run_pipeline.ps1 `
  -SourceArchive D:\ExternalAssetReview\P2-01\isa_BP3D_4.0_obj_99.zip `
  -OutputDirectory D:\ExternalAssetReview\P2-04\source_run `
  -BlenderExecutable 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
```

## Processing Steps

1. Verify the source archive hash against the P2-02 reduction manifest.
2. Verify the P2-02 reduction manifest hash against the P2-03 ontology.
3. Read only the selected OBJ files directly from the source ZIP.
4. Convert source coordinates from millimeters to meters.
5. Merge selected source elements within each unilateral semantic region.
6. Merge coincident vertices, remove degenerate geometry, delete loose
   vertices, recalculate normals, and triangulate faces.
7. Attach stable semantic metadata to each GLB node:
   `muscle_region_id`, `semantic_group_id`, `side`, `reduction_slot`, and
   `source_element_ids`.
8. Export three GLB LODs:
   - `lod0`: cleaned source topology
   - `lod1`: collapse-decimated to 50%
   - `lod2`: collapse-decimated to 20%
9. Write `anatomy_pipeline_manifest.json` with input hashes, output hashes,
   geometry counts, primitive draw-call upper bounds, material counts, license
   records, source coverage gaps, and region metadata.
10. Validate the generated GLBs and manifest before any downstream use.

This is automated cleanup and topology normalization. It is not a final
artist-authored retopology pass. If P2-07 or P2-08 performance budgets fail,
P2-10 must decide whether to add stronger LODs, a fallback asset, or a separate
manual retopology pass.

## Validated P2-04 Outputs

The final P2-04 source run produced 56 semantic muscle-region nodes in each
GLB. The run was repeated with identical hashes for all GLBs and the manifest.

| File | Size | Vertices | Triangles | SHA-256 |
| --- | ---: | ---: | ---: | --- |
| `project_atlas_muscles_lod0.glb` | 70,850,448 bytes | 2,590,701 | 863,688 | `f04e11b43f292d5c624e689b31cf79df17e9f08abc569fd4704aa48f06c3c40b` |
| `project_atlas_muscles_lod1.glb` | 34,956,104 bytes | 1,294,618 | 431,582 | `b5e7d2ce57785d31b3f7695b277601523e7cddea1ba0c05d5483ae6bebc891ae` |
| `project_atlas_muscles_lod2.glb` | 13,766,432 bytes | 517,252 | 172,434 | `87fcbc078f9d1c8f069fd4ff1c7c96b4a2a0f533d3dfe1fe621d94ae750016f2` |

P2-08 adds CI budgets above these values. The current primitive draw-call upper
bound is 56 per LOD and the material count is 1 per LOD.

The manifest hash for the validated run is:

`sha256:8f09d58e6bd7c0dc787ef8898aa41cbca387db7d6242a73d094defe344f832a3`

## License Handling

The current official BodyParts3D catalog page lists Creative Commons
Attribution 4.0 International (`CC-BY-4.0`). Reviewed OBJ headers in the source
archive also contain an older Creative Commons Attribution-Share Alike 2.1
Japan notice. Until the publisher's intended precedence is clarified, the
pipeline treats processed geometry conservatively:

- Record the current catalog license as `CC-BY-4.0`.
- Record the embedded geometry notice as `CC-BY-SA-2.1-JP`.
- Embed both attribution strings in exported GLB asset metadata.
- Treat processed geometry as a share-alike asset for repository review and
  distribution planning.

Required attribution records:

- BodyParts3D, © The Database Center for Life Science licensed under CC
  Attribution 4.0 International
- BodyParts3D, (c) The Database Center for Life Science licensed under CC
  Attribution-Share Alike 2.1 Japan

## Downstream Contract

P2-05 exposes GLB node names and `muscle_region_id` extras as the renderer
identity contract through [the Android anatomy renderer bridge](ANATOMY_RENDERER_BRIDGE.md).
The renderer must not depend on source OBJ filenames, localized display names,
numeric slots, or mesh ordering.

P2-08 converts the measured P2-04 size and geometry counts into CI budgets
before any processed GLB is bundled in the application. The active budget
contract is recorded in [the anatomy asset budgets](ANATOMY_ASSET_BUDGETS.md).
