from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import bmesh
import bpy


CURRENT_CATALOG_LICENSE = "CC-BY-4.0"
EMBEDDED_GEOMETRY_LICENSE = "CC-BY-SA-2.1-JP"
CURRENT_ATTRIBUTION = (
    "BodyParts3D, © The Database Center for Life Science licensed under "
    "CC Attribution 4.0 International"
)
EMBEDDED_ATTRIBUTION = (
    "BodyParts3D, (c) The Database Center for Life Science licensed under "
    "CC Attribution-Share Alike 2.1 Japan"
)
SOURCE_LICENSE_URL = "https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html"
GLB_MAGIC = b"glTF"
GLB_VERSION = 2
JSON_CHUNK_TYPE = 0x4E4F534A


@dataclass(frozen=True)
class Region:
    region_id: str
    semantic_group_id: str
    side: str
    reduction_slot: int
    element_file_ids: tuple[str, ...]


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build cleaned and decimated anatomy GLB LODs.",
    )
    parser.add_argument("--source-archive", required=True, type=Path)
    parser.add_argument("--reduction-manifest", required=True, type=Path)
    parser.add_argument("--ontology", required=True, type=Path)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--output-directory", required=True, type=Path)
    arguments = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    return parser.parse_args(arguments)


def _read_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"Expected a JSON object: {path}")
    return value


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _validate_config(config: dict[str, Any]) -> None:
    if config.get("schema_version") != 1:
        raise ValueError("Unsupported pipeline config schema")
    lods = config.get("lods")
    if not isinstance(lods, list) or not lods:
        raise ValueError("At least one LOD is required")
    identifiers = [entry.get("id") for entry in lods]
    ratios = [entry.get("decimation_ratio") for entry in lods]
    if len(identifiers) != len(set(identifiers)):
        raise ValueError("LOD identifiers must be unique")
    if ratios[0] != 1.0:
        raise ValueError("The first LOD must preserve cleaned source topology")
    if any(not isinstance(ratio, (int, float)) or ratio <= 0 or ratio > 1 for ratio in ratios):
        raise ValueError("LOD ratios must be in the interval (0, 1]")
    if ratios != sorted(ratios, reverse=True):
        raise ValueError("LOD ratios must be ordered from highest to lowest detail")


def _regions(
    reduction: dict[str, Any],
    ontology: dict[str, Any],
) -> list[Region]:
    reduction_pairs = {
        int(pair["slot"]): pair for pair in reduction.get("pairs", [])
    }
    groups = ontology.get("groups", [])
    if set(reduction_pairs) != {int(group["reduction_slot"]) for group in groups}:
        raise ValueError("Reduction and ontology slots do not match")

    result: list[Region] = []
    seen_region_ids: set[str] = set()
    seen_elements: set[str] = set()
    for group in groups:
        slot = int(group["reduction_slot"])
        reduction_pair = reduction_pairs[slot]
        semantic_group_id = str(group["semantic_group_id"])
        for side in ("right", "left"):
            region_id = str(group["regions"][side]["id"])
            elements = tuple(str(value) for value in reduction_pair[side]["element_file_ids"])
            if not elements:
                raise ValueError(f"Region has no source geometry: {region_id}")
            if region_id in seen_region_ids:
                raise ValueError(f"Duplicate region ID: {region_id}")
            duplicate_elements = seen_elements.intersection(elements)
            if duplicate_elements:
                raise ValueError(
                    f"Source elements assigned more than once: {sorted(duplicate_elements)}"
                )
            seen_region_ids.add(region_id)
            seen_elements.update(elements)
            result.append(
                Region(
                    region_id=region_id,
                    semantic_group_id=semantic_group_id,
                    side=side,
                    reduction_slot=slot,
                    element_file_ids=elements,
                )
            )
    if len(result) != int(ontology["muscle_region_count"]):
        raise ValueError("Ontology region count does not match generated region list")
    return result


