import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final inventory = _readJson(
    'tool/exercise_catalog/foundational_exercises.v1.json',
  );
  final categories = _readJson(
    'tool/exercise_catalog/foundational_exercise_categories.v1.json',
  );
  final filters = _readJson(
    'tool/exercise_catalog/foundational_exercise_filters.v1.json',
  );
  final animationContract = _readJson(
    'tool/anatomy/animation/core_exercise_animation_prototypes.v1.json',
  );

  final inventoryExercises = _maps(inventory['exercises']);
  final categoryAssignments = _maps(categories['exercise_categories']);
  final equipmentFilters = _maps(filters['equipment_filters']);
  final levelFilters = _maps(filters['level_filters']);
  final lateralityFilters = _maps(filters['laterality_filters']);
  final exerciseTypeFilters = _maps(filters['exercise_type_filters']);
  final exerciseFilters = _maps(filters['exercise_filters']);

  test('defines localized P3-03 filter vocabularies', () {
    expect(filters['schema_version'], 1);
    expect(filters['scope'], 'P3-03');
    expect(filters['status'], 'filter_contract');
    expect(filters['source_inventory_id'], inventory['inventory_id']);
    expect(
      filters['source_category_contract_id'],
      categories['category_contract_id'],
    );

    expect(
      equipmentFilters,
      hasLength(filters['equipment_filter_count'] as int),
    );
    expect(levelFilters, hasLength(filters['level_filter_count'] as int));
    expect(
      lateralityFilters,
      hasLength(filters['laterality_filter_count'] as int),
    );
    expect(
      exerciseTypeFilters,
      hasLength(filters['exercise_type_filter_count'] as int),
    );

    _expectLocalizedVocabulary(equipmentFilters);
    _expectLocalizedVocabulary(levelFilters);
    _expectLocalizedVocabulary(lateralityFilters);
    _expectLocalizedVocabulary(exerciseTypeFilters);

    expect(
      _ids(levelFilters),
      unorderedEquals(<String>[
        'beginner',
        'novice',
        'intermediate',
        'advanced',
      ]),
    );
    expect(
      _ids(lateralityFilters),
      unorderedEquals(<String>[
        'bilateral',
        'unilateral',
        'alternating',
        'side_specific',
        'not_applicable',
      ]),
    );
  });

  test('assigns one filter record to every foundational exercise', () {
    expect(exerciseFilters, hasLength(filters['exercise_filter_count'] as int));

    final inventoryIds = inventoryExercises
        .map((exercise) => exercise['id'] as String)
        .toSet();
    final categoryExerciseIds = categoryAssignments
        .map((assignment) => assignment['exercise_id'] as String)
        .toSet();
    final filterExerciseIds = exerciseFilters
        .map((assignment) => assignment['exercise_id'] as String)
        .toSet();

    expect(categoryExerciseIds, inventoryIds);
    expect(filterExerciseIds, inventoryIds);
  });

  test('uses only valid P3-03 fields and filter references', () {
    const allowedEntryKeys = <String>{
      'exercise_id',
      'equipment_ids',
      'level_id',
      'laterality_id',
      'exercise_type_id',
    };
    const deferredKeys = <String>{
      'movement_pattern_id',
      'muscle_region_category_ids',
      'primary_region_ids',
      'secondary_region_ids',
      'stabilizer_region_ids',
      'instructions',
      'form_cues',
      'common_errors',
      'substitutions',
      'default_load_increment',
      'thumbnail_id',
      'animation_id',
      'asset_license_ids',
      'content_review_status',
      'sets',
      'reps',
      'rir',
      'rest_seconds',
    };

    final equipmentIds = _ids(equipmentFilters);
    final levelIds = _ids(levelFilters);
    final lateralityIds = _ids(lateralityFilters);
    final exerciseTypeIds = _ids(exerciseTypeFilters);

    final usedEquipmentIds = <String>{};
    final usedLevelIds = <String>{};
    final usedLateralityIds = <String>{};
    final usedExerciseTypeIds = <String>{};

    for (final entry in exerciseFilters) {
      expect(entry.keys.toSet(), allowedEntryKeys);
      expect(entry.keys.toSet().intersection(deferredKeys), isEmpty);

      final exerciseEquipmentIds = _strings(entry['equipment_ids']);
      expect(
        exerciseEquipmentIds,
        isNotEmpty,
        reason: entry['exercise_id'] as String,
      );
      expect(
        exerciseEquipmentIds.toSet(),
        hasLength(exerciseEquipmentIds.length),
      );
      for (final equipmentId in exerciseEquipmentIds) {
        expect(equipmentIds, contains(equipmentId));
      }
      usedEquipmentIds.addAll(exerciseEquipmentIds);

      final levelId = entry['level_id']! as String;
      final lateralityId = entry['laterality_id']! as String;
      final exerciseTypeId = entry['exercise_type_id']! as String;
      expect(levelIds, contains(levelId));
      expect(lateralityIds, contains(lateralityId));
      expect(exerciseTypeIds, contains(exerciseTypeId));
      usedLevelIds.add(levelId);
      usedLateralityIds.add(lateralityId);
      usedExerciseTypeIds.add(exerciseTypeId);
    }

    expect(usedEquipmentIds, containsAll(equipmentIds));
    expect(usedLevelIds, containsAll(levelIds));
    expect(usedLateralityIds, containsAll(lateralityIds));
    expect(usedExerciseTypeIds, containsAll(exerciseTypeIds));
  });

  test('keeps P2 animation equipment compatible with P3-03 filters', () {
    final equipmentIds = _ids(equipmentFilters);
    final filtersByExerciseId = <String, Map<String, Object?>>{
      for (final entry in exerciseFilters)
        entry['exercise_id'] as String: entry,
    };

    for (final animationExercise in _maps(animationContract['exercises'])) {
      final exerciseId = animationExercise['exercise_id']! as String;
      final animationEquipmentIds = _strings(animationExercise['equipment']);
      for (final equipmentId in animationEquipmentIds) {
        expect(equipmentIds, contains(equipmentId), reason: exerciseId);
      }

      final assignedEquipmentIds = _strings(
        filtersByExerciseId[exerciseId]!['equipment_ids'],
      );
      expect(
        assignedEquipmentIds.toSet().intersection(
          animationEquipmentIds.toSet(),
        ),
        isNotEmpty,
        reason: exerciseId,
      );
    }
  });

  test('keeps level ranks stable and sequential', () {
    final ranks = levelFilters.map((filter) => filter['rank'] as int).toList();
    expect(
      ranks,
      List<int>.generate(levelFilters.length, (index) => index + 1),
    );
  });
}

Map<String, Object?> _readJson(String path) {
  return Map<String, Object?>.from(
    jsonDecode(File(path).readAsStringSync()) as Map,
  );
}

List<Map<String, Object?>> _maps(Object? value) {
  return [
    for (final item in value! as List) Map<String, Object?>.from(item as Map),
  ];
}

Set<String> _ids(List<Map<String, Object?>> records) {
  return records.map((record) => record['id']! as String).toSet();
}

List<String> _strings(Object? value) {
  return [for (final item in value! as List) item as String];
}

void _expectLocalizedVocabulary(List<Map<String, Object?>> records) {
  final ids = <String>{};
  final displayOrders = <int>[];

  for (final record in records) {
    final id = record['id']! as String;
    expect(id, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
    ids.add(id);
    displayOrders.add(record['display_order']! as int);

    final names = Map<String, Object?>.from(record['names']! as Map);
    expect(names.keys, unorderedEquals(<String>['en', 'tr']));
    expect((names['en']! as String).trim(), isNotEmpty, reason: id);
    expect((names['tr']! as String).trim(), isNotEmpty, reason: id);
  }

  expect(ids, hasLength(records.length));
  expect(
    displayOrders,
    List<int>.generate(records.length, (index) => index + 1),
  );
}
