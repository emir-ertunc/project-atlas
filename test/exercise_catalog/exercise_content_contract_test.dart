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
  final content = _readJson(
    'tool/exercise_catalog/foundational_exercise_content.v1.json',
  );

  final inventoryExercises = _maps(inventory['exercises']);
  final movementPatterns = _maps(categories['movement_patterns']);
  final categoryAssignments = _maps(categories['exercise_categories']);
  final filterAssignments = _maps(filters['exercise_filters']);
  final instructionBlocks = _maps(content['instruction_blocks']);
  final exerciseContent = _maps(content['exercise_content']);

  test('defines localized original instruction, cue, and error blocks', () {
    expect(content['schema_version'], 1);
    expect(content['scope'], 'P3-04');
    expect(content['status'], 'content_contract');
    expect(content['source_inventory_id'], inventory['inventory_id']);
    expect(
      content['source_category_contract_id'],
      categories['category_contract_id'],
    );
    expect(content['source_filter_contract_id'], filters['filter_contract_id']);
    expect(
      instructionBlocks,
      hasLength(content['instruction_block_count'] as int),
    );

    final movementPatternIds = _ids(movementPatterns);
    final instructionBlockIds = _ids(instructionBlocks);
    expect(instructionBlockIds, movementPatternIds);

    for (final block in instructionBlocks) {
      final blockId = block['id']! as String;
      expect(blockId, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      _expectLocalizedText(block['setup'], reason: '$blockId setup');
      _expectLocalizedText(block['execution'], reason: '$blockId execution');
      _expectLocalizedTextList(
        block['form_cues'],
        minimumLength: 2,
        reason: '$blockId form cues',
      );
      _expectLocalizedTextList(
        block['common_errors'],
        minimumLength: 2,
        reason: '$blockId common errors',
      );
    }
  });

  test('assigns one content record to every foundational exercise', () {
    expect(
      exerciseContent,
      hasLength(content['exercise_content_count'] as int),
    );

    final inventoryIds = inventoryExercises
        .map((exercise) => exercise['id'] as String)
        .toSet();
    final categoryExerciseIds = categoryAssignments
        .map((assignment) => assignment['exercise_id'] as String)
        .toSet();
    final filterExerciseIds = filterAssignments
        .map((assignment) => assignment['exercise_id'] as String)
        .toSet();
    final contentExerciseIds = exerciseContent
        .map((assignment) => assignment['exercise_id'] as String)
        .toSet();

    expect(categoryExerciseIds, inventoryIds);
    expect(filterExerciseIds, inventoryIds);
    expect(contentExerciseIds, inventoryIds);
  });

  test(
    'keeps content assignments aligned with movement-pattern categories',
    () {
      final categoryByExerciseId = <String, Map<String, Object?>>{
        for (final assignment in categoryAssignments)
          assignment['exercise_id']! as String: assignment,
      };
      final instructionBlockIds = _ids(instructionBlocks);

      for (final assignment in exerciseContent) {
        final exerciseId = assignment['exercise_id']! as String;
        final blockId = assignment['instruction_block_id']! as String;
        expect(instructionBlockIds, contains(blockId), reason: exerciseId);
        expect(
          blockId,
          categoryByExerciseId[exerciseId]!['movement_pattern_id'],
          reason: exerciseId,
        );
      }
    },
  );

  test('uses valid substitution and regression exercise references', () {
    final inventoryIds = inventoryExercises
        .map((exercise) => exercise['id'] as String)
        .toSet();

    for (final assignment in exerciseContent) {
      final exerciseId = assignment['exercise_id']! as String;
      final substitutionIds = _strings(assignment['substitution_ids']);
      final regressionIds = _strings(assignment['regression_ids']);

      expect(substitutionIds, isNotEmpty, reason: exerciseId);
      expect(regressionIds, isNotEmpty, reason: exerciseId);
      expect(substitutionIds.toSet(), hasLength(substitutionIds.length));
      expect(regressionIds.toSet(), hasLength(regressionIds.length));

      for (final referencedId in <String>[
        ...substitutionIds,
        ...regressionIds,
      ]) {
        expect(inventoryIds, contains(referencedId), reason: exerciseId);
        expect(referencedId, isNot(exerciseId), reason: exerciseId);
      }
    }
  });

  test('does not pre-fill detailed muscle, programming, or media fields', () {
    const allowedAssignmentKeys = <String>{
      'exercise_id',
      'instruction_block_id',
      'substitution_ids',
      'regression_ids',
    };
    const deferredKeys = <String>{
      'equipment_ids',
      'level_id',
      'laterality_id',
      'exercise_type_id',
      'primary_region_ids',
      'secondary_region_ids',
      'stabilizer_region_ids',
      'default_load_increment',
      'sets',
      'reps',
      'rir',
      'rest_seconds',
      'thumbnail_id',
      'animation_id',
      'asset_license_ids',
      'content_review_status',
    };

    for (final assignment in exerciseContent) {
      expect(assignment.keys.toSet(), allowedAssignmentKeys);
      expect(assignment.keys.toSet().intersection(deferredKeys), isEmpty);
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

void _expectLocalizedText(Object? value, {required String reason}) {
  final localized = Map<String, Object?>.from(value! as Map);
  expect(localized.keys, unorderedEquals(<String>['en', 'tr']));
  for (final locale in <String>['en', 'tr']) {
    expect((localized[locale]! as String).trim(), isNotEmpty, reason: reason);
  }
}

void _expectLocalizedTextList(
  Object? value, {
  required int minimumLength,
  required String reason,
}) {
  final localized = Map<String, Object?>.from(value! as Map);
  expect(localized.keys, unorderedEquals(<String>['en', 'tr']));
  for (final locale in <String>['en', 'tr']) {
    final items = _strings(localized[locale]);
    expect(items.length, greaterThanOrEqualTo(minimumLength), reason: reason);
    for (final item in items) {
      expect(item.trim(), isNotEmpty, reason: reason);
    }
  }
}