def _validate_inputs(
    source_archive: Path,
    reduction_path: Path,
    ontology_path: Path,
    reduction: dict[str, Any],
    ontology: dict[str, Any],
) -> None:
    source_hash = _sha256(source_archive)
    if source_hash != str(reduction["source_archive_sha256"]):
        raise ValueError("Source archive hash does not match the reduction manifest")
    reduction_hash = _sha256(reduction_path)
    if reduction_hash != str(ontology["source_reduction_sha256"]):
        raise ValueError("Reduction manifest hash does not match the ontology")
    if str(ontology["source_reduction_file"]) != reduction_path.name:
        raise ValueError("Ontology references a different reduction filename")
    if ontology_path.name != "muscle_region_ontology.v1.json":
        raise ValueError("Unexpected ontology filename")


def _archive_members(
    archive: zipfile.ZipFile,
    regions: list[Region],
) -> dict[str, str]:
    requested = {
        element
        for region in regions
        for element in region.element_file_ids
    }
    members: dict[str, str] = {}
    for member in archive.namelist():
        path = Path(member)
        if path.suffix.lower() != ".obj" or path.stem not in requested:
            continue
        if path.stem in members:
            raise ValueError(f"Duplicate OBJ basename in source archive: {path.stem}")
        members[path.stem] = member
    missing = requested.difference(members)
    if missing:
        raise ValueError(f"Source archive is missing OBJ files: {sorted(missing)}")
    return members


def _parse_obj(
    payload: bytes,
    scale: float,
) -> tuple[list[tuple[float, float, float]], list[tuple[int, ...]]]:
    vertices: list[tuple[float, float, float]] = []
    faces: list[tuple[int, ...]] = []
    for raw_line in payload.decode("utf-8-sig").splitlines():
        line = raw_line.strip()
        if line.startswith("v "):
            values = line.split()
            if len(values) < 4:
                raise ValueError("Malformed OBJ vertex")
            vertices.append(
                (
                    float(values[1]) * scale,
                    float(values[2]) * scale,
                    float(values[3]) * scale,
                )
            )
        elif line.startswith("f "):
            indices: list[int] = []
            for token in line.split()[1:]:
                raw_index = int(token.split("/", 1)[0])
                index = raw_index - 1 if raw_index > 0 else len(vertices) + raw_index
                if index < 0 or index >= len(vertices):
                    raise ValueError("OBJ face references an invalid vertex")
                indices.append(index)
            if len(indices) >= 3:
                faces.append(tuple(indices))
    if not vertices or not faces:
        raise ValueError("OBJ contains no renderable mesh")
    return vertices, faces


def _build_region_object(
    region: Region,
    archive: zipfile.ZipFile,
    members: dict[str, str],
    scale: float,
    merge_distance: float,
    degenerate_distance: float,
    material: bpy.types.Material,
) -> bpy.types.Object:
    vertices: list[tuple[float, float, float]] = []
    faces: list[tuple[int, ...]] = []
    for element in region.element_file_ids:
        element_vertices, element_faces = _parse_obj(
            archive.read(members[element]),
            scale,
        )
        offset = len(vertices)
        vertices.extend(element_vertices)
        faces.extend(tuple(index + offset for index in face) for face in element_faces)

    mesh = bpy.data.meshes.new(f"__base_{region.region_id}")
    mesh.from_pydata(vertices, [], faces)
    mesh.validate(clean_customdata=True)
    mesh.update(calc_edges=True)

    editable = bmesh.new()
    editable.from_mesh(mesh)
    bmesh.ops.remove_doubles(editable, verts=list(editable.verts), dist=merge_distance)
    bmesh.ops.dissolve_degenerate(
        editable,
        dist=degenerate_distance,
        edges=list(editable.edges),
    )
    loose_vertices = [vertex for vertex in editable.verts if not vertex.link_faces]
    if loose_vertices:
        bmesh.ops.delete(editable, geom=loose_vertices, context="VERTS")
    bmesh.ops.recalc_face_normals(editable, faces=list(editable.faces))
    bmesh.ops.triangulate(editable, faces=list(editable.faces))
    editable.to_mesh(mesh)
    editable.free()
    mesh.validate(clean_customdata=True)
    mesh.update(calc_edges=True)

    if not mesh.vertices or not mesh.polygons:
        raise ValueError(f"Cleanup removed all geometry for {region.region_id}")

    obj = bpy.data.objects.new(f"__base_{region.region_id}", mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(material)
    obj["muscle_region_id"] = region.region_id
    obj["semantic_group_id"] = region.semantic_group_id
    obj["side"] = region.side
    obj["reduction_slot"] = region.reduction_slot
    obj["source_element_ids"] = ",".join(region.element_file_ids)
    return obj


def _create_material(config: dict[str, Any]) -> bpy.types.Material:
    material_config = config["material"]
    material = bpy.data.materials.new(str(material_config["name"]))
    material.diffuse_color = tuple(material_config["base_color_rgba"])
    node = material.node_tree.nodes.get("Principled BSDF")
    if node is not None:
        node.inputs["Base Color"].default_value = tuple(
            material_config["base_color_rgba"]
        )
        node.inputs["Roughness"].default_value = float(material_config["roughness"])
        node.inputs["Metallic"].default_value = float(material_config["metallic"])
    return material


def _clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for mesh in list(bpy.data.meshes):
        if mesh.users == 0:
            bpy.data.meshes.remove(mesh)
    for material in list(bpy.data.materials):
        if material.users == 0:
            bpy.data.materials.remove(material)


def _mesh_stats(objects: list[bpy.types.Object]) -> dict[str, int]:
    return {
        "region_count": len(objects),
        "vertex_count": sum(len(obj.data.vertices) for obj in objects),
        "triangle_count": sum(len(obj.data.polygons) for obj in objects),
    }


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


def _exported_glb_stats(path: Path) -> dict[str, int]:
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
    }


