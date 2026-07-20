import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final ontologyFile = File('tool/anatomy/muscle_region_ontology.v1.json');
  final reductionFile = File(
    'tool/anatomy/bodyparts3d_region_reduction.v1.json',
  );

  test('defines stable bilateral identifiers for all reduction slots', () {
    final ontology = _readJson(ontologyFile);
    final reduction = _readJson(reductionFile);
    final groups = _maps(ontology['groups']);
    final reductionPairs = _maps(reduction['pairs']);
    final reductionSlots = reductionPairs
        .map((pair) => pair['slot'] as int)
        .toSet();

    expect(ontology['schema_version'], 1);
    expect(ontology['supported_locales'], <String>['en', 'tr']);
    expect(ontology['semantic_group_count'], groups.length);
    expect(ontology['muscle_region_count'], groups.length * 2);
    expect(groups, hasLength(28));
    expect(ontology['muscle_region_count'], 56);
    expect(
      groups.map((group) => group['semantic_group_id']),
      _expectedGroupIds,
    );

    final groupIds = <String>{};
    final regionIds = <String>{};
    final slots = <int>{};

    for (final group in groups) {
      final slot = group['reduction_slot'] as int;
      final groupId = group['semantic_group_id'] as String;
      final groupNames = _names(group['names']);
      final regions = Map<String, dynamic>.from(group['regions'] as Map);

      expect(reductionSlots, contains(slot));
      expect(slots.add(slot), isTrue, reason: 'Duplicate slot $slot');
      expect(groupId, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      expect(
        groupIds.add(groupId),
        isTrue,
        reason: 'Duplicate semantic group ID $groupId',
      );
      expect(groupNames.keys, unorderedEquals(<String>['en', 'tr']));
      expect(groupNames.values, everyElement(isNotEmpty));
      expect(regions.keys, unorderedEquals(<String>['right', 'left']));
      expect(group.keys, isNot(contains('source_concept_ids')));
      expect(group.keys, isNot(contains('element_file_ids')));

      for (final side in <String>['right', 'left']) {
        final region = Map<String, dynamic>.from(regions[side] as Map);
        final regionId = region['id'] as String;
        final names = _names(region['names']);

        expect(regionId, '${groupId}_$side');
        expect(regionId, matches(RegExp(r'^[a-z][a-z0-9_]*_(right|left)$')));
        expect(
          regionIds.add(regionId),
          isTrue,
          reason: 'Duplicate muscle region ID $regionId',
        );
        expect(names.keys, unorderedEquals(<String>['en', 'tr']));
        expect(names['en'], startsWith(side == 'right' ? 'Right ' : 'Left '));
        expect(names['tr'], startsWith(side == 'right' ? 'Sağ ' : 'Sol '));
      }
    }

    expect(slots, reductionSlots);
    expect(regionIds, hasLength(56));
    expect(ontology['deprecated_region_ids'], isEmpty);
  });

  test('pins the source reduction contract', () {
    final ontology = _readJson(ontologyFile);

    expect(
      ontology['source_reduction_file'],
      'bodyparts3d_region_reduction.v1.json',
    );
    expect(
      ontology['source_reduction_sha256'],
      'b4e6cf5dae12b674511981bf2a8b60d258d933db6bf38c3054e3b33a3322a3cf',
    );
    expect(ontology['id_format'], '{semantic_group_id}_{side}');
  });
}

Map<String, dynamic> _readJson(File file) =>
    Map<String, dynamic>.from(jsonDecode(file.readAsStringSync()) as Map);

List<Map<String, dynamic>> _maps(Object? value) => (value as List)
    .map((entry) => Map<String, dynamic>.from(entry as Map))
    .toList(growable: false);

Map<String, String> _names(Object? value) =>
    Map<String, String>.from(value as Map);

const _expectedGroupIds = <String>[
  'pectoralis_major',
  'pectoralis_minor',
  'serratus_anterior',
  'deltoid_anterior',
  'deltoid_lateral',
  'deltoid_posterior',
  'biceps_brachii',
  'brachialis',
  'triceps_brachii',
  'forearm_flexors_pronators',
  'forearm_extensors_supinators',
  'trapezius',
  'rhomboids',
  'rotator_cuff',
  'teres_major',
  'erector_spinae',
  'external_oblique',
  'gluteus_maximus',
  'gluteus_medius_minimus',
  'hip_adductors',
  'iliopsoas',
  'quadriceps',
  'hamstrings',
  'tibialis_anterior',
  'gastrocnemius',
  'soleus',
  'fibularis',
  'hip_external_rotators_deep',
];
