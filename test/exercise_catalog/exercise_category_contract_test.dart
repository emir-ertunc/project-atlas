import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final inventory = _readJson(
    'tool/exercise_catalog/foundational_exercises.v1.json',
  );
  final categoryContract = _readJson(
    'tool/exercise_catalog/foundational_exercise_categories.v1.json',
  );
  final ontology = _readJson('tool/anatomy/muscle_region_ontology.v1.json');
  final animationContract = _readJson(
    'tool/anatomy/animation/core_exercise_animation_prototypes.v1.json',
  );

  final inventoryExercises = _maps(inventory['exercises']);
  final movementPatterns = _maps(categoryContract['movement_patterns']);
  final muscleCategories = _maps(categoryContract['muscle_region_categories']);
  final exerciseCategories = _maps(categoryContract['exercise_categories']);
  final ontologyGroups = _maps(ontology['groups']);

  test('defines localized movement-pattern and muscle-region vocabularies', () {
    expect(categoryContract['schema_version'], 1);
    expect(categoryContract['scope'], 'P3-02');
    expect(categoryContract['status'], 'category_contract');
    expect(categoryContract['source_inventory_id'], inventory['inventory_id']);
    expect(
      movementPatterns,
      hasLength(categoryContract['movement_pattern_count'] as int),
    );
    expect(
      muscleCategories,
      hasLength(categoryContract['muscle_region_category_count'] as int),
    );

    _expectLocalizedVocabulary(movementPatterns);
    _expectLocalizedVocabulary(muscleCategories);

    final movementPatternIds = _ids(movementPatterns);
    expect(
      movementPatternIds,
      containsAll(<String>[
        'squat',
        'hinge',
        'horizontal_push',
        'vertical_push',
        'horizontal_pull',
        'vertical_pull',
        'single_leg_squat',
        'elbow_flexion',
        'elbow_extension',
        'loaded_carry',
        'conditioning',
      ]),
    );
  });

  test('anchors muscle-region categories to the P2 semantic ontology', () {
    final ontologyGroupIds = ontologyGroups
        .map((group) => group['semantic_group_id'] as String)
        .toSet();
    expect(
      ontologyGroupIds,
      hasLength(ontology['semantic_group_count'] as int),
    );

    final coveredGroupIds = <String>{};
    for (final category in muscleCategories) {
      final semanticGroupIds = _strings(category['semantic_group_ids']);
      expect(semanticGroupIds, isNotEmpty, reason: category['id'] as String);
      expect(semanticGroupIds.toSet(), hasLength(semanticGroupIds.length));

      for (final groupId in semanticGroupIds) {
        expect(ontologyGroupIds, contains(groupId));
      }
      coveredGroupIds.addAll(semanticGroupIds);
    }

    expect(coveredGroupIds, containsAll(ontologyGroupIds));
  });

  test('assigns one category record to every foundational exercise', () {
    expect(
      exerciseCategories,
      hasLength(categoryContract['exercise_category_count'] as int),
    );

    final inventoryIds = inventoryExercises
        .map((exercise) => exercise['id'] as String)
        .toSet();
    final categoryExerciseIds = exerciseCategories
        .map((entry) => entry['exercise_id'] as String)
        .toSet();

    expect(categoryExerciseIds, hasLength(inventoryIds.length));
    expect(categoryExerciseIds, inventoryIds);
  });

  test('uses only P3-02 category fields for each exercise assignment', () {
    const allowedEntryKeys = <String>{
      'exercise_id',
      'movement_pattern_id',
      'muscle_region_category_ids',
    };
    const deferredKeys = <String>{
      'exercise_type',
      'equipment',
      'difficulty',
      'level',
      'laterality',
      'instructions',
      'form_cues',
      'common_errors',
      'substitutions',
      'default_load_increment',
      'thumbnail_id',
      'animation_id',
      'asset_license_ids',
      'content_review_status',
      'primary_region_ids',
      'secondary_region_ids',
      'stabilizer_region_ids',
    };

    final movementPatternIds = _ids(movementPatterns);
    final muscleCategoryIds = _ids(muscleCategories);
    final usedMovementPatterns = <String>{};
    final usedMuscleCategories = <String>{};

    for (final entry in exerciseCategories) {
      expect(entry.keys.toSet(), allowedEntryKeys);
      expect(entry.keys.toSet().intersection(deferredKeys), isEmpty);

      final movementPatternId = entry['movement_pattern_id']! as String;
      expect(movementPatternIds, contains(movementPatternId));
      usedMovementPatterns.add(movementPatternId);

      final exerciseMuscleCategories = _strings(
        entry['muscle_region_category_ids'],
      );
      expect(exerciseMuscleCategories, isNotEmpty);
      expect(
        exerciseMuscleCategories.toSet(),
        hasLength(exerciseMuscleCategories.length),
      );

      for (final categoryId in exerciseMuscleCategories) {
        expect(muscleCategoryIds, contains(categoryId));
      }
      usedMuscleCategories.addAll(exerciseMuscleCategories);
    }

    expect(usedMovementPatterns, containsAll(movementPatternIds));
    expect(usedMuscleCategories, containsAll(muscleCategoryIds));
  });

  test('keeps P2 animation prototype movement patterns aligned', () {
    final categoriesByExerciseId = <String, Map<String, Object?>>{
      for (final entry in exerciseCategories)
        entry['exercise_id'] as String: entry,
    };
    final animationExercises = _maps(animationContract['exercises']);

    for (final exercise in animationExercises) {
      final exerciseId = exercise['exercise_id']! as String;
      expect(categoriesByExerciseId, contains(exerciseId));
      expect(
        categoriesByExerciseId[exerciseId]!['movement_pattern_id'],
        exercise['movement_pattern'],
        reason: exerciseId,
      );
    }
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
