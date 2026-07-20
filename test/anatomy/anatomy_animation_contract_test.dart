import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final rigFile = File('tool/anatomy/animation/shared_humanoid_rig.v1.json');
  final animationsFile = File(
    'tool/anatomy/animation/core_exercise_animation_prototypes.v1.json',
  );
  final ontologyFile = File('tool/anatomy/muscle_region_ontology.v1.json');

  test('defines a shared rig with bounded controls and semantic bindings', () {
    final rig = _readJson(rigFile);
    final ontologyRegionIds = _ontologyRegionIds(_readJson(ontologyFile));
    final joints = _maps(rig['rest_pose']['joints']);
    final bones = _maps(rig['bones']);
    final controls = _maps(rig['controls']);
    final bindings = _maps(rig['muscle_region_bindings']);

    expect(rig['schema_version'], 1);
    expect(rig['rig_id'], 'project_atlas_shared_humanoid_rig_v1');
    expect(
      joints.map((joint) => joint['id']).toSet(),
      hasLength(joints.length),
    );
    expect(controls, hasLength(greaterThanOrEqualTo(20)));

    final jointIds = joints.map((joint) => joint['id'] as String).toSet();
    for (final bone in bones) {
      expect(jointIds, contains(bone['parent_joint']));
      expect(jointIds, contains(bone['child_joint']));
    }

    for (final control in controls) {
      expect(control['min'], lessThan(control['max']));
      expect(
        control['default'],
        inInclusiveRange(control['min'], control['max']),
      );
    }

    for (final binding in bindings) {
      expect(ontologyRegionIds, contains(binding['region_id']));
      for (final driver in binding['drivers'] as List) {
        expect(jointIds, contains(driver));
      }
    }
  });

  test('defines ten loopable core exercise animation prototypes', () {
    final rig = _readJson(rigFile);
    final animations = _readJson(animationsFile);
    final ontologyRegionIds = _ontologyRegionIds(_readJson(ontologyFile));
    final controls = _maps(rig['controls']);
    final controlById = {
      for (final control in controls) control['id'] as String: control,
    };
    final anchors = _maps(
      rig['equipment_anchors'],
    ).map((anchor) => anchor['id'] as String).toSet();
    final exercises = _maps(animations['exercises']);

    expect(animations['schema_version'], 1);
    expect(animations['rig_id'], rig['rig_id']);
    expect(animations['fps'], greaterThanOrEqualTo(24));
    expect(exercises, hasLength(10));
    expect(
      exercises.map((exercise) => exercise['movement_pattern']).toSet(),
      hasLength(greaterThanOrEqualTo(6)),
    );

    for (final exercise in exercises) {
      final exerciseId = exercise['exercise_id'] as String;
      final keyframes = _maps(exercise['keyframes']);
      final phases = Set<String>.from(exercise['phase_tags'] as List);
      expect(keyframes, hasLength(greaterThanOrEqualTo(4)));
      expect(phases, containsAll(<String>['setup', 'finish']));
      expect(exercise['names'].keys, unorderedEquals(<String>['en', 'tr']));

      for (final regionListKey in <String>[
        'primary_region_ids',
        'secondary_region_ids',
      ]) {
        final ids = Set<String>.from(exercise[regionListKey] as List);
        expect(ids, isNotEmpty, reason: '$exerciseId $regionListKey');
        expect(ontologyRegionIds, containsAll(ids));
      }

      expect(anchors, containsAll(exercise['contact_anchors'] as List));
      expect(keyframes.first['time_seconds'], 0.0);
      expect(keyframes.last['time_seconds'], animations['cycle_seconds']);
      expect(keyframes.first['controls'], keyframes.last['controls']);

      var previousTime = -1.0;
      for (final keyframe in keyframes) {
        final time = keyframe['time_seconds'] as num;
        expect(time, greaterThan(previousTime), reason: exerciseId);
        previousTime = time.toDouble();
        expect(phases, contains(keyframe['phase']));
        final frameControls = Map<String, dynamic>.from(
          keyframe['controls'] as Map,
        );
        for (final entry in frameControls.entries) {
          final control = controlById[entry.key];
          expect(control, isNotNull, reason: '$exerciseId ${entry.key}');
          expect(
            entry.value,
            inInclusiveRange(control!['min'], control['max']),
            reason: '$exerciseId ${entry.key}',
          );
        }
      }
    }
  });
}

Map<String, dynamic> _readJson(File file) =>
    Map<String, dynamic>.from(jsonDecode(file.readAsStringSync()) as Map);

List<Map<String, dynamic>> _maps(Object? value) => (value as List)
    .map((entry) => Map<String, dynamic>.from(entry as Map))
    .toList(growable: false);

Set<String> _ontologyRegionIds(Map<String, dynamic> ontology) {
  final groups = _maps(ontology['groups']);
  return {
    for (final group in groups)
      for (final side in <String>['right', 'left'])
        Map<String, dynamic>.from(
              Map<String, dynamic>.from(group['regions'] as Map)[side] as Map,
            )['id']
            as String,
  };
}
