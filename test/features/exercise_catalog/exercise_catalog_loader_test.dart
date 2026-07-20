import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';

import '../../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog catalog;

  setUpAll(() {
    catalog = loadTestExerciseCatalog();
  });

  test('loads the complete foundational catalog into one app model', () {
    expect(catalog.exercises, hasLength(120));
    expect(catalog.movementPatterns, hasLength(31));
    expect(catalog.muscleRegionCategories, hasLength(15));
    expect(catalog.equipment, hasLength(29));
    expect(catalog.levels, hasLength(4));
    expect(catalog.lateralities, hasLength(5));
    expect(catalog.exerciseTypes, hasLength(7));
    expect(
      catalog.exercises.every(
        (exercise) =>
            exercise.media.thumbnailAssetKind == 'procedural_vector_thumbnail',
      ),
      isTrue,
    );
    expect(
      catalog.exercises.where((exercise) => exercise.media.hasAnimation),
      hasLength(30),
    );
    expect(catalog.availableAnimationIds, hasLength(30));
    expect(
      catalog.exercises
          .map((exercise) => exercise.media.animationId)
          .whereType<String>()
          .toSet(),
      catalog.availableAnimationIds,
    );
  });

  test('searches across exercise names and resolved metadata', () {
    final benchMatches = catalog.query(localeCode: 'en', searchTerm: 'bench');
    expect(
      benchMatches.map((exercise) => exercise.id),
      containsAll(['barbell_bench_press', 'dumbbell_bench_press']),
    );

    final chestMatches = catalog.query(localeCode: 'en', searchTerm: 'chest');
    expect(
      chestMatches.map((exercise) => exercise.id),
      contains('barbell_bench_press'),
    );
  });

  test(
    'filters by movement, equipment, and level without mutating results',
    () {
      final filtered = catalog.query(
        localeCode: 'en',
        filters: const ExerciseCatalogFilters(
          movementPatternIds: {'horizontal_push'},
          equipmentIds: {'barbell'},
          levelIds: {'intermediate'},
        ),
      );

      expect(
        filtered.map((exercise) => exercise.id),
        contains('barbell_bench_press'),
      );
      expect(
        filtered.every(
          (exercise) =>
              exercise.movementPattern.id == 'horizontal_push' &&
              exercise.equipmentIds.contains('barbell') &&
              exercise.level.id == 'intermediate',
        ),
        isTrue,
      );
    },
  );

  test(
    'resolves detail content, related exercises, and muscle-region names',
    () {
      final bench = catalog.exerciseById('barbell_bench_press');

      expect(bench, isNotNull);
      expect(bench!.content.setup.resolve('en'), isNotEmpty);
      expect(bench.content.execution.resolve('en'), isNotEmpty);
      expect(bench.content.formCues.resolve('en'), isNotEmpty);
      expect(bench.content.commonErrors.resolve('en'), isNotEmpty);
      expect(
        catalog.resolveExercises(bench.content.substitutionIds),
        isNotEmpty,
      );
      expect(catalog.resolveExercises(bench.content.regressionIds), isNotEmpty);
      expect(
        bench.muscleMapping.primaryRegionIds,
        contains('pectoralis_major_right'),
      );
      expect(bench.media.thumbnailId, 'thumb_barbell_bench_press_v1');
      expect(bench.media.animationId, 'anim_barbell_bench_press_v1');
      expect(
        catalog.muscleRegionName('pectoralis_major_right', 'en'),
        'Right pectoralis major',
      );
    },
  );

  testWidgets('declares the canonical catalog contracts as Flutter assets', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());

    final bundledCatalog = await tester.runAsync(() async {
      final inventoryJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.inventoryAsset)
          .timeout(const Duration(seconds: 2));
      final categoriesJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.categoriesAsset)
          .timeout(const Duration(seconds: 2));
      final filtersJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.filtersAsset)
          .timeout(const Duration(seconds: 2));
      final contentJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.contentAsset)
          .timeout(const Duration(seconds: 2));
      final muscleMappingsJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.muscleMappingsAsset)
          .timeout(const Duration(seconds: 2));
      final mediaJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.mediaAsset)
          .timeout(const Duration(seconds: 2));
      final compoundAnimationsJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.compoundAnimationsAsset)
          .timeout(const Duration(seconds: 2));
      final muscleOntologyJson = await rootBundle
          .loadString(ExerciseCatalogAssetLoader.muscleOntologyAsset)
          .timeout(const Duration(seconds: 2));

      expect(
        mediaJson,
        contains('project_atlas_foundational_exercise_media_v1'),
      );
      expect(
        compoundAnimationsJson,
        contains('project_atlas_compound_exercise_animation_prototypes_v1'),
      );

      return ExerciseCatalog.fromJsonDocuments(
        inventoryJson: inventoryJson,
        categoriesJson: categoriesJson,
        filtersJson: filtersJson,
        contentJson: contentJson,
        muscleMappingsJson: muscleMappingsJson,
        mediaJson: mediaJson,
        compoundAnimationsJson: compoundAnimationsJson,
        muscleOntologyJson: muscleOntologyJson,
      );
    });

    expect(bundledCatalog, isNotNull);
    expect(bundledCatalog!.exercises, hasLength(120));
    expect(bundledCatalog.availableAnimationIds, hasLength(30));
    expect(bundledCatalog.exerciseById('barbell_bench_press'), isNotNull);
  });
}
