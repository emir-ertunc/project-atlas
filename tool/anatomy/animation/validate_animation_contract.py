from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


DEFAULT_EXPECTED_EXERCISE_COUNT = 10
REQUIRED_PHASES = {"setup", "finish"}


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate the shared anatomy rig and exercise animation contract."
    )
    parser.add_argument("--rig", required=True, type=Path)
    parser.add_argument("--animations", required=True, type=Path)
    parser.add_argument("--ontology", required=True, type=Path)
    parser.add_argument(
        "--expected-exercise-count",
        type=int,
        default=DEFAULT_EXPECTED_EXERCISE_COUNT,
    )
    return parser.parse_args()


def _read_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"Expected JSON object: {path}")
    return value


def _ontology_region_ids(ontology: dict[str, Any]) -> set[str]:
    return {
        str(group["regions"][side]["id"])
        for group in ontology["groups"]
        for side in ("right", "left")
    }


def _validate_rig(rig: dict[str, Any], region_ids: set[str]) -> dict[str, dict[str, Any]]:
    if rig.get("schema_version") != 1:
        raise ValueError("Rig schema_version must be 1")
    if not str(rig.get("rig_id", "")).endswith("_v1"):
        raise ValueError("Rig ID must be versioned")

    joints = list(dict(rig["rest_pose"])["joints"])
    joint_ids = {str(joint["id"]) for joint in joints}
    if len(joint_ids) != len(joints):
        raise ValueError("Rig contains duplicate joints")
    for joint in joints:
        parent = joint.get("parent")
        if parent is not None and str(parent) not in joint_ids:
            raise ValueError(f"Joint parent is missing: {joint['id']}")
        position = list(joint["position_m"])
        if len(position) != 3 or not all(isinstance(value, int | float) for value in position):
            raise ValueError(f"Joint position must be a 3D numeric vector: {joint['id']}")

    for bone in list(rig["bones"]):
        if str(bone["parent_joint"]) not in joint_ids:
            raise ValueError(f"Bone parent joint missing: {bone['id']}")
        if str(bone["child_joint"]) not in joint_ids:
            raise ValueError(f"Bone child joint missing: {bone['id']}")

    controls = {str(control["id"]): dict(control) for control in list(rig["controls"])}
    if len(controls) != len(list(rig["controls"])):
        raise ValueError("Rig contains duplicate controls")
    for control_id, control in controls.items():
        minimum = float(control["min"])
        maximum = float(control["max"])
        default = float(control["default"])
        if minimum >= maximum:
            raise ValueError(f"Control min/max is invalid: {control_id}")
        if not minimum <= default <= maximum:
            raise ValueError(f"Control default is outside limits: {control_id}")

    anchor_ids = {str(anchor["id"]) for anchor in list(rig["equipment_anchors"])}
    if len(anchor_ids) != len(list(rig["equipment_anchors"])):
        raise ValueError("Rig contains duplicate equipment anchors")

    for binding in list(rig["muscle_region_bindings"]):
        region_id = str(binding["region_id"])
        if region_id not in region_ids:
            raise ValueError(f"Rig binding references unknown region: {region_id}")
        for driver in list(binding["drivers"]):
            if str(driver) not in joint_ids:
                raise ValueError(f"Rig binding references unknown driver: {driver}")

    return controls


def _validate_animations(
    animations: dict[str, Any],
    controls: dict[str, dict[str, Any]],
    region_ids: set[str],
    anchor_ids: set[str],
    rig_id: str,
    expected_exercise_count: int,
) -> None:
    if animations.get("schema_version") != 1:
        raise ValueError("Animation schema_version must be 1")
    if animations.get("rig_id") != rig_id:
        raise ValueError("Animation set rig_id does not match shared rig")
    if int(animations.get("fps", 0)) < 24:
        raise ValueError("Animation fps must be at least 24")

    expected_duration = float(animations["cycle_seconds"])
    minimum_keyframes = int(animations["minimum_keyframes_per_exercise"])
    exercises = [dict(exercise) for exercise in list(animations["exercises"])]
    if len(exercises) != expected_exercise_count:
        raise ValueError(f"Expected {expected_exercise_count} exercise prototypes")

    exercise_ids = {str(exercise["exercise_id"]) for exercise in exercises}
    if len(exercise_ids) != len(exercises):
        raise ValueError("Animation set contains duplicate exercise IDs")

    movement_patterns = {str(exercise["movement_pattern"]) for exercise in exercises}
    if len(movement_patterns) < 6:
        raise ValueError("Animation prototypes must cover at least six movement patterns")

    for exercise in exercises:
        exercise_id = str(exercise["exercise_id"])
        _validate_names(exercise_id, dict(exercise["names"]))
        _validate_region_list(exercise_id, exercise, "primary_region_ids", region_ids)
        _validate_region_list(exercise_id, exercise, "secondary_region_ids", region_ids)

        phases = {str(phase) for phase in list(exercise["phase_tags"])}
        if not REQUIRED_PHASES.issubset(phases):
            raise ValueError(f"Exercise lacks required setup/finish phases: {exercise_id}")
        for anchor in list(exercise["contact_anchors"]):
            if str(anchor) not in anchor_ids:
                raise ValueError(f"Exercise references unknown anchor: {exercise_id}:{anchor}")

        keyframes = [dict(keyframe) for keyframe in list(exercise["keyframes"])]
        if len(keyframes) < minimum_keyframes:
            raise ValueError(f"Exercise has too few keyframes: {exercise_id}")
        _validate_keyframes(exercise_id, keyframes, expected_duration, phases, controls)


