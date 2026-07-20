# Anatomy Asset Budgets

## Purpose

P2-08 adds CI-enforced budgets for processed anatomy GLB assets before any
runtime anatomy binary is committed. The gate covers file size, geometry,
primitive draw-call upper bounds, material count, and required license
metadata.

The budget contract is stored in
[`anatomy_asset_budgets.v1.json`](../tool/anatomy/anatomy_asset_budgets.v1.json)
and validated by
[`validate_asset_budgets.py`](../tool/anatomy/validate_asset_budgets.py).

## CI Behavior

CI runs:

```bash
python3 tool/anatomy/validate_asset_budgets.py \
  --budget tool/anatomy/anatomy_asset_budgets.v1.json \
  --scan-repository .
```

The validator always checks the budget file and its reference P2-04 output
metadata. It also scans the repository for committed `.glb` or `.gltf` files,
ignoring generated build/cache directories. If a runtime anatomy GLB is added
later, CI requires an adjacent `anatomy_pipeline_manifest.json` and enforces
the same budgets against the manifest and any available GLB JSON metadata.

P2-07 remains the physical-device runtime measurement gate. P2-08 is the static
asset budget and legal metadata gate.

## Budget Limits

| LOD | Max size | Max vertices | Max triangles | Max primitive draw-call upper bound | Max materials |
| --- | ---: | ---: | ---: | ---: | ---: |
| `lod0` | 75,000,000 bytes | 2,700,000 | 900,000 | 56 | 1 |
| `lod1` | 37,000,000 bytes | 1,350,000 | 450,000 | 56 | 1 |
| `lod2` | 15,000,000 bytes | 540,000 | 180,000 | 56 | 1 |

The draw-call budget is an upper bound derived from GLB primitive count. It is
not a replacement for P2-07 runtime frame measurement because renderer backend,
materials, device driver behavior, and future batching can change actual frame
cost.

## Reference P2-04 Outputs

| LOD | Size | Vertices | Triangles | Primitive draw-call upper bound | Materials |
| --- | ---: | ---: | ---: | ---: | ---: |
| `lod0` | 70,850,448 bytes | 2,590,701 | 863,688 | 56 | 1 |
| `lod1` | 34,956,104 bytes | 1,294,618 | 431,582 | 56 | 1 |
| `lod2` | 13,766,432 bytes | 517,252 | 172,434 | 56 | 1 |

These reference values are intentionally below the CI limits. If a future
pipeline change increases any value beyond the limit, the change must either be
optimized or explicitly re-budgeted with a documented reason.

## Required License Metadata

Every bundled anatomy asset manifest must preserve:

- Current catalog license: `CC-BY-4.0`
- Conservative embedded geometry license: `CC-BY-SA-2.1-JP`
- Source license URL:
  `https://dbarchive.biosciencedbc.jp/data/bodyparts3d/`
- Required attribution text containing:
  - `The Database Center for Life Science`
  - `CC Attribution 4.0 International`
  - `CC Attribution-Share Alike 2.1 Japan`
- A modification summary with at least six explicit processing steps

If GLB files are available beside the manifest, the validator also checks GLB
asset copyright metadata for the required attribution text.

## Failure Policy

CI must fail when:

- A committed anatomy GLB lacks a pipeline manifest.
- A manifest lacks required LODs.
- A LOD exceeds file size, vertex, triangle, primitive, or material limits.
- Required license or attribution metadata is missing.
- A committed GLB hash differs from its manifest entry.
- A GLB JSON chunk is malformed or omits required indexed triangle geometry.
