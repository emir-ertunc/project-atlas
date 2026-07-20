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


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate anatomy pipeline outputs.")
    parser.add_argument("--output-directory", required=True, type=Path)
    parser.add_argument("--source-archive", required=True, type=Path)
    parser.add_argument("--reduction-manifest", required=True, type=Path)
    parser.add_argument("--ontology", required=True, type=Path)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--pipeline-script", required=True, type=Path)
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


def _expected_region_ids(ontology: dict[str, Any]) -> set[str]:
    return {
        str(group["regions"][side]["id"])
        for group in ontology["groups"]
        for side in ("right", "left")
    }


def _geometry_stats(document: dict[str, Any]) -> dict[str, int]:
    accessors = document.get("accessors", [])
    triangles = 0
    vertices = 0
    primitive_count = 0
    for mesh in document.get("meshes", []):
        for primitive in mesh.get("primitives", []):
            primitive_count += 1
            if "indices" not in primitive:
                raise ValueError("Every anatomy primitive must be indexed")
            index_count = int(accessors[int(primitive["indices"])]["count"])
            if index_count % 3:
                raise ValueError("Anatomy primitive index count is not triangular")
            position_accessor = int(primitive["attributes"]["POSITION"])
            triangles += index_count // 3
            vertices += int(accessors[position_accessor]["count"])
    return {
        "mesh_count": len(document.get("meshes", [])),
        "primitive_draw_call_count": primitive_count,
        "material_count": len(document.get("materials", [])),
        "vertex_count": vertices,
        "triangle_count": triangles,
    }


def _verify_input(
    manifest: dict[str, Any],
    key: str,
    path: Path,
) -> None:
    recorded = manifest["inputs"][key]
    if recorded["file"] != path.name:
        raise ValueError(f"Input filename mismatch for {key}")
    if recorded["sha256"] != _sha256(path):
        raise ValueError(f"Input hash mismatch for {key}")


def main() -> None:
    args = _parse_args()
    output_directory = args.output_directory.resolve(strict=True)
    manifest = _read_json(output_directory / "anatomy_pipeline_manifest.json")
    ontology = _read_json(args.ontology)
    config = _read_json(args.config)
    expected_ids = _expected_region_ids(ontology)

    _verify_input(manifest, "source_archive", args.source_archive.resolve(strict=True))
    _verify_input(
        manifest,
        "reduction_manifest",
        args.reduction_manifest.resolve(strict=True),
    )
    _verify_input(manifest, "ontology", args.ontology.resolve(strict=True))
    _verify_input(manifest, "pipeline_config", args.config.resolve(strict=True))
    _verify_input(
        manifest,
        "pipeline_script",
        args.pipeline_script.resolve(strict=True),
    )

    manifest_ids = {str(region["id"]) for region in manifest["regions"]}
    if manifest_ids != expected_ids:
        raise ValueError("Output manifest region IDs do not match the ontology")
    if len(manifest["regions"]) != len(expected_ids):
        raise ValueError("Output manifest contains duplicate regions")

    expected_lods = {
        str(lod["id"]): float(lod["decimation_ratio"])
        for lod in config["lods"]
    }
    outputs = manifest.get("outputs", [])
    if {str(output["lod"]) for output in outputs} != set(expected_lods):
        raise ValueError("Output LOD set does not match pipeline config")

    previous_triangles: int | None = None
    for output in outputs:
        lod = str(output["lod"])
        path = output_directory / str(output["file"])
        if not path.is_file():
            raise ValueError(f"Missing GLB output: {path}")
        if path.stat().st_size != int(output["size_bytes"]):
            raise ValueError(f"GLB size mismatch: {path}")
        if _sha256(path) != str(output["sha256"]):
            raise ValueError(f"GLB hash mismatch: {path}")
        if float(output["decimation_ratio"]) != expected_lods[lod]:
            raise ValueError(f"LOD ratio mismatch: {lod}")

        document = _read_glb_json(path)
        copyright_text = str(document.get("asset", {}).get("copyright", ""))
        if "CC Attribution 4.0 International" not in copyright_text:
            raise ValueError(f"Current attribution is missing from {path}")
        if "CC Attribution-Share Alike 2.1 Japan" not in copyright_text:
            raise ValueError(f"Embedded geometry attribution is missing from {path}")

        mesh_names = {str(mesh.get("name")) for mesh in document.get("meshes", [])}
        if mesh_names != expected_ids:
            raise ValueError(f"GLB mesh names do not match ontology IDs: {path}")
        matching_nodes = {
            str(node.get("name")): node
            for node in document.get("nodes", [])
            if str(node.get("name")) in expected_ids
        }
        if set(matching_nodes) != expected_ids:
            raise ValueError(f"GLB node names do not match ontology IDs: {path}")
        for region_id, node in matching_nodes.items():
            extras = node.get("extras", {})
            if extras.get("muscle_region_id") != region_id:
                raise ValueError(f"Node extras mismatch for {region_id}")

        stats = _geometry_stats(document)
        if stats["vertex_count"] != int(output["vertex_count"]):
            raise ValueError(f"Vertex count mismatch for {lod}")
        if stats["triangle_count"] != int(output["triangle_count"]):
            raise ValueError(f"Triangle count mismatch for {lod}")
        if int(output.get("mesh_count", stats["mesh_count"])) != stats["mesh_count"]:
            raise ValueError(f"Mesh count mismatch for {lod}")
        if (
            int(output.get("primitive_draw_call_count", stats["primitive_draw_call_count"]))
            != stats["primitive_draw_call_count"]
        ):
            raise ValueError(f"Primitive draw-call count mismatch for {lod}")
        if int(output.get("material_count", stats["material_count"])) != stats["material_count"]:
            raise ValueError(f"Material count mismatch for {lod}")
        if previous_triangles is not None and stats["triangle_count"] >= previous_triangles:
            raise ValueError("Each lower LOD must reduce triangle count")
        previous_triangles = stats["triangle_count"]

    license_record = manifest.get("license", {})
    if license_record.get("conservative_geometry_license") != "CC-BY-SA-2.1-JP":
        raise ValueError("Conservative embedded geometry license is missing")
    if license_record.get("current_catalog_license") != "CC-BY-4.0":
        raise ValueError("Current catalog license is missing")

    print(
        "VALIDATION_OK "
        f"regions={len(expected_ids)} "
        f"lods={len(outputs)} "
        f"output={output_directory}"
    )


if __name__ == "__main__":
    main()