def _validate_names(exercise_id: str, names: dict[str, Any]) -> None:
    if set(names) != {"en", "tr"}:
        raise ValueError(f"Exercise names must include en and tr: {exercise_id}")
    for locale, value in names.items():
        if not str(value).strip():
            raise ValueError(f"Exercise name is empty: {exercise_id}:{locale}")


def _validate_region_list(
    exercise_id: str,
    exercise: dict[str, Any],
    key: str,
    region_ids: set[str],
) -> None:
    values = [str(value) for value in list(exercise[key])]
    if not values:
        raise ValueError(f"Exercise {key} is empty: {exercise_id}")
    if len(values) != len(set(values)):
        raise ValueError(f"Exercise {key} contains duplicates: {exercise_id}")
    unknown = sorted(set(values) - region_ids)
    if unknown:
        raise ValueError(f"Exercise {key} references unknown regions: {exercise_id}:{unknown}")


def _validate_keyframes(
    exercise_id: str,
    keyframes: list[dict[str, Any]],
    expected_duration: float,
    phases: set[str],
    controls: dict[str, dict[str, Any]],
) -> None:
    times = [float(keyframe["time_seconds"]) for keyframe in keyframes]
    if times[0] != 0.0:
        raise ValueError(f"First keyframe must start at 0.0 seconds: {exercise_id}")
    if times[-1] != expected_duration:
        raise ValueError(f"Last keyframe must equal cycle_seconds: {exercise_id}")
    if times != sorted(times) or len(times) != len(set(times)):
        raise ValueError(f"Keyframe times must be strictly increasing: {exercise_id}")

    first_controls = dict(keyframes[0]["controls"])
    last_controls = dict(keyframes[-1]["controls"])
    if first_controls != last_controls:
        raise ValueError(f"First and last keyframe controls must match: {exercise_id}")

    for keyframe in keyframes:
        phase = str(keyframe["phase"])
        if phase not in phases:
            raise ValueError(f"Keyframe phase is not declared: {exercise_id}:{phase}")
        frame_controls = dict(keyframe["controls"])
        if not frame_controls:
            raise ValueError(f"Keyframe controls are empty: {exercise_id}:{phase}")
        for control_id, raw_value in frame_controls.items():
            if control_id not in controls:
                raise ValueError(f"Unknown rig control: {exercise_id}:{control_id}")
            if not isinstance(raw_value, int | float):
                raise ValueError(f"Control value must be numeric: {exercise_id}:{control_id}")
            value = float(raw_value)
            control = controls[control_id]
            minimum = float(control["min"])
            maximum = float(control["max"])
            if not minimum <= value <= maximum:
                raise ValueError(
                    f"Control value outside limits: {exercise_id}:{control_id}={value}"
                )


def main() -> None:
    args = _parse_args()
    rig = _read_json(args.rig.resolve(strict=True))
    animations = _read_json(args.animations.resolve(strict=True))
    ontology = _read_json(args.ontology.resolve(strict=True))
    region_ids = _ontology_region_ids(ontology)
    controls = _validate_rig(rig, region_ids)
    anchor_ids = {str(anchor["id"]) for anchor in list(rig["equipment_anchors"])}
    _validate_animations(
        animations=animations,
        controls=controls,
        region_ids=region_ids,
        anchor_ids=anchor_ids,
        rig_id=str(rig["rig_id"]),
        expected_exercise_count=args.expected_exercise_count,
    )
    print(
        "ANIMATION_CONTRACT_OK "
        f"rig_controls={len(controls)} "
        f"exercises={len(list(animations['exercises']))}"
    )


if __name__ == "__main__":
    main()
