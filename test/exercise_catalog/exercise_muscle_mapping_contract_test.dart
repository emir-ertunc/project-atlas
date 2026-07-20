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
  final mappings = _readJson(
    'tool/exercise_catalog/foundational_exercise_muscle_mappings.v1.json',
  );
  final ontology = _readJson('tool/anatomy/muscle_region_ontology.v1.json');
  final animationContract = _readJson(
    'tool/anatomy/animation/core_exercise_animation_prototypes.v1.json',
  );

  final inventoryExercises = _maps(inventory['exercises']);
  final categoryAssignments = _maps(categories['exercise_categories']);
  final filterAssignments = _maps(filters['exercise_filters']);
  final contentAssignments = _maps(content['exercise_content']);
  final muscleMappings = _maps(mappings['exercise_muscle_mappings']);
  final ontologyGroups = _maps(ontology['groups']);
  final muscleCategories = _maps(categories['muscle_region_categories']);

  test('defines a P3-05 structural muscle mapping contract', () {
    expect(mappings['schema_version'], 1);
    expect(mappings['scope'], 'P3-05');
    expect(mappings['status'], 'structurally_verified_muscle_mapping_contract');
    expect(mappings['source_inventory_id'], inventory['inventory_id']);
    expect(
      mappings['source_category_contract_id'],
      categories['category_contract_id'],
    );
    expect(
      mappings['source_filter_contract_id'],
      filters['filter_contract_id'],
    );
    expect(
      mappings['source_content_contract_id'],
      content['content_contract_id'],
    );
    expect(mappings['muscle_role_order'], <String>[
      'primary_region_ids',
      'secondary_region_ids',
      'stabilizer_region_ids',
    ]);
    expect(
      muscleMappings,
      hasLength(mappings['exercise_muscle_mapping_count'] as int),
    );
  });

  test('assigns one muscle mapping to every foundational exercise', () {
    final inventoryIds = _ids(inventoryExercises);
    final categoryExerciseIds = _exerciseIds(categoryAssignments);
    final filterExerciseIds = _exerciseIds(filterAssignments);
    final contentExerciseIds = _exerciseIds(contentAssignments);
    final mappingExerciseIds = _exerciseIds(muscleMappings);

    expect(categoryExerciseIds, inventoryIds);
    expect(filterExerciseIds, inventoryIds);
    expect(contentExerciseIds, inventoryIds);
    expect(mappingExerciseIds, inventoryIds);
  });

  test('uses only valid side-qualified P2 muscle region IDs', () {
    final ontologyRegionIds = _ontologyRegionIds(ontologyGroups);
    final usedRegionIds = <String>{};

    for (final mapping in muscleMappings) {
      final exerciseId = mapping['exercise_id']! as String;
      final primary = _strings(mapping['primary_region_ids']);
      final secondary = _strings(mapping['secondary_region_ids']);
      final stabilizer = _strings(mapping['stabilizer_region_ids']);

      expect(primary, isNotEmpty, reason: exerciseId);
      _expectUniqueRole(primary, ontologyRegionIds, exerciseId);
      _expectUniqueRole(secondary, ontologyRegionIds, exerciseId);
      _expectUniqueRole(stabilizer, ontologyRegionIds, exerciseId);

      expect(primary.toSet().intersection(secondary.toSet()), isEmpty);
      expect(primary.toSet().intersection(stabilizer.toSet()), isEmpty);
      expect(secondary.toSet().intersection(stabilizer.toSet()), isEmpty);

      usedRegionIds.addAll(primary);
      usedRegionIds.addAll(secondary);
      usedRegionIds.addAll(stabilizer);
    }

    expect(
      _semanticGroupsFromRegions(usedRegionIds),
      containsAll(_ontologyGroupIds(ontologyGroups)),
    );
  });

  test(
    'keeps primary muscles compatible with broad P3-02 muscle categories',
    () {
      final categoryById = {
        for (final category in muscleCategories)
          category['id'] as String: category,
      };
      final assignmentByExerciseId = {
        for (final assignment in categoryAssignments)
          assignment['exercise_id'] as String: assignment,
      };

      for (final mapping in muscleMappings) {
        final exerciseId = mapping['exercise_id']! as String;
        final broadCategoryIds = _strings(
          assignmentByExerciseId[exerciseId]!['muscle_region_category_ids'],
        );
        final allowedPrimaryGroups = <String>{};
        for (final categoryId in broadCategoryIds) {
          allowedPrimaryGroups.addAll(
            _strings(categoryById[categoryId]!['semantic_group_ids']),
          );
        }

        final primaryGroups = _semanticGroupsFromRegions(
          _strings(mapping['primary_region_ids']).toSet(),
        );
        expect(
          allowedPrimaryGroups,
          containsAll(primaryGroups),
          reason: exerciseId,
        );
      }
    },
  );

  test(
    'keeps P2 animation prototype muscles represented in P3-05 mappings',
    () {
      final mappingByExerciseId = {
        for (final mapping in muscleMappings)
          mapping['exercise_id'] as String: mapping,
      };

      for (final animationExercise in _maps(animationContract['exercises'])) {
        final exerciseId = animationExercise['exercise_id']! as String;
        expect(mappingByExerciseId, contains(exerciseId));

        final mapping = mappingByExerciseId[exerciseId]!;
        final primaryOrSecondary = <String>{
          ..._strings(mapping['primary_region_ids']),
          ..._strings(mapping['secondary_region_ids']),
        };
        final allMappedRegions = <String>{
          ...primaryOrSecondary,
          ..._strings(mapping['stabilizer_region_ids']),
        };

        expect(
          primaryOrSecondary,
          containsAll(_strings(animationExercise['primary_region_ids'])),
          reason: exerciseId,
        );
        expect(
          allMappedRegions,
          containsAll(_strings(animationExercise['secondary_region_ids'])),
          reason: exerciseId,
        );
      }
    },
  );

  test(
    'does not mix mapping data with content, programming, or media fields',
    () {
      const allowedAssignmentKeys = <String>{
        'exercise_id',
        'primary_region_ids',
        'secondary_region_ids',
        'stabilizer_region_ids',
      };
      const deferredKeys = <String>{
        'equipment_ids',
        'level_id',
        'laterality_id',
        'exercise_type_id',
        'instruction_block_id',
        'substitution_ids',
        'regression_ids',
        'setup',
        'execution',
        'form_cues',
        'common_errors',
        'sets',
        'reps',
        'rir',
        'rest_seconds',
        'thumbnail_id',
        'animation_id',
        'asset_license_ids',
        'content_review_status',
      };

      for (final mapping in muscleMappings) {
        expect(mapping.keys.toSet(), allowedAssignmentKeys);
        expect(mapping.keys.toSet().intersection(deferredKeys), isEmpty);
      }
    },
  );
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

