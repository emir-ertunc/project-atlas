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
  final mappings = _readJson(
    'tool/exercise_catalog/foundational_exercise_muscle_mappings.v1.json',
  );
  final media = _readJson(
    'tool/exercise_catalog/foundational_exercise_media.v1.json',
  );
  final rig = _readJson('tool/anatomy/animation/shared_humanoid_rig.v1.json');
  final animations = _readJson(
    'tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json',
  );
  final ontology = _readJson('tool/anatomy/muscle_region_ontology.v1.json');

  final inventoryExercises = _maps(inventory['exercises']);
  final categoryAssignments = _maps(categories['exercise_categories']);
  final filterAssignments = _maps(filters['exercise_filters']);
  final muscleMappings = _maps(mappings['exercise_muscle_mappings']);
  final mediaRows = _maps(media['exercise_media']);
  final animationRows = _maps(animations['exercises']);

  test('defines the P3-10 media and animation contracts', () {
    expect(media['schema_version'], 1);
    expect(media['scope'], 'P3-10');
    expect(
      media['status'],
      'procedural_thumbnail_and_animation_binding_contract',
    );
    expect(media['source_inventory_id'], inventory['inventory_id']);
    expect(
      media['source_category_contract_id'],
      categories['category_contract_id'],
    );
    expect(media['source_filter_contract_id'], filters['filter_contract_id']);
    expect(
      media['source_muscle_mapping_contract_id'],
      mappings['muscle_mapping_contract_id'],
    );

    expect(animations['schema_version'], 1);
    expect(animations['scope'], 'P3-10');
    expect(animations['rig_id'], rig['rig_id']);
    expect(animations['source_inventory_id'], inventory['inventory_id']);
    expect(
      animations['source_filter_contract_id'],
      filters['filter_contract_id'],
    );
    expect(
      animations['source_muscle_mapping_contract_id'],
      mappings['muscle_mapping_contract_id'],
    );
    expect(animations['exercise_animation_count'], 30);
    expect(media['animated_exercise_count'], 30);
  });

  test('assigns one procedural thumbnail to every foundational exercise', () {
    const allowedMediaKeys = <String>{
      'exercise_id',
      'thumbnail_id',
      'thumbnail_variant',
      'thumbnail_asset_kind',
      'animation_id',
      'animation_status',
      'license_ids',
      'review_status',
    };
    const forbiddenPathKeys = <String>{
      'file',
      'file_path',
      'asset_path',
      'source_url',
      'external_url',
    };

    final inventoryIds = _ids(inventoryExercises);
    final mediaExerciseIds = _exerciseIds(mediaRows);

    expect(mediaRows, hasLength(media['thumbnail_count'] as int));
    expect(mediaExerciseIds, inventoryIds);

    for (final row in mediaRows) {
      final exerciseId = row['exercise_id']! as String;
      expect(row.keys.toSet(), allowedMediaKeys);
      expect(row.keys.toSet().intersection(forbiddenPathKeys), isEmpty);
      expect(row['thumbnail_id'], 'thumb_${exerciseId}_v1');
      expect(row['thumbnail_asset_kind'], 'procedural_vector_thumbnail');
      expect(row['thumbnail_variant'], matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      expect(row['license_ids'], isNotEmpty, reason: exerciseId);
      expect(row['review_status'], 'internal_structural_check');
    }
  });

  test('binds animations to exactly thirty compound catalog exercises', () {
    final filtersByExerciseId = {
      for (final row in filterAssignments) row['exercise_id'] as String: row,
    };
    final categoriesByExerciseId = {
      for (final row in categoryAssignments) row['exercise_id'] as String: row,
    };
    final mediaByAnimationId = {
      for (final row in mediaRows)
        if (row['animation_id'] != null) row['animation_id'] as String: row,
    };
    final animationIds = animationRows
        .map((row) => row['animation_id'] as String)
        .toSet();
    final animatedExerciseIds = animationRows
        .map((row) => row['exercise_id'] as String)
        .toSet();
    final movementCoverage = <String>{};

    expect(animationRows, hasLength(30));
    expect(animationIds, hasLength(30));
    expect(mediaByAnimationId.keys.toSet(), animationIds);

    for (final row in animationRows) {
      final exerciseId = row['exercise_id']! as String;
      final filter = filtersByExerciseId[exerciseId]!;
      final category = categoriesByExerciseId[exerciseId]!;

      expect(
        {'compound', 'bodyweight_compound'},
        contains(filter['exercise_type_id']),
        reason: exerciseId,
      );
      expect(row['exercise_type'], filter['exercise_type_id']);
      expect(row['movement_pattern'], category['movement_pattern_id']);
      movementCoverage.add(row['movement_pattern'] as String);

      final filterEquipmentIds = _strings(filter['equipment_ids']).toSet();
      final animationEquipmentIds = _strings(row['equipment']).toSet();
      expect(
        filterEquipmentIds.intersection(animationEquipmentIds),
        isNotEmpty,
        reason: exerciseId,
      );

      final mediaRow = mediaByAnimationId[row['animation_id']]!;
      expect(mediaRow['exercise_id'], exerciseId);
      expect(mediaRow['animation_status'], 'available');
    }

    expect(
      movementCoverage,
      containsAll(<String>[
        'squat',
        'hinge',
        'hip_extension',
        'horizontal_push',
        'vertical_push',
        'horizontal_pull',
        'vertical_pull',
        'single_leg_squat',
      ]),
    );

    final unavailableMedia = mediaRows.where(
      (row) => row['animation_id'] == null,
    );
    expect(
      unavailableMedia.every((row) => row['animation_status'] == 'not_started'),
      isTrue,
    );
    expect(animatedExerciseIds, hasLength(30));
  });

  test(
    'keeps animation regions and keyframes compatible with the shared rig',
    () {
      final ontologyRegionIds = _ontologyRegionIds(_maps(ontology['groups']));
      final mappingByExerciseId = {
        for (final row in muscleMappings) row['exercise_id'] as String: row,
      };
      final controlsById = {
        for (final control in _maps(rig['controls']))
          control['id'] as String: control,
      };
      final anchorIds = _maps(
        rig['equipment_anchors'],
      ).map((anchor) => anchor['id'] as String).toSet();
      final expectedDuration = animations['cycle_seconds'] as num;

      for (final animation in animationRows) {
        final exerciseId = animation['exercise_id']! as String;
        final mapping = mappingByExerciseId[exerciseId]!;
        final primaryOrSecondary = <String>{
          ..._strings(mapping['primary_region_ids']),
          ..._strings(mapping['secondary_region_ids']),
        };
        final allMapped = <String>{
          ...primaryOrSecondary,
          ..._strings(mapping['stabilizer_region_ids']),
        };
        final primaryIds = _strings(animation['primary_region_ids']);
        final secondaryIds = _strings(animation['secondary_region_ids']);

        expect(ontologyRegionIds, containsAll(primaryIds), reason: exerciseId);
        expect(
          ontologyRegionIds,
          containsAll(secondaryIds),
          reason: exerciseId,
        );
        expect(primaryOrSecondary, containsAll(primaryIds), reason: exerciseId);
        expect(allMapped, containsAll(secondaryIds), reason: exerciseId);
        expect(anchorIds, containsAll(animation['contact_anchors'] as List));

        final phases = Set<String>.from(animation['phase_tags'] as List);
        final keyframes = _maps(animation['keyframes']);
        expect(keyframes, hasLength(greaterThanOrEqualTo(5)));
        expect(phases, containsAll(<String>['setup', 'finish']));
        expect(keyframes.first['time_seconds'], 0.0);
        expect(keyframes.last['time_seconds'], expectedDuration);
        expect(keyframes.first['controls'], keyframes.last['controls']);

        var previousTime = -1.0;
        for (final keyframe in keyframes) {
          final time = keyframe['time_seconds'] as num;
          expect(time, greaterThan(previousTime), reason: exerciseId);
          previousTime = time.toDouble();
          expect(phases, contains(keyframe['phase']));

          final frameControls = Map<String, Object?>.from(
            keyframe['controls'] as Map,
          );
          for (final entry in frameControls.entries) {
            final control = controlsById[entry.key];
            expect(control, isNotNull, reason: '$exerciseId ${entry.key}');
            expect(
              entry.value,
              inInclusiveRange(control!['min'] as num, control['max'] as num),
              reason: '$exerciseId ${entry.key}',
            );
          }
        }
      }
    },
  );

  test('records only original procedural media licensing for P3-10 assets', () {
    final licenses = _maps(media['licenses']);

    expect(licenses, hasLength(1));
    expect(licenses.single['id'], 'project_atlas_original_procedural_media');
    expect(licenses.single['kind'], 'original_project_asset');
    expect(licenses.single['third_party_source'], isNull);
    expect(
      mediaRows.every(
        (row) =>
            _strings(row['license_ids']).single ==
            'project_atlas_original_procedural_media',
      ),
      isTrue,
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

Set<String> _exerciseIds(List<Map<String, Object?>> records) {
  return records.map((row) => row['exercise_id']! as String).toSet();
}

Set<String> _ids(List<Map<String, Object?>> records) {
  return records.map((row) => row['id']! as String).toSet();
}

List<String> _strings(Object? value) {
  return [for (final item in value! as List) item as String];
}

Set<String> _ontologyRegionIds(List<Map<String, Object?>> ontologyGroups) {
  return {
    for (final group in ontologyGroups)
      for (final region in (group['regions']! as Map).values)
        Map<String, Object?>.from(region as Map)['id']! as String,
  };
}
