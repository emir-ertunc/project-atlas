import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CATALOG_DIR = ROOT / "tool" / "exercise_catalog"
OUTPUT_PATH = CATALOG_DIR / "foundational_exercise_muscle_mappings.v1.json"


def bilateral(*group_ids):
    region_ids = []
    for group_id in group_ids:
        region_ids.extend([f"{group_id}_right", f"{group_id}_left"])
    return region_ids


def template(primary, secondary, stabilizer):
    return {
        "primary_region_ids": bilateral(*primary),
        "secondary_region_ids": bilateral(*secondary),
        "stabilizer_region_ids": bilateral(*stabilizer),
    }


TEMPLATES = {
    "squat": template(
        ["quadriceps", "gluteus_maximus"],
        ["hamstrings", "erector_spinae", "gastrocnemius"],
        ["external_oblique", "gluteus_medius_minimus", "soleus"],
    ),
    "knee_extension": template(
        ["quadriceps"],
        ["iliopsoas"],
        ["external_oblique", "gluteus_medius_minimus"],
    ),
    "hinge": template(
        ["gluteus_maximus", "hamstrings", "erector_spinae"],
        ["quadriceps", "trapezius", "forearm_flexors_pronators"],
        ["external_oblique", "gluteus_medius_minimus", "gastrocnemius"],
    ),
    "hip_extension": template(
        ["gluteus_maximus"],
        ["hamstrings", "erector_spinae"],
        ["external_oblique", "gluteus_medius_minimus"],
    ),
    "knee_flexion": template(
        ["hamstrings"],
        ["gastrocnemius"],
        ["gluteus_maximus", "external_oblique"],
    ),
    "horizontal_push": template(
        ["pectoralis_major", "triceps_brachii", "deltoid_anterior"],
        ["serratus_anterior", "pectoralis_minor"],
        ["rotator_cuff", "trapezius", "external_oblique"],
    ),
    "chest_fly": template(
        ["pectoralis_major"],
        ["pectoralis_minor", "deltoid_anterior", "serratus_anterior"],
        ["rotator_cuff", "external_oblique"],
    ),
    "vertical_push": template(
        ["deltoid_anterior", "deltoid_lateral", "triceps_brachii"],
        ["trapezius", "serratus_anterior"],
        ["rotator_cuff", "external_oblique", "gluteus_maximus"],
    ),
    "shoulder_abduction": template(
        ["deltoid_lateral"],
        ["deltoid_anterior", "deltoid_posterior"],
        ["rotator_cuff", "trapezius", "external_oblique"],
    ),
    "horizontal_pull": template(
        ["rhomboids", "trapezius", "teres_major", "biceps_brachii"],
        ["deltoid_posterior", "forearm_flexors_pronators", "erector_spinae"],
        ["external_oblique", "rotator_cuff"],
    ),
    "shoulder_horizontal_abduction": template(
        ["deltoid_posterior", "rhomboids"],
        ["trapezius", "rotator_cuff"],
        ["external_oblique", "forearm_extensors_supinators"],
    ),
    "vertical_pull": template(
        ["rhomboids", "trapezius", "teres_major", "biceps_brachii"],
        ["deltoid_posterior", "forearm_flexors_pronators"],
        ["rotator_cuff", "external_oblique"],
    ),
    "shoulder_extension": template(
        ["teres_major", "rhomboids", "trapezius"],
        ["pectoralis_major", "triceps_brachii"],
        ["rotator_cuff", "external_oblique"],
    ),
    "single_leg_squat": template(
        ["quadriceps", "gluteus_maximus"],
        ["hamstrings", "gastrocnemius", "gluteus_medius_minimus"],
        ["external_oblique", "erector_spinae", "soleus"],
    ),
    "lateral_lunge": template(
        ["quadriceps", "gluteus_maximus", "hip_adductors"],
        ["hamstrings", "gluteus_medius_minimus"],
        ["external_oblique", "erector_spinae", "gastrocnemius"],
    ),
    "single_leg_hinge": template(
        ["hamstrings", "gluteus_maximus"],
        ["erector_spinae", "gluteus_medius_minimus"],
        ["external_oblique", "gastrocnemius", "soleus"],
    ),
    "hip_abduction": template(
        ["gluteus_medius_minimus"],
        ["hip_external_rotators_deep"],
        ["external_oblique", "gluteus_maximus"],
    ),
    "hip_adduction": template(
        ["hip_adductors"],
        ["iliopsoas"],
        ["external_oblique", "gluteus_medius_minimus"],
    ),
    "hip_external_rotation": template(
        ["hip_external_rotators_deep", "gluteus_medius_minimus"],
        ["gluteus_maximus"],
        ["external_oblique"],
    ),
    "elbow_flexion": template(
        ["biceps_brachii", "brachialis"],
        ["forearm_flexors_pronators"],
        ["deltoid_anterior", "external_oblique"],
    ),
    "elbow_extension": template(
        ["triceps_brachii"],
        ["forearm_extensors_supinators", "deltoid_anterior"],
        ["rotator_cuff", "external_oblique"],
    ),
    "ankle_plantar_flexion": template(
        ["gastrocnemius", "soleus"],
        ["fibularis"],
        ["tibialis_anterior", "quadriceps"],
    ),
    "ankle_dorsiflexion": template(
        ["tibialis_anterior"],
        ["fibularis"],
        ["quadriceps", "external_oblique"],
    ),
    "core_anti_extension": template(
        ["external_oblique"],
        ["erector_spinae", "iliopsoas"],
        ["gluteus_maximus", "serratus_anterior", "deltoid_anterior"],
    ),
    "core_anti_lateral_flexion": template(
        ["external_oblique"],
        ["gluteus_medius_minimus", "erector_spinae"],
        ["deltoid_lateral", "trapezius"],
    ),
    "core_anti_rotation": template(
        ["external_oblique"],
        ["erector_spinae", "gluteus_medius_minimus"],
        ["pectoralis_major", "deltoid_anterior", "rhomboids"],
    ),
    "core_flexion": template(
        ["external_oblique"],
        ["iliopsoas"],
        ["erector_spinae"],
    ),
    "hip_flexion": template(
        ["iliopsoas", "external_oblique"],
        ["quadriceps", "forearm_flexors_pronators"],
        ["erector_spinae", "trapezius"],
    ),
    "core_rotation": template(
        ["external_oblique"],
        ["erector_spinae", "iliopsoas"],
        ["gluteus_medius_minimus"],
    ),
    "loaded_carry": template(
        ["forearm_flexors_pronators", "trapezius"],
        ["external_oblique", "erector_spinae", "gluteus_medius_minimus"],
        ["quadriceps", "gastrocnemius", "soleus"],
    ),
    "conditioning": template(
        ["quadriceps", "gluteus_maximus", "pectoralis_major", "triceps_brachii"],
        ["hamstrings", "gastrocnemius", "deltoid_anterior"],
        ["external_oblique", "erector_spinae", "serratus_anterior"],
    ),
}