Set<String> _exerciseIds(List<Map<String, Object?>> records) {
  return records.map((record) => record['exercise_id']! as String).toSet();
}

Set<String> _ids(List<Map<String, Object?>> records) {
  return records.map((record) => record['id']! as String).toSet();
}

Set<String> _ontologyRegionIds(List<Map<String, Object?>> ontologyGroups) {
  return {
    for (final group in ontologyGroups)
      for (final region in (group['regions']! as Map).values)
        Map<String, Object?>.from(region as Map)['id']! as String,
  };
}

Set<String> _ontologyGroupIds(List<Map<String, Object?>> ontologyGroups) {
  return {
    for (final group in ontologyGroups) group['semantic_group_id']! as String,
  };
}

List<String> _strings(Object? value) {
  return [for (final item in value! as List) item as String];
}

void _expectUniqueRole(
  List<String> regionIds,
  Set<String> ontologyRegionIds,
  String exerciseId,
) {
  expect(regionIds.toSet(), hasLength(regionIds.length), reason: exerciseId);
  for (final regionId in regionIds) {
    expect(ontologyRegionIds, contains(regionId), reason: exerciseId);
    expect(
      regionId,
      anyOf(endsWith('_right'), endsWith('_left')),
      reason: exerciseId,
    );
  }
}

Set<String> _semanticGroupsFromRegions(Set<String> regionIds) {
  return {
    for (final regionId in regionIds)
      regionId.replaceFirst(RegExp(r'_(right|left)$'), ''),
  };
}
