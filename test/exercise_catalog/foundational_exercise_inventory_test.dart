import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final inventory = _readJson(
    'tool/exercise_catalog/foundational_exercises.v1.json',
  );
  final exercises = _maps(inventory['exercises']);
  final groups = _maps(inventory['inventory_groups']);

  test('defines exactly 120 foundational exercise inventory entries', () {
    expect(inventory['schema_version'], 1);
    expect(inventory['scope'], 'P3-01');
    expect(inventory['status'], 'inventory_only');
    expect(inventory['exercise_count'], 120);
    expect(exercises, hasLength(120));

    final ids = exercises.map((exercise) => exercise['id'] as String).toList();
    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      expect(id.length, lessThanOrEqualTo(128));
    }

    final displayOrders = exercises
        .map((exercise) => exercise['display_order'] as int)
        .toList();
    expect(displayOrders, List<int>.generate(120, (index) => index + 1));
  });

  test('keeps inventory names localized and non-empty', () {
    final englishNames = <String>{};
    final turkishNames = <String>{};

    for (final exercise in exercises) {
      final names = Map<String, Object?>.from(exercise['names'] as Map);
      expect(names.keys, unorderedEquals(<String>['en', 'tr']));

      final english = names['en']! as String;
      final turkish = names['tr']! as String;
      expect(english.trim(), isNotEmpty, reason: exercise['id'] as String);
      expect(turkish.trim(), isNotEmpty, reason: exercise['id'] as String);
      englishNames.add(english.toLowerCase());
      turkishNames.add(turkish.toLowerCase());
    }

    expect(englishNames, hasLength(120));
    expect(turkishNames.length, greaterThanOrEqualTo(100));
  });

  test(
    'balances the P3-01 planning groups without defining P3-02 categories',
    () {
      final groupIds = groups.map((group) => group['id'] as String).toSet();
      expect(groupIds, hasLength(12));

      final counts = <String, int>{};
      for (final exercise in exercises) {
        final groupId = exercise['inventory_group'] as String;
        expect(groupIds, contains(groupId));
        counts[groupId] = (counts[groupId] ?? 0) + 1;
      }

      for (final group in groups) {
        final groupId = group['id'] as String;
        expect(counts[groupId], group['target_count'], reason: groupId);
      }
    },
  );

  test('contains every P2 animation prototype exercise ID', () {
    final animationContract = _readJson(
      'tool/anatomy/animation/core_exercise_animation_prototypes.v1.json',
    );
    final inventoryIds = exercises
        .map((exercise) => exercise['id'] as String)
        .toSet();
    final animationIds = _maps(
      animationContract['exercises'],
    ).map((exercise) => exercise['exercise_id'] as String);

    expect(inventoryIds, containsAll(animationIds));
  });

  test(
    'does not pre-fill later catalog fields before their checklist items',
    () {
      const allowedEntryKeys = <String>{
        'display_order',
        'id',
        'inventory_group',
        'names',
      };
      const deferredKeys = <String>{
        'movement_pattern',
        'exercise_type',
        'primary_region_ids',
        'secondary_region_ids',
        'stabilizer_region_ids',
        'equipment',
        'difficulty',
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
      };

      for (final exercise in exercises) {
        expect(exercise.keys.toSet(), allowedEntryKeys);
        expect(
          exercise.keys.toSet().intersection(deferredKeys),
          isEmpty,
          reason: exercise['id'] as String,
        );
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
