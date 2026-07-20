from __future__ import annotations

import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
CATALOG_ROOT = ROOT / "tool" / "exercise_catalog"
ANIMATION_ROOT = ROOT / "tool" / "anatomy" / "animation"

COMPOUND_EXERCISE_IDS = [
    "barbell_back_squat",
    "front_squat",
    "goblet_squat",
    "hack_squat",
    "leg_press",
    "bodyweight_squat",
    "barbell_deadlift",
    "romanian_deadlift",
    "sumo_deadlift",
    "trap_bar_deadlift",
    "kettlebell_swing",
    "hip_thrust",
    "barbell_bench_press",
    "dumbbell_bench_press",
    "incline_barbell_bench_press",
    "incline_dumbbell_bench_press",
    "push_up",
    "weighted_push_up",
    "standing_overhead_press",
    "dumbbell_shoulder_press",
    "push_press",
    "handstand_push_up",
    "bent_over_barbell_row",
    "dumbbell_row",
    "seated_cable_row",
    "inverted_row",
    "pull_up",
    "chin_up",
    "lat_pulldown",
    "reverse_lunge",
]


def main() -> None:
    inventory = _read_json(CATALOG_ROOT / "foundational_exercises.v1.json")
    categories = _read_json(
        CATALOG_ROOT / "foundational_exercise_categories.v1.json"
    )
    filters = _read_json(CATALOG_ROOT / "foundational_exercise_filters.v1.json")
    mappings = _read_json(
        CATALOG_ROOT / "foundational_exercise_muscle_mappings.v1.json"
    )

    inventory_by_id = {
        str(row["id"]): dict(row) for row in list(inventory["exercises"])
    }
    category_by_exercise_id = {
        str(row["exercise_id"]): dict(row)
        for row in list(categories["exercise_categories"])
    }
    filter_by_exercise_id = {
        str(row["exercise_id"]): dict(row)
        for row in list(filters["exercise_filters"])
    }
    mapping_by_exercise_id = {
        str(row["exercise_id"]): dict(row)
        for row in list(mappings["exercise_muscle_mappings"])
    }

    animation_document = _build_animation_document(
        inventory=inventory,
        categories=categories,
        filters=filters,
        mappings=mappings,
        inventory_by_id=inventory_by_id,
        category_by_exercise_id=category_by_exercise_id,
        filter_by_exercise_id=filter_by_exercise_id,
        mapping_by_exercise_id=mapping_by_exercise_id,
    )
    media_document = _build_media_document(
        inventory=inventory,
        categories=categories,
        filters=filters,
        mappings=mappings,
        inventory_by_id=inventory_by_id,
        category_by_exercise_id=category_by_exercise_id,
        filter_by_exercise_id=filter_by_exercise_id,
    )

    _write_json(
        ANIMATION_ROOT / "compound_exercise_animation_prototypes.v1.json",
        animation_document,
    )
    _write_json(CATALOG_ROOT / "foundational_exercise_media.v1.json", media_document)