OVERRIDES = {
    "leg_extension": template(["quadriceps"], [], ["iliopsoas", "external_oblique"]),
    "wall_sit": template(
        ["quadriceps", "gluteus_maximus"],
        ["hamstrings"],
        ["external_oblique", "gastrocnemius", "soleus"],
    ),
    "dumbbell_lateral_raise": TEMPLATES["shoulder_abduction"],
    "face_pull": template(
        ["deltoid_posterior", "rhomboids", "rotator_cuff"],
        ["trapezius", "biceps_brachii"],
        ["external_oblique", "forearm_flexors_pronators"],
    ),
    "pull_up": TEMPLATES["vertical_pull"],
    "chin_up": template(
        ["biceps_brachii", "rhomboids", "trapezius", "teres_major"],
        ["brachialis", "deltoid_posterior", "forearm_flexors_pronators"],
        ["rotator_cuff", "external_oblique"],
    ),
    "neutral_grip_pull_up": TEMPLATES["vertical_pull"],
    "straight_arm_pulldown": TEMPLATES["shoulder_extension"],
    "pullover_machine": TEMPLATES["shoulder_extension"],
    "clamshell": TEMPLATES["hip_external_rotation"],
    "bodyweight_donkey_kick": TEMPLATES["hip_extension"],
    "tibialis_raise": TEMPLATES["ankle_dorsiflexion"],
    "side_plank": TEMPLATES["core_anti_lateral_flexion"],
    "dead_bug": TEMPLATES["core_anti_extension"],
    "bird_dog": TEMPLATES["core_anti_rotation"],
    "hanging_knee_raise": TEMPLATES["hip_flexion"],
    "hanging_leg_raise": TEMPLATES["hip_flexion"],
    "pallof_press": TEMPLATES["core_anti_rotation"],
    "russian_twist": TEMPLATES["core_rotation"],
    "overhead_carry": template(
        ["deltoid_anterior", "deltoid_lateral", "trapezius", "triceps_brachii"],
        ["forearm_flexors_pronators", "serratus_anterior"],
        ["external_oblique", "erector_spinae", "rotator_cuff"],
    ),
    "sled_push": template(
        ["quadriceps", "gluteus_maximus", "gastrocnemius"],
        ["deltoid_anterior", "triceps_brachii", "pectoralis_major"],
        ["external_oblique", "erector_spinae", "soleus"],
    ),
    "sled_pull": template(
        ["quadriceps", "gluteus_maximus", "hamstrings"],
        ["rhomboids", "trapezius", "forearm_flexors_pronators"],
        ["external_oblique", "erector_spinae", "gastrocnemius"],
    ),
    "burpee": template(
        ["quadriceps", "gluteus_maximus", "pectoralis_major", "triceps_brachii"],
        ["deltoid_anterior", "hamstrings", "gastrocnemius"],
        ["external_oblique", "serratus_anterior", "erector_spinae"],
    ),
}