def _export_lod(
    lod: dict[str, Any],
    base_objects: list[bpy.types.Object],
    output_path: Path,
    config: dict[str, Any],
) -> dict[str, Any]:
    ratio = float(lod["decimation_ratio"])
    root = bpy.data.objects.new(f"muscle_regions_{lod['id']}", None)
    bpy.context.scene.collection.objects.link(root)
    root["lod"] = str(lod["id"])
    root["region_count"] = len(base_objects)

    objects: list[bpy.types.Object] = []
    for base in base_objects:
        duplicate = base.copy()
        duplicate.data = base.data.copy()
        duplicate.name = str(base["muscle_region_id"])
        duplicate.data.name = str(base["muscle_region_id"])
        duplicate.parent = root
        bpy.context.scene.collection.objects.link(duplicate)
        if ratio < 1.0 and len(duplicate.data.polygons) > 12:
            modifier = duplicate.modifiers.new(name="lod_decimate", type="DECIMATE")
            modifier.decimate_type = "COLLAPSE"
            modifier.ratio = ratio
            modifier.use_collapse_triangulate = True
            bpy.context.view_layer.objects.active = duplicate
            duplicate.select_set(True)
            bpy.ops.object.modifier_apply(modifier=modifier.name)
            duplicate.select_set(False)
        duplicate.data.validate(clean_customdata=True)
        duplicate.data.update(calc_edges=True)
        objects.append(duplicate)

    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root

    export_config = config["export"]
    bpy.ops.export_scene.gltf(
        filepath=str(output_path),
        check_existing=False,
        export_format="GLB",
        use_selection=True,
        export_extras=True,
        export_copyright=f"{CURRENT_ATTRIBUTION}; {EMBEDDED_ATTRIBUTION}",
        export_yup=bool(export_config["y_up"]),
        export_normals=bool(export_config["include_normals"]),
        export_tangents=bool(export_config["include_tangents"]),
        export_texcoords=bool(export_config["include_texcoords"]),
        export_vertex_color="ACTIVE" if export_config["include_vertex_colors"] else "NONE",
        export_animations=bool(export_config["include_animations"]),
        export_cameras=False,
        export_lights=False,
        export_materials="EXPORT",
        export_apply=False,
    )

    stats = _mesh_stats(objects)
    stats.update(_exported_glb_stats(output_path))
    stats.update(
        {
            "lod": str(lod["id"]),
            "decimation_ratio": ratio,
            "file": output_path.name,
            "size_bytes": output_path.stat().st_size,
            "sha256": _sha256(output_path),
        }
    )

    for obj in objects:
        mesh = obj.data
        bpy.data.objects.remove(obj, do_unlink=True)
        if mesh.users == 0:
            bpy.data.meshes.remove(mesh)
    bpy.data.objects.remove(root, do_unlink=True)
    return stats