def _build_animation_document(
    *,
    inventory: dict[str, Any],
    categories: dict[str, Any],
    filters: dict[str, Any],
    mappings: dict[str, Any],
    inventory_by_id: dict[str, dict[str, Any]],
    category_by_exercise_id: dict[str, dict[str, Any]],
    filter_by_exercise_id: dict[str, dict[str, Any]],
    mapping_by_exercise_id: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    exercises = []
    for exercise_id in COMPOUND_EXERCISE_IDS:
        inventory_row = inventory_by_id[exercise_id]
        category_row = category_by_exercise_id[exercise_id]
        filter_row = filter_by_exercise_id[exercise_id]
        mapping_row = mapping_by_exercise_id[exercise_id]
        movement_pattern = str(category_row["movement_pattern_id"])
        equipment_ids = [str(value) for value in list(filter_row["equipment_ids"])]

        exercises.append(
            {
                "animation_id": _animation_id(exercise_id),
                "exercise_id": exercise_id,
                "names": dict(inventory_row["names"]),
                "movement_pattern": movement_pattern,
                "exercise_type": str(filter_row["exercise_type_id"]),
                "equipment": equipment_ids,
                "primary_region_ids": list(mapping_row["primary_region_ids"]),
                "secondary_region_ids": list(mapping_row["secondary_region_ids"]),
                "contact_anchors": _contact_anchors(equipment_ids),
                "phase_tags": _phase_tags(movement_pattern, exercise_id),
                "thumbnail_pose_phase": _thumbnail_pose_phase(movement_pattern),
                "keyframes": _keyframes(movement_pattern, exercise_id, equipment_ids),
            }
        )

    return {
        "schema_version": 1,
        "animation_set_id": "project_atlas_compound_exercise_animation_prototypes_v1",
        "rig_id": "project_atlas_shared_humanoid_rig_v1",
        "scope": "P3-10",
        "status": "review_ready_source_animation_contract",
        "source_inventory_id": inventory["inventory_id"],
        "source_category_contract_id": categories["category_contract_id"],
        "source_filter_contract_id": filters["filter_contract_id"],
        "source_muscle_mapping_contract_id": mappings[
            "muscle_mapping_contract_id"
        ],
        "fps": 30,
        "cycle_seconds": 2.0,
        "minimum_keyframes_per_exercise": 5,
        "exercise_animation_count": len(exercises),
        "selection_policy": {
            "target_exercise_count": 30,
            "allowed_exercise_type_ids": ["compound", "bodyweight_compound"],
            "coverage": [
                "squat",
                "hinge",
                "hip_extension",
                "horizontal_push",
                "vertical_push",
                "horizontal_pull",
                "vertical_pull",
                "single_leg_squat",
            ],
        },
        "exercises": exercises,
    }


def _build_media_document(
    *,
    inventory: dict[str, Any],
    categories: dict[str, Any],
    filters: dict[str, Any],
    mappings: dict[str, Any],
    inventory_by_id: dict[str, dict[str, Any]],
    category_by_exercise_id: dict[str, dict[str, Any]],
    filter_by_exercise_id: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    animated_ids = set(COMPOUND_EXERCISE_IDS)
    exercise_media = []
    for exercise_id, inventory_row in sorted(
        inventory_by_id.items(), key=lambda item: int(item[1]["display_order"])
    ):
        movement_pattern = str(
            category_by_exercise_id[exercise_id]["movement_pattern_id"]
        )
        exercise_type = str(filter_by_exercise_id[exercise_id]["exercise_type_id"])
        has_animation = exercise_id in animated_ids
        exercise_media.append(
            {
                "exercise_id": exercise_id,
                "thumbnail_id": f"thumb_{exercise_id}_v1",
                "thumbnail_variant": _thumbnail_variant(
                    movement_pattern,
                    exercise_type,
                ),
                "thumbnail_asset_kind": "procedural_vector_thumbnail",
                "animation_id": _animation_id(exercise_id) if has_animation else None,
                "animation_status": "available" if has_animation else "not_started",
                "license_ids": ["project_atlas_original_procedural_media"],
                "review_status": "internal_structural_check",
            }
        )

    return {
        "schema_version": 1,
        "media_contract_id": "project_atlas_foundational_exercise_media_v1",
        "scope": "P3-10",
        "status": "procedural_thumbnail_and_animation_binding_contract",
        "source_inventory_id": inventory["inventory_id"],
        "source_category_contract_id": categories["category_contract_id"],
        "source_filter_contract_id": filters["filter_contract_id"],
        "source_muscle_mapping_contract_id": mappings[
            "muscle_mapping_contract_id"
        ],
        "animation_set_id": "project_atlas_compound_exercise_animation_prototypes_v1",
        "thumbnail_count": len(exercise_media),
        "animated_exercise_count": len(animated_ids),
        "licenses": [
            {
                "id": "project_atlas_original_procedural_media",
                "kind": "original_project_asset",
                "applies_to": [
                    "procedural exercise thumbnails",
                    "source animation keyframes",
                ],
                "third_party_source": None,
                "distribution": "project_source_distribution",
            }
        ],
        "exercise_media": exercise_media,
    }


def _animation_id(exercise_id: str) -> str:
    return f"anim_{exercise_id}_v1"


def _thumbnail_variant(movement_pattern: str, exercise_type: str) -> str:
    if exercise_type in {"loaded_carry", "conditioning"}:
        return exercise_type
    if movement_pattern in {
        "squat",
        "knee_extension",
        "hinge",
        "hip_extension",
        "knee_flexion",
        "single_leg_squat",
        "lateral_lunge",
        "single_leg_hinge",
        "hip_abduction",
        "hip_adduction",
        "hip_external_rotation",
    }:
        return movement_pattern
    if movement_pattern in {
        "horizontal_push",
        "chest_fly",
        "vertical_push",
        "shoulder_abduction",
        "horizontal_pull",
        "shoulder_horizontal_abduction",
        "vertical_pull",
        "shoulder_extension",
    }:
        return movement_pattern
    if movement_pattern.startswith("core_") or movement_pattern == "hip_flexion":
        return "core"
    return "isolation"


def _contact_anchors(equipment_ids: list[str]) -> list[str]:
    anchors = ["floor"]
    if "barbell" in equipment_ids or "trap_bar" in equipment_ids:
        anchors.append("barbell")
    if "dumbbells" in equipment_ids or "kettlebell" in equipment_ids:
        anchors.append("dumbbells")
    if "bench" in equipment_ids:
        anchors.append("bench")
    if "pull_up_bar" in equipment_ids:
        anchors.append("pull_up_bar")
    if "cable_handle" in equipment_ids or "cable_stack" in equipment_ids:
        anchors.append("cable_handle")
    return list(dict.fromkeys(anchors))


def _phase_tags(movement_pattern: str, exercise_id: str) -> list[str]:
    if movement_pattern in {"hinge", "hip_extension"}:
        return ["setup", "concentric", "lockout", "eccentric", "finish"]
    if movement_pattern in {"vertical_push", "vertical_pull"}:
        return ["setup", "concentric", "top", "eccentric", "finish"]
    if movement_pattern == "horizontal_pull":
        return ["setup", "concentric", "top", "eccentric", "finish"]
    if movement_pattern == "single_leg_squat" or exercise_id == "reverse_lunge":
        return ["setup", "eccentric", "bottom", "concentric", "finish"]
    return ["setup", "eccentric", "bottom", "concentric", "finish"]


def _thumbnail_pose_phase(movement_pattern: str) -> str:
    if movement_pattern in {"hinge", "hip_extension", "vertical_push", "vertical_pull"}:
        return "top"
    if movement_pattern == "horizontal_pull":
        return "top"
    return "bottom"


def _keyframes(
    movement_pattern: str,
    exercise_id: str,
    equipment_ids: list[str],
) -> list[dict[str, Any]]:
    if movement_pattern == "squat":
        return _squat_keyframes(equipment_ids, exercise_id)
    if movement_pattern in {"hinge", "hip_extension"}:
        return _hinge_keyframes(equipment_ids, exercise_id, movement_pattern)
    if movement_pattern == "horizontal_push":
        return _horizontal_push_keyframes(equipment_ids, exercise_id)
    if movement_pattern == "vertical_push":
        return _vertical_push_keyframes(equipment_ids, exercise_id)
    if movement_pattern == "horizontal_pull":
        return _horizontal_pull_keyframes(equipment_ids, exercise_id)
    if movement_pattern == "vertical_pull":
        return _vertical_pull_keyframes(equipment_ids, exercise_id)
    if movement_pattern == "single_leg_squat":
        return _single_leg_squat_keyframes()
    raise ValueError(f"No P3-10 animation template for {exercise_id}:{movement_pattern}")


def _squat_keyframes(equipment_ids: list[str], exercise_id: str) -> list[dict[str, Any]]:
    bar_height = 1.42 if "barbell" in equipment_ids else 1.0
    setup = {
        "root_y_m": 0.0,
        "torso_pitch_deg": 10.0,
        "pelvis_pitch_deg": 4.0,
        "hip_flexion_right_deg": 20.0,
        "hip_flexion_left_deg": 20.0,
        "knee_flexion_right_deg": 8.0,
        "knee_flexion_left_deg": 8.0,
        "ankle_dorsiflexion_right_deg": 2.0,
        "ankle_dorsiflexion_left_deg": 2.0,
        "bar_height_m": bar_height,
        "grip_width_m": _grip_width(equipment_ids, 1.05),
    }
    bottom_depth = -0.32 if exercise_id == "leg_press" else -0.43
    bottom_knee = 96.0 if exercise_id == "leg_press" else 122.0
    return _loop([
        (0.0, "setup", setup),
        (
            0.7,
            "eccentric",
            setup | {
                "root_y_m": bottom_depth * 0.8,
                "torso_pitch_deg": 22.0,
                "pelvis_pitch_deg": 16.0,
                "hip_flexion_right_deg": 88.0,
                "hip_flexion_left_deg": 88.0,
                "knee_flexion_right_deg": bottom_knee - 12.0,
                "knee_flexion_left_deg": bottom_knee - 12.0,
                "ankle_dorsiflexion_right_deg": 16.0,
                "ankle_dorsiflexion_left_deg": 16.0,
                "bar_height_m": max(0.72, bar_height - 0.34),
            },
        ),
        (
            1.05,
            "bottom",
            setup | {
                "root_y_m": bottom_depth,
                "torso_pitch_deg": 26.0,
                "pelvis_pitch_deg": 20.0,
                "hip_flexion_right_deg": 104.0,
                "hip_flexion_left_deg": 104.0,
                "knee_flexion_right_deg": bottom_knee,
                "knee_flexion_left_deg": bottom_knee,
                "ankle_dorsiflexion_right_deg": 20.0,
                "ankle_dorsiflexion_left_deg": 20.0,
                "bar_height_m": max(0.68, bar_height - 0.42),
            },
        ),
        (
            1.55,
            "concentric",
            setup | {
                "root_y_m": bottom_depth * 0.35,
                "torso_pitch_deg": 16.0,
                "pelvis_pitch_deg": 10.0,
                "hip_flexion_right_deg": 46.0,
                "hip_flexion_left_deg": 46.0,
                "knee_flexion_right_deg": 42.0,
                "knee_flexion_left_deg": 42.0,
                "ankle_dorsiflexion_right_deg": 9.0,
                "ankle_dorsiflexion_left_deg": 9.0,
                "bar_height_m": max(0.78, bar_height - 0.16),
            },
        ),
        (2.0, "finish", setup),
    ])


def _hinge_keyframes(
    equipment_ids: list[str],
    exercise_id: str,
    movement_pattern: str,
) -> list[dict[str, Any]]:
    is_thrust = movement_pattern == "hip_extension" or exercise_id == "hip_thrust"
    setup = {
        "root_y_m": -0.18 if not is_thrust else -0.42,
        "torso_pitch_deg": 58.0 if not is_thrust else -12.0,
        "pelvis_pitch_deg": 24.0 if not is_thrust else 22.0,
        "hip_flexion_right_deg": 82.0 if not is_thrust else 86.0,
        "hip_flexion_left_deg": 82.0 if not is_thrust else 86.0,
        "knee_flexion_right_deg": 54.0 if not is_thrust else 78.0,
        "knee_flexion_left_deg": 54.0 if not is_thrust else 78.0,
        "ankle_dorsiflexion_right_deg": 8.0,
        "ankle_dorsiflexion_left_deg": 8.0,
        "shoulder_flexion_right_deg": 16.0,
        "shoulder_flexion_left_deg": 16.0,
        "elbow_flexion_right_deg": 4.0,
        "elbow_flexion_left_deg": 4.0,
        "bar_height_m": 0.25 if not is_thrust else 0.58,
        "grip_width_m": _grip_width(equipment_ids, 0.62),
    }
    lockout = setup | {
        "root_y_m": 0.0 if not is_thrust else -0.18,
        "torso_pitch_deg": 2.0 if not is_thrust else 0.0,
        "pelvis_pitch_deg": 0.0,
        "hip_flexion_right_deg": 5.0,
        "hip_flexion_left_deg": 5.0,
        "knee_flexion_right_deg": 3.0 if not is_thrust else 74.0,
        "knee_flexion_left_deg": 3.0 if not is_thrust else 74.0,
        "ankle_dorsiflexion_right_deg": 0.0,
        "ankle_dorsiflexion_left_deg": 0.0,
        "shoulder_flexion_right_deg": -4.0,
        "shoulder_flexion_left_deg": -4.0,
        "bar_height_m": 0.86 if not is_thrust else 0.95,
    }
    return _loop([
        (0.0, "setup", setup),
        (0.7, "concentric", _midpoint(setup, lockout, 0.72)),
        (1.05, "lockout", lockout),
        (1.55, "eccentric", _midpoint(setup, lockout, 0.45)),
        (2.0, "finish", setup),
    ])


def _horizontal_push_keyframes(
    equipment_ids: list[str],
    exercise_id: str,
) -> list[dict[str, Any]]:
    is_push_up = exercise_id.endswith("push_up")
    setup = {
        "root_y_m": -0.42 if is_push_up else -0.50,
        "torso_pitch_deg": 0.0 if is_push_up else -8.0,
        "spine_extension_deg": 0.0 if is_push_up else 12.0,
        "shoulder_flexion_right_deg": 76.0,
        "shoulder_flexion_left_deg": 76.0,
        "shoulder_horizontal_adduction_right_deg": 14.0,
        "shoulder_horizontal_adduction_left_deg": 14.0,
        "elbow_flexion_right_deg": 18.0,
        "elbow_flexion_left_deg": 18.0,
        "scapula_retraction_right_deg": -2.0 if is_push_up else 14.0,
        "scapula_retraction_left_deg": -2.0 if is_push_up else 14.0,
        "bar_height_m": 1.12 if not is_push_up else 0.72,
        "grip_width_m": _grip_width(equipment_ids, 0.90 if not is_push_up else 0.62),
    }
    bottom = setup | {
        "root_y_m": -0.60 if is_push_up else -0.50,
        "shoulder_flexion_right_deg": 62.0,
        "shoulder_flexion_left_deg": 62.0,
        "shoulder_horizontal_adduction_right_deg": 42.0,
        "shoulder_horizontal_adduction_left_deg": 42.0,
        "elbow_flexion_right_deg": 106.0,
        "elbow_flexion_left_deg": 106.0,
        "scapula_retraction_right_deg": 10.0 if is_push_up else 16.0,
        "scapula_retraction_left_deg": 10.0 if is_push_up else 16.0,
        "bar_height_m": 0.86 if not is_push_up else 0.58,
    }
    return _loop([
        (0.0, "setup", setup),
        (0.7, "eccentric", _midpoint(setup, bottom, 0.72)),
        (1.05, "bottom", bottom),
        (1.55, "concentric", _midpoint(setup, bottom, 0.32)),
        (2.0, "finish", setup),
    ])


def _vertical_push_keyframes(
    equipment_ids: list[str],
    exercise_id: str,
) -> list[dict[str, Any]]:
    is_handstand = exercise_id == "handstand_push_up"
    setup = {
        "root_y_m": -0.30 if is_handstand else 0.0,
        "torso_pitch_deg": -4.0 if is_handstand else 0.0,
        "spine_extension_deg": 4.0,
        "shoulder_flexion_right_deg": 92.0 if not is_handstand else 170.0,
        "shoulder_flexion_left_deg": 92.0 if not is_handstand else 170.0,
        "shoulder_abduction_right_deg": 35.0,
        "shoulder_abduction_left_deg": 35.0,
        "elbow_flexion_right_deg": 104.0 if not is_handstand else 20.0,
        "elbow_flexion_left_deg": 104.0 if not is_handstand else 20.0,
        "bar_height_m": 1.36 if not is_handstand else 0.18,
        "grip_width_m": _grip_width(equipment_ids, 0.62),
    }
    top = setup | {
        "root_y_m": -0.52 if is_handstand else 0.0,
        "torso_pitch_deg": 0.0,
        "spine_extension_deg": 0.0,
        "shoulder_flexion_right_deg": 170.0,
        "shoulder_flexion_left_deg": 170.0,
        "shoulder_abduction_right_deg": 55.0,
        "shoulder_abduction_left_deg": 55.0,
        "elbow_flexion_right_deg": 8.0 if not is_handstand else 112.0,
        "elbow_flexion_left_deg": 8.0 if not is_handstand else 112.0,
        "bar_height_m": 2.02 if not is_handstand else 0.08,
    }
    return _loop([
        (0.0, "setup", setup),
        (0.7, "concentric", _midpoint(setup, top, 0.70)),
        (1.05, "top", top),
        (1.55, "eccentric", _midpoint(setup, top, 0.38)),
        (2.0, "finish", setup),
    ])


def _horizontal_pull_keyframes(
    equipment_ids: list[str],
    exercise_id: str,
) -> list[dict[str, Any]]:
    is_inverted = exercise_id == "inverted_row"
    is_seated = exercise_id == "seated_cable_row"
    setup = {
        "root_y_m": -0.42 if is_inverted else (-0.34 if is_seated else -0.10),
        "torso_pitch_deg": 0.0 if is_inverted or is_seated else 55.0,
        "pelvis_pitch_deg": 8.0 if is_seated else 20.0,
        "hip_flexion_right_deg": 75.0 if is_seated else 62.0,
        "hip_flexion_left_deg": 75.0 if is_seated else 62.0,
        "knee_flexion_right_deg": 35.0 if not is_seated else 20.0,
        "knee_flexion_left_deg": 35.0 if not is_seated else 20.0,
        "shoulder_flexion_right_deg": 36.0,
        "shoulder_flexion_left_deg": 36.0,
        "elbow_flexion_right_deg": 12.0,
        "elbow_flexion_left_deg": 12.0,
        "scapula_retraction_right_deg": 0.0,
        "scapula_retraction_left_deg": 0.0,
        "bar_height_m": 0.55 if not is_inverted else 1.05,
        "grip_width_m": _grip_width(equipment_ids, 0.72),
    }
    top = setup | {
        "shoulder_flexion_right_deg": 14.0,
        "shoulder_flexion_left_deg": 14.0,
        "elbow_flexion_right_deg": 104.0,
        "elbow_flexion_left_deg": 104.0,
        "scapula_retraction_right_deg": 20.0,
        "scapula_retraction_left_deg": 20.0,
        "bar_height_m": 0.84 if not is_inverted else 1.05,
    }
    return _loop([
        (0.0, "setup", setup),
        (0.7, "concentric", _midpoint(setup, top, 0.72)),
        (1.05, "top", top),
        (1.55, "eccentric", _midpoint(setup, top, 0.36)),
        (2.0, "finish", setup),
    ])


def _vertical_pull_keyframes(
    equipment_ids: list[str],
    exercise_id: str,
) -> list[dict[str, Any]]:
    is_pulldown = "pulldown" in exercise_id
    setup = {
        "root_y_m": -0.35 if is_pulldown else -0.25,
        "torso_pitch_deg": -6.0 if is_pulldown else 0.0,
        "shoulder_flexion_right_deg": 170.0,
        "shoulder_flexion_left_deg": 170.0,
        "shoulder_abduction_right_deg": 55.0,
        "shoulder_abduction_left_deg": 55.0,
        "elbow_flexion_right_deg": 8.0,
        "elbow_flexion_left_deg": 8.0,
        "scapula_retraction_right_deg": -4.0,
        "scapula_retraction_left_deg": -4.0,
        "bar_height_m": 2.20 if not is_pulldown else 1.95,
        "grip_width_m": _grip_width(equipment_ids, 0.95),
    }
    top = setup | {
        "root_y_m": -0.35 if is_pulldown else 0.20,
        "torso_pitch_deg": -8.0,
        "shoulder_flexion_right_deg": 112.0,
        "shoulder_flexion_left_deg": 112.0,
        "shoulder_abduction_right_deg": 40.0,
        "shoulder_abduction_left_deg": 40.0,
        "elbow_flexion_right_deg": 104.0,
        "elbow_flexion_left_deg": 104.0,
        "scapula_retraction_right_deg": 18.0,
        "scapula_retraction_left_deg": 18.0,
        "bar_height_m": 1.30 if is_pulldown else 2.20,
    }
    return _loop([
        (0.0, "setup", setup),
        (0.7, "concentric", _midpoint(setup, top, 0.72)),
        (1.05, "top", top),
        (1.55, "eccentric", _midpoint(setup, top, 0.34)),
        (2.0, "finish", setup),
    ])


def _single_leg_squat_keyframes() -> list[dict[str, Any]]:
    setup = {
        "root_y_m": 0.0,
        "root_z_m": 0.0,
        "torso_pitch_deg": 4.0,
        "hip_flexion_right_deg": 5.0,
        "hip_flexion_left_deg": 5.0,
        "knee_flexion_right_deg": 4.0,
        "knee_flexion_left_deg": 4.0,
        "ankle_dorsiflexion_right_deg": 0.0,
        "ankle_dorsiflexion_left_deg": 0.0,
    }
    bottom = {
        "root_y_m": -0.34,
        "root_z_m": 0.32,
        "torso_pitch_deg": 10.0,
        "hip_flexion_right_deg": -12.0,
        "hip_flexion_left_deg": 82.0,
        "knee_flexion_right_deg": 92.0,
        "knee_flexion_left_deg": 98.0,
        "ankle_dorsiflexion_right_deg": -10.0,
        "ankle_dorsiflexion_left_deg": 18.0,
    }
    return _loop([
        (0.0, "setup", setup),
        (0.7, "eccentric", _midpoint(setup, bottom, 0.70)),
        (1.05, "bottom", bottom),
        (1.55, "concentric", _midpoint(setup, bottom, 0.36)),
        (2.0, "finish", setup),
    ])


def _grip_width(equipment_ids: list[str], fallback: float) -> float:
    if "dumbbells" in equipment_ids:
        return 0.52
    if "pull_up_bar" in equipment_ids:
        return 0.95
    if "barbell" in equipment_ids:
        return fallback
    return fallback


def _midpoint(
    start: dict[str, float],
    end: dict[str, float],
    ratio: float,
) -> dict[str, float]:
    keys = set(start) | set(end)
    return {
        key: round(float(start.get(key, end.get(key, 0.0))) + (
            float(end.get(key, start.get(key, 0.0)))
            - float(start.get(key, end.get(key, 0.0)))
        ) * ratio, 4)
        for key in keys
    }


def _loop(frames: list[tuple[float, str, dict[str, float]]]) -> list[dict[str, Any]]:
    return [
        {
            "time_seconds": time,
            "phase": phase,
            "controls": controls,
        }
        for time, phase, controls in frames
    ]


def _read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
