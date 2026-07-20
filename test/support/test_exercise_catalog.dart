import 'dart:io';

import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';

ExerciseCatalog loadTestExerciseCatalog() {
  return ExerciseCatalog.fromJsonDocuments(
    inventoryJson: _read(
      'tool/exercise_catalog/foundational_exercises.v1.json',
    ),
    categoriesJson: _read(
      'tool/exercise_catalog/foundational_exercise_categories.v1.json',
    ),
    filtersJson: _read(
      'tool/exercise_catalog/foundational_exercise_filters.v1.json',
    ),
    contentJson: _read(
      'tool/exercise_catalog/foundational_exercise_content.v1.json',
    ),
    muscleMappingsJson: _read(
      'tool/exercise_catalog/foundational_exercise_muscle_mappings.v1.json',
    ),
    mediaJson: _read(
      'tool/exercise_catalog/foundational_exercise_media.v1.json',
    ),
    compoundAnimationsJson: _read(
      'tool/anatomy/animation/compound_exercise_animation_prototypes.v1.json',
    ),
    muscleOntologyJson: _read('tool/anatomy/muscle_region_ontology.v1.json'),
  );
}

String _read(String path) => File(path).readAsStringSync();