def _write_manifest(
    path: Path,
    pipeline_path: Path,
    config_path: Path,
    reduction_path: Path,
    ontology_path: Path,
    source_archive: Path,
    regions: list[Region],
    outputs: list[dict[str, Any]],
    config: dict[str, Any],
    reduction: dict[str, Any],
) -> None:
    manifest = {
        "schema_version": 1,
        "pipeline_version": config["pipeline_version"],
        "blender_version": bpy.app.version_string,
        "inputs": {
            "pipeline_script": {
                "file": pipeline_path.name,
                "sha256": _sha256(pipeline_path),
            },
            "source_archive": {
                "file": source_archive.name,
                "sha256": _sha256(source_archive),
            },
            "reduction_manifest": {
                "file": reduction_path.name,
                "sha256": _sha256(reduction_path),
            },
            "ontology": {
                "file": ontology_path.name,
                "sha256": _sha256(ontology_path),
            },
            "pipeline_config": {
                "file": config_path.name,
                "sha256": _sha256(config_path),
            },
        },
        "license": {
            "conservative_geometry_license": EMBEDDED_GEOMETRY_LICENSE,
            "current_catalog_license": CURRENT_CATALOG_LICENSE,
            "source_license_url": SOURCE_LICENSE_URL,
            "required_attribution": [CURRENT_ATTRIBUTION, EMBEDDED_ATTRIBUTION],
            "modifications": [
                "selected source elements by semantic region",
                "converted millimeter coordinates to meters",
                "merged coincident vertices and removed degenerate geometry",
                "recalculated normals and triangulated faces",
                "merged elements within unilateral regions",
                "generated collapse-decimated LOD variants",
                "exported GLB containers with semantic node metadata",
            ],
        },
        "source_coverage_gaps": reduction.get("known_source_coverage_gaps", []),
        "regions": [
            {
                "id": region.region_id,
                "semantic_group_id": region.semantic_group_id,
                "side": region.side,
                "reduction_slot": region.reduction_slot,
                "source_element_ids": list(region.element_file_ids),
            }
            for region in regions
        ],
        "outputs": outputs,
    }
    path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )


def main() -> None:
    args = _parse_args()
    source_archive = args.source_archive.resolve(strict=True)
    reduction_path = args.reduction_manifest.resolve(strict=True)
    ontology_path = args.ontology.resolve(strict=True)
    config_path = args.config.resolve(strict=True)
    output_directory = args.output_directory.resolve()
    output_directory.mkdir(parents=True, exist_ok=True)

    reduction = _read_json(reduction_path)
    ontology = _read_json(ontology_path)
    config = _read_json(config_path)
    _validate_config(config)
    _validate_inputs(
        source_archive,
        reduction_path,
        ontology_path,
        reduction,
        ontology,
    )
    regions = _regions(reduction, ontology)

    _clear_scene()
    material = _create_material(config)
    with zipfile.ZipFile(source_archive) as archive:
        members = _archive_members(archive, regions)
        base_objects = [
            _build_region_object(
                region=region,
                archive=archive,
                members=members,
                scale=float(config["source_unit_scale_to_meters"]),
                merge_distance=float(config["merge_distance_meters"]),
                degenerate_distance=float(config["degenerate_distance_meters"]),
                material=material,
            )
            for region in regions
        ]

    outputs: list[dict[str, Any]] = []
    for lod in config["lods"]:
        output_path = output_directory / (
            f"{config['output_prefix']}_{lod['id']}.glb"
        )
        outputs.append(_export_lod(lod, base_objects, output_path, config))

    _write_manifest(
        path=output_directory / "anatomy_pipeline_manifest.json",
        pipeline_path=Path(__file__).resolve(),
        config_path=config_path,
        reduction_path=reduction_path,
        ontology_path=ontology_path,
        source_archive=source_archive,
        regions=regions,
        outputs=outputs,
        config=config,
        reduction=reduction,
    )
    print(
        "PIPELINE_OK "
        f"regions={len(regions)} "
        f"lods={len(outputs)} "
        f"output={output_directory}"
    )


if __name__ == "__main__":
    main()
