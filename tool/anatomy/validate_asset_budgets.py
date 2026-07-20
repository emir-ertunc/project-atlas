from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path
from typing import Any


GLB_MAGIC = b"glTF"
GLB_VERSION = 2
JSON_CHUNK_TYPE = 0x4E4F534A
IGNORED_SCAN_DIRECTORIES = {
    ".dart_tool",
    ".git",
    ".gradle",
    ".idea",
    "build",
    "__pycache__",
}


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate anatomy GLB budgets and bundled asset metadata."
    )
    parser.add_argument("--budget", required=True, type=Path)
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--asset-directory", type=Path)
    parser.add_argument("--scan-repository", type=Path)
    return parser.parse_args()


def _read_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"Expected JSON object: {path}")
    return value


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _read_glb_json(path: Path) -> dict[str, Any]:
    payload = path.read_bytes()
    if len(payload) < 20:
        raise ValueError(f"GLB is truncated: {path}")
    magic, version, declared_length = struct.unpack_from("<4sII", payload, 0)
    if magic != GLB_MAGIC or version != GLB_VERSION:
        raise ValueError(f"Invalid GLB header: {path}")
    if declared_length != len(payload):
        raise ValueError(f"GLB length mismatch: {path}")
    chunk_length, chunk_type = struct.unpack_from("<II", payload, 12)
    if chunk_type != JSON_CHUNK_TYPE:
        raise ValueError(f"First GLB chunk is not JSON: {path}")
    chunk_end = 20 + chunk_length
    if chunk_end > len(payload):
        raise ValueError(f"GLB JSON chunk exceeds file length: {path}")
    value = json.loads(payload[20:chunk_end].decode("utf-8").rstrip(" \x00"))
    if not isinstance(value, dict):
        raise ValueError(f"GLB JSON root is not an object: {path}")
    return value


def _glb_stats(path: Path) -> dict[str, int]:
    document = _read_glb_json(path)
    accessors = document.get("accessors", [])
    triangles = 0
    vertices = 0
    primitive_count = 0
    for mesh in document.get("meshes", []):
        for primitive in mesh.get("primitives", []):
            primitive_count += 1
            if "indices" not in primitive:
                raise ValueError(f"Every anatomy primitive must be indexed: {path}")
            index_count = int(accessors[int(primitive["indices"])]["count"])
            if index_count % 3:
                raise ValueError(f"Anatomy primitive index count is not triangular: {path}")
            position_accessor = int(primitive["attributes"]["POSITION"])
            triangles += index_count // 3
            vertices += int(accessors[position_accessor]["count"])
    return {
        "mesh_count": len(document.get("meshes", [])),
        "primitive_draw_call_count": primitive_count,
        "material_count": len(document.get("materials", [])),
        "vertex_count": vertices,
        "triangle_count": triangles,
        "size_bytes": path.stat().st_size,
    }


def _validate_budget_shape(budget: dict[str, Any]) -> None:
    if budget.get("schema_version") != 1:
        raise ValueError("Budget schema_version must be 1")
    if budget.get("pipeline_manifest_schema_version") != 1:
        raise ValueError("Budget must target pipeline manifest schema version 1")
    if int(budget.get("expected_region_count", 0)) != 56:
        raise ValueError("Budget expected_region_count must be 56")

    required_lods = _required_lods(budget)
    budgets_by_lod = _budgets_by_lod(budget)
    if set(budgets_by_lod) != required_lods:
        raise ValueError("Budget LOD keys must exactly match required_lods")

    for lod, limits in budgets_by_lod.items():
        for key in (
            "max_size_bytes",
            "max_vertex_count",
            "max_triangle_count",
            "max_primitive_draw_calls",
            "max_material_count",
        ):
            if int(limits.get(key, 0)) <= 0:
                raise ValueError(f"{lod} budget {key} must be positive")

    license_budget = _license_budget(budget)
    for key in (
        "current_catalog_license",
        "conservative_geometry_license",
        "source_license_url",
        "required_attribution_contains",
        "minimum_modification_count",
    ):
        if key not in license_budget:
            raise ValueError(f"Budget license metadata is missing {key}")


def _required_lods(budget: dict[str, Any]) -> set[str]:
    return {str(value) for value in budget.get("required_lods", [])}


