import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifestFile = File(
    'tool/anatomy/bodyparts3d_region_reduction.v1.json',
  );

  test('defines 56 bilateral render regions without source overlap', () {
    final manifest = Map<String, dynamic>.from(
      jsonDecode(manifestFile.readAsStringSync()) as Map,
    );
    final pairs = (manifest['pairs'] as List)
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList(growable: false);

    expect(manifest['schema_version'], 1);
    expect(
      manifest['contract_status'],
      'working_source_selection_not_product_ontology',
    );
    expect(manifest['bilateral_pair_count'], pairs.length);
    expect(manifest['render_region_count'], pairs.length * 2);
    expect(manifest['render_region_count'], inInclusiveRange(40, 80));
    expect(pairs, hasLength(28));

    final slots = <int>{};
    final sourceConcepts = <String>{};
    final sourceElements = <String>{};

    for (final pair in pairs) {
      expect(pair.keys, isNot(contains('id')));
      expect(pair.keys, isNot(contains('name_en')));
      expect(pair.keys, isNot(contains('name_tr')));

      final slot = pair['slot'] as int;
      expect(slots.add(slot), isTrue, reason: 'Duplicate slot $slot');
      expect((pair['working_label'] as String).trim(), isNotEmpty);

      final right = Map<String, dynamic>.from(pair['right'] as Map);
      final left = Map<String, dynamic>.from(pair['left'] as Map);
      final rightElements = _validateSide(
        side: right,
        sourceConcepts: sourceConcepts,
        sourceElements: sourceElements,
      );
      final leftElements = _validateSide(
        side: left,
        sourceConcepts: sourceConcepts,
        sourceElements: sourceElements,
      );

      expect(
        leftElements,
        rightElements.map((element) => '${element}M').toList(),
        reason: 'Slot $slot must preserve source bilateral pairing',
      );
    }

    expect(slots, equals({...List<int>.generate(28, (index) => index + 1)}));
    expect(sourceConcepts, hasLength(162));
    expect(sourceElements, hasLength(166));
  });

  test('pins the reviewed source and records unresolved coverage gaps', () {
    final manifest = Map<String, dynamic>.from(
      jsonDecode(manifestFile.readAsStringSync()) as Map,
    );

    expect(
      manifest['source_asset_id'],
      'anatomy-source-bodyparts3d-v4-isa-obj99',
    );
    expect(
      manifest['source_archive_sha256'],
      '40665852c49f218326590e204db91064a1ecfc3c6f8cbd7bbbcaac62c7cd409e',
    );
    final metadataHashes = Map<String, dynamic>.from(
      manifest['source_metadata_sha256'] as Map,
    );
    expect(
      metadataHashes['isa_parts_list_e.txt'],
      'ab7796deedd49205e77f3609a1cb8c53e2bbee14ecb5c9a6ca05227469780513',
    );
    expect(
      metadataHashes['isa_element_parts.txt'],
      'a3de74423f943b0d724ae8f59b3a817f87c423a544f8db98113b1980817cbeaf',
    );
    expect(
      manifest['known_source_coverage_gaps'],
      containsAll(<String>[
        'latissimus dorsi',
        'rectus abdominis',
        'internal oblique',
        'transversus abdominis',
      ]),
    );
  });
}

List<String> _validateSide({
  required Map<String, dynamic> side,
  required Set<String> sourceConcepts,
  required Set<String> sourceElements,
}) {
  final concepts = List<String>.from(side['source_concept_ids'] as List);
  final elements = List<String>.from(side['element_file_ids'] as List);

  expect(concepts, isNotEmpty);
  expect(elements, isNotEmpty);

  for (final concept in concepts) {
    expect(concept, matches(RegExp(r'^FMA\d+$')));
    expect(
      sourceConcepts.add(concept),
      isTrue,
      reason: 'Source concept $concept is assigned more than once',
    );
  }
  for (final element in elements) {
    expect(element, matches(RegExp(r'^FJ\d+M?$')));
    expect(
      sourceElements.add(element),
      isTrue,
      reason: 'Source element $element is assigned more than once',
    );
  }

  return elements;
}