def compact(record):
    return {
        key: value
        for key, value in record.items()
        if key == "primary_region_ids" or value
    }


def main():
    inventory = json.loads((CATALOG_DIR / "foundational_exercises.v1.json").read_text(encoding="utf-8"))
    categories = json.loads((CATALOG_DIR / "foundational_exercise_categories.v1.json").read_text(encoding="utf-8"))
    filters = json.loads((CATALOG_DIR / "foundational_exercise_filters.v1.json").read_text(encoding="utf-8"))
    content = json.loads((CATALOG_DIR / "foundational_exercise_content.v1.json").read_text(encoding="utf-8"))

    category_by_exercise_id = {
        assignment["exercise_id"]: assignment
        for assignment in categories["exercise_categories"]
    }

    mappings = []
    for exercise in inventory["exercises"]:
        exercise_id = exercise["id"]
        movement_pattern_id = category_by_exercise_id[exercise_id]["movement_pattern_id"]
        mapping = OVERRIDES.get(exercise_id, TEMPLATES[movement_pattern_id])
        mappings.append({
            "exercise_id": exercise_id,
            "primary_region_ids": mapping["primary_region_ids"],
            "secondary_region_ids": mapping["secondary_region_ids"],
            "stabilizer_region_ids": mapping["stabilizer_region_ids"],
        })

    contract = {
        "schema_version": 1,
        "muscle_mapping_contract_id": "project_atlas_foundational_exercise_muscle_mappings_v1",
        "scope": "P3-05",
        "status": "structurally_verified_muscle_mapping_contract",
        "source_inventory_id": inventory["inventory_id"],
        "source_inventory_file": "foundational_exercises.v1.json",
        "source_category_contract_id": categories["category_contract_id"],
        "source_category_file": "foundational_exercise_categories.v1.json",
        "source_filter_contract_id": filters["filter_contract_id"],
        "source_filter_file": "foundational_exercise_filters.v1.json",
        "source_content_contract_id": content["content_contract_id"],
        "source_content_file": "foundational_exercise_content.v1.json",
        "muscle_ontology_file": "../anatomy/muscle_region_ontology.v1.json",
        "supported_locales": ["en", "tr"],
        "muscle_role_order": ["primary_region_ids", "secondary_region_ids", "stabilizer_region_ids"],
        "exercise_muscle_mapping_count": len(mappings),
        "exercise_muscle_mappings": mappings,
    }

    OUTPUT_PATH.write_text(
        json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
