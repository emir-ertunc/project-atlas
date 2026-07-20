import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';

final exerciseCatalogProvider = FutureProvider<ExerciseCatalog>((ref) {
  return ExerciseCatalogAssetLoader(rootBundle).load();
});

class ExerciseCatalogAssetLoader {
  const ExerciseCatalogAssetLoader(this.bundle);

  static const inventoryAsset =
      'tool/exercise_catalog/foundational_exercises.v1.json';
  static const categoriesAsset =
      'tool/exercise_catalog/foundational_exercise_categories.v1.json';
  static const filtersAsset =
      'tool/exercise_catalog/foundational_exercise_filters.v1.json';
  static const contentAsset =
      'tool/exercise_catalog/foundational_exercise_content.v1.json';
  static const muscleMappingsAsset =
      'tool/exercise_catalog/foundational_exercise_muscle_mappings.v1.json';
  static const mediaAsset =
      'tool/exercise_catalog/foundational_exercise_media.v1.json';
  static const muscleOntologyAsset =
      'tool/anatomy/muscle_region_ontology.v1.json';
  static const compoundAnimationsAsset =
      'tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json';

  final AssetBundle bundle;

  Future<ExerciseCatalog> load() async {
    final documents = await Future.wait([
      bundle.loadString(inventoryAsset),
      bundle.loadString(categoriesAsset),
      bundle.loadString(filtersAsset),
      bundle.loadString(contentAsset),
      bundle.loadString(muscleMappingsAsset),
      bundle.loadString(mediaAsset),
      bundle.loadString(muscleOntologyAsset),
    ]);

    return ExerciseCatalog.fromJsonDocuments(
      inventoryJson: documents[0],
      categoriesJson: documents[1],
      filtersJson: documents[2],
      contentJson: documents[3],
      muscleMappingsJson: documents[4],
      mediaJson: documents[5],
      muscleOntologyJson: documents[6],
    );
  }
}