def _budgets_by_lod(budget: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {
        str(key): dict(value)
        for key, value in dict(budget.get("budgets_by_lod", {})).items()
    }


def _license_budget(budget: dict[str, Any]) -> dict[str, Any]:
    return dict(budget.get("required_license_metadata", {}))


def _reference_outputs(budget: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        dict(output)
        for output in list(budget.get("reference_outputs", []))
    ]


def _validate_reference_outputs(budget: dict[str, Any]) -> None:
    outputs = _reference_outputs(budget)
    if {str(output.get("lod")) for output in outputs} != _required_lods(budget):
        raise ValueError("Reference output LODs must exactly match required_lods")
    for output in outputs:
        _validate_output_against_budget(
            budget=budget,
            output=output,
            description=f"reference {output.get('lod')}",
            asset_directory=None,
        )


def _validate_manifest(
    budget: dict[str, Any],
    manifest_path: Path,
    asset_directory: Path | None,
) -> None:
    manifest = _read_json(manifest_path)
    if int(manifest.get("schema_version", 0)) != int(
        budget["pipeline_manifest_schema_version"]
    ):
        raise ValueError(f"Pipeline manifest schema mismatch: {manifest_path}")

    regions = list(manifest.get("regions", []))
    if len(regions) != int(budget["expected_region_count"]):
        raise ValueError(f"Region count budget failed: {manifest_path}")

    _validate_license_metadata(budget, manifest, manifest_path)

    outputs = [dict(output) for output in list(manifest.get("outputs", []))]
    if {str(output.get("lod")) for output in outputs} != _required_lods(budget):
        raise ValueError(f"Manifest output LODs do not match budget: {manifest_path}")

    for output in outputs:
        _validate_output_against_budget(
            budget=budget,
            output=output,
            description=f"{manifest_path}:{output.get('lod')}",
            asset_directory=asset_directory or manifest_path.parent,
        )


def _validate_license_metadata(
    budget: dict[str, Any],
    manifest: dict[str, Any],
    manifest_path: Path,
) -> None:
    expected = _license_budget(budget)
    license_record = dict(manifest.get("license", {}))
    for key in ("current_catalog_license", "conservative_geometry_license"):
        if license_record.get(key) != expected[key]:
            raise ValueError(f"License metadata {key} failed: {manifest_path}")

    if str(license_record.get("source_license_url", "")).rstrip("/") != str(
        expected["source_license_url"]
    ).rstrip("/"):
        raise ValueError(f"Source license URL failed: {manifest_path}")

    attribution_text = " ".join(
        str(value) for value in list(license_record.get("required_attribution", []))
    )
    for required_text in list(expected["required_attribution_contains"]):
        if str(required_text) not in attribution_text:
            raise ValueError(
                f"Required attribution text is missing from {manifest_path}: "
                f"{required_text}"
            )

    modification_count = len(list(license_record.get("modifications", [])))
    if modification_count < int(expected["minimum_modification_count"]):
        raise ValueError(f"Modification metadata is incomplete: {manifest_path}")


def _validate_output_against_budget(
    budget: dict[str, Any],
    output: dict[str, Any],
    description: str,
    asset_directory: Path | None,
) -> None:
    lod = str(output.get("lod", ""))
    limits = _budgets_by_lod(budget).get(lod)
    if limits is None:
        raise ValueError(f"Unexpected LOD in budget validation: {description}")

    metrics = dict(output)
    glb_path = None
    if asset_directory is not None and output.get("file"):
        candidate = asset_directory / str(output["file"])
        if candidate.is_file():
            glb_path = candidate
            glb_metrics = _glb_stats(candidate)
            metrics.update(glb_metrics)
            if output.get("sha256") and _sha256(candidate) != str(output["sha256"]):
                raise ValueError(f"GLB SHA-256 mismatch: {candidate}")
            _validate_glb_license_metadata(budget, candidate)

    for metric_key, limit_key in (
        ("size_bytes", "max_size_bytes"),
        ("vertex_count", "max_vertex_count"),
        ("triangle_count", "max_triangle_count"),
        ("primitive_draw_call_count", "max_primitive_draw_calls"),
        ("material_count", "max_material_count"),
    ):
        if metric_key not in metrics:
            hint = " and the GLB file is unavailable" if glb_path is None else ""
            raise ValueError(f"{metric_key} is missing for {description}{hint}")
        if int(metrics[metric_key]) > int(limits[limit_key]):
            raise ValueError(
                f"{metric_key} budget failed for {description}: "
                f"{metrics[metric_key]} > {limits[limit_key]}"
            )

    if "sha256" in metrics and len(str(metrics["sha256"])) != 64:
        raise ValueError(f"Invalid SHA-256 metadata for {description}")


def _validate_glb_license_metadata(budget: dict[str, Any], path: Path) -> None:
    document = _read_glb_json(path)
    copyright_text = str(document.get("asset", {}).get("copyright", ""))
    for required_text in list(_license_budget(budget)["required_attribution_contains"]):
        if str(required_text) not in copyright_text:
            raise ValueError(
                f"GLB copyright metadata is missing required text in {path}: "
                f"{required_text}"
            )


def _scan_repository_for_glbs(root: Path) -> list[Path]:
    glb_files: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        relative_parts = path.relative_to(root).parts
        if any(part in IGNORED_SCAN_DIRECTORIES for part in relative_parts):
            continue
        if path.suffix.lower() in {".glb", ".gltf"}:
            glb_files.append(path)
    return sorted(glb_files)


def _find_manifest_for_glb(path: Path, root: Path) -> Path | None:
    current = path.parent
    while True:
        candidate = current / "anatomy_pipeline_manifest.json"
        if candidate.is_file():
            return candidate
        if current == root or current.parent == current:
            return None
        current = current.parent


def _validate_scanned_assets(budget: dict[str, Any], root: Path) -> int:
    glb_files = _scan_repository_for_glbs(root)
    manifests: set[Path] = set()
    for glb_file in glb_files:
        manifest = _find_manifest_for_glb(glb_file, root)
        if manifest is None:
            raise ValueError(f"Bundled GLB lacks anatomy pipeline manifest: {glb_file}")
        manifests.add(manifest)

    for manifest in sorted(manifests):
        _validate_manifest(budget, manifest, manifest.parent)
    return len(manifests)


def main() -> None:
    args = _parse_args()
    budget = _read_json(args.budget.resolve(strict=True))
    _validate_budget_shape(budget)
    _validate_reference_outputs(budget)

    validated_manifests = 0
    if args.manifest is not None:
        asset_directory = args.asset_directory.resolve() if args.asset_directory else None
        _validate_manifest(budget, args.manifest.resolve(strict=True), asset_directory)
        validated_manifests += 1

    if args.scan_repository is not None:
        validated_manifests += _validate_scanned_assets(
            budget,
            args.scan_repository.resolve(strict=True),
        )

    print(
        "BUDGETS_OK "
        f"reference_outputs={len(_reference_outputs(budget))} "
        f"bundled_manifests={validated_manifests}"
    )


if __name__ == "__main__":
    main()
