import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final budgetFile = File('tool/anatomy/anatomy_asset_budgets.v1.json');

  test('defines CI budgets for every anatomy GLB LOD', () {
    final budget = Map<String, dynamic>.from(
      jsonDecode(budgetFile.readAsStringSync()) as Map,
    );
    final requiredLods = Set<String>.from(budget['required_lods'] as List);
    final budgetsByLod = Map<String, dynamic>.from(
      budget['budgets_by_lod'] as Map,
    );
    final referenceOutputs = (budget['reference_outputs'] as List)
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList(growable: false);

    expect(budget['schema_version'], 1);
    expect(budget['pipeline_manifest_schema_version'], 1);
    expect(budget['expected_region_count'], 56);
    expect(requiredLods, <String>{'lod0', 'lod1', 'lod2'});
    expect(budgetsByLod.keys.toSet(), requiredLods);
    expect(
      referenceOutputs.map((output) => output['lod'] as String).toSet(),
      requiredLods,
    );

    for (final output in referenceOutputs) {
      final lod = output['lod'] as String;
      final limits = Map<String, dynamic>.from(budgetsByLod[lod] as Map);
      expect(output['size_bytes'], lessThanOrEqualTo(limits['max_size_bytes']));
      expect(
        output['vertex_count'],
        lessThanOrEqualTo(limits['max_vertex_count']),
      );
      expect(
        output['triangle_count'],
        lessThanOrEqualTo(limits['max_triangle_count']),
      );
      expect(
        output['primitive_draw_call_count'],
        lessThanOrEqualTo(limits['max_primitive_draw_calls']),
      );
      expect(
        output['material_count'],
        lessThanOrEqualTo(limits['max_material_count']),
      );
      expect(output['sha256'], matches(RegExp(r'^[a-f0-9]{64}$')));
    }
  });

  test(
    'requires complete legal metadata before anatomy assets can be bundled',
    () {
      final budget = Map<String, dynamic>.from(
        jsonDecode(budgetFile.readAsStringSync()) as Map,
      );
      final licenseMetadata = Map<String, dynamic>.from(
        budget['required_license_metadata'] as Map,
      );

      expect(licenseMetadata['current_catalog_license'], 'CC-BY-4.0');
      expect(
        licenseMetadata['conservative_geometry_license'],
        'CC-BY-SA-2.1-JP',
      );
      expect(
        licenseMetadata['source_license_url'],
        'https://dbarchive.biosciencedbc.jp/data/bodyparts3d/',
      );
      expect(
        licenseMetadata['required_attribution_contains'],
        containsAll(<String>[
          'The Database Center for Life Science',
          'CC Attribution 4.0 International',
          'CC Attribution-Share Alike 2.1 Japan',
        ]),
      );
      expect(
        licenseMetadata['minimum_modification_count'],
        greaterThanOrEqualTo(6),
      );
    },
  );
}
