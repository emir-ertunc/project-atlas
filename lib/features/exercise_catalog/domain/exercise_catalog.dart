import 'dart:convert';

enum ExerciseCatalogFacet {
  movementPattern,
  muscleRegion,
  equipment,
  level,
  laterality,
  exerciseType,
}

class CatalogLocalizedText {
  const CatalogLocalizedText(this.values);

  factory CatalogLocalizedText.fromJson(Object? json, String fieldName) {
    final source = _asMap(json, fieldName);
    return CatalogLocalizedText(
      Map.unmodifiable(
        source.map((key, value) => MapEntry(key, _asString(value, key))),
      ),
    );
  }

  final Map<String, String> values;

  String resolve(String localeCode) {
    final normalizedLocale = localeCode.toLowerCase();
    return values[normalizedLocale] ??
        values[normalizedLocale.split('_').first] ??
        values['en'] ??
        (values.isEmpty ? '' : values.values.first);
  }

  Iterable<String> get searchableValues => values.values;
}

class CatalogLocalizedList {
  const CatalogLocalizedList(this.values);

  factory CatalogLocalizedList.fromJson(Object? json, String fieldName) {
    final source = _asMap(json, fieldName);
    return CatalogLocalizedList(
      Map.unmodifiable(
        source.map(
          (key, value) => MapEntry(
            key,
            List<String>.unmodifiable(_asStringList(value, '$fieldName.$key')),
          ),
        ),
      ),
    );
  }

  final Map<String, List<String>> values;

  List<String> resolve(String localeCode) {
    final normalizedLocale = localeCode.toLowerCase();
    return values[normalizedLocale] ??
        values[normalizedLocale.split('_').first] ??
        values['en'] ??
        (values.isEmpty ? const <String>[] : values.values.first);
  }

  Iterable<String> get searchableValues =>
      values.values.expand((items) => items);
}

class CatalogOption {
  const CatalogOption({
    required this.id,
    required this.displayOrder,
    required this.names,
  });

  factory CatalogOption.fromJson(Map<String, Object?> json) {
    return CatalogOption(
      id: _asString(json['id'], 'id'),
      displayOrder: _asInt(json['display_order'], 'display_order'),
      names: CatalogLocalizedText.fromJson(json['names'], 'names'),
    );
  }

  final String id;
  final int displayOrder;
  final CatalogLocalizedText names;

  String name(String localeCode) => names.resolve(localeCode);
}

class ExerciseInstructionContent {
  const ExerciseInstructionContent({
    required this.setup,
    required this.execution,
    required this.formCues,
    required this.commonErrors,
    required this.substitutionIds,
    required this.regressionIds,
  });

  final CatalogLocalizedText setup;
  final CatalogLocalizedText execution;
  final CatalogLocalizedList formCues;
  final CatalogLocalizedList commonErrors;
  final List<String> substitutionIds;
  final List<String> regressionIds;
}

class ExerciseMuscleMapping {
  const ExerciseMuscleMapping({
    required this.primaryRegionIds,
    required this.secondaryRegionIds,
    required this.stabilizerRegionIds,
  });

  factory ExerciseMuscleMapping.fromJson(Map<String, Object?> json) {
    return ExerciseMuscleMapping(
      primaryRegionIds: List.unmodifiable(
        _asStringList(json['primary_region_ids'], 'primary_region_ids'),
      ),
      secondaryRegionIds: List.unmodifiable(
        _asStringList(json['secondary_region_ids'], 'secondary_region_ids'),
      ),
      stabilizerRegionIds: List.unmodifiable(
        _asStringList(json['stabilizer_region_ids'], 'stabilizer_region_ids'),
      ),
    );
  }

  final List<String> primaryRegionIds;
  final List<String> secondaryRegionIds;
  final List<String> stabilizerRegionIds;
}

class ExerciseMedia {
  const ExerciseMedia({
    required this.thumbnailId,
    required this.thumbnailVariant,
    required this.thumbnailAssetKind,
    required this.animationStatus,
    required this.licenseIds,
    required this.reviewStatus,
    this.animationId,
  });

  factory ExerciseMedia.fromJson(Map<String, Object?> json) {
    return ExerciseMedia(
      thumbnailId: _asString(json['thumbnail_id'], 'thumbnail_id'),
      thumbnailVariant: _asString(
        json['thumbnail_variant'],
        'thumbnail_variant',
      ),
      thumbnailAssetKind: _asString(
        json['thumbnail_asset_kind'],
        'thumbnail_asset_kind',
      ),
      animationId: _asOptionalString(json['animation_id'], 'animation_id'),
      animationStatus: _asString(json['animation_status'], 'animation_status'),
      licenseIds: List.unmodifiable(
        _asStringList(json['license_ids'], 'license_ids'),
      ),
      reviewStatus: _asString(json['review_status'], 'review_status'),
    );
  }

  final String thumbnailId;
  final String thumbnailVariant;
  final String thumbnailAssetKind;
  final String? animationId;
  final String animationStatus;
  final List<String> licenseIds;
  final String reviewStatus;

  bool get hasAnimation => animationId != null;
}

class ExerciseCatalogEntry {
  const ExerciseCatalogEntry({
    required this.id,
    required this.displayOrder,
    required this.inventoryGroup,
    required this.names,
    required this.movementPattern,
    required this.muscleRegionCategories,
    required this.equipment,
    required this.level,
    required this.laterality,
    required this.exerciseType,
    required this.content,
    required this.muscleMapping,
    required this.media,
  });

  final String id;
  final int displayOrder;
  final String inventoryGroup;
  final CatalogLocalizedText names;
  final CatalogOption movementPattern;
  final List<CatalogOption> muscleRegionCategories;
  final List<CatalogOption> equipment;
  final CatalogOption level;
  final CatalogOption laterality;
  final CatalogOption exerciseType;
  final ExerciseInstructionContent content;
  final ExerciseMuscleMapping muscleMapping;
  final ExerciseMedia media;

  String name(String localeCode) => names.resolve(localeCode);

  List<String> get muscleRegionCategoryIds =>
      muscleRegionCategories.map((option) => option.id).toList(growable: false);

  List<String> get equipmentIds =>
      equipment.map((option) => option.id).toList(growable: false);
}

class ExerciseCatalogFilters {
  const ExerciseCatalogFilters({
    this.movementPatternIds = const <String>{},
    this.muscleRegionCategoryIds = const <String>{},
    this.equipmentIds = const <String>{},
    this.levelIds = const <String>{},
    this.lateralityIds = const <String>{},
    this.exerciseTypeIds = const <String>{},
  });

  final Set<String> movementPatternIds;
  final Set<String> muscleRegionCategoryIds;
  final Set<String> equipmentIds;
  final Set<String> levelIds;
  final Set<String> lateralityIds;
  final Set<String> exerciseTypeIds;

  bool get isEmpty =>
      movementPatternIds.isEmpty &&
      muscleRegionCategoryIds.isEmpty &&
      equipmentIds.isEmpty &&
      levelIds.isEmpty &&
      lateralityIds.isEmpty &&
      exerciseTypeIds.isEmpty;

  ExerciseCatalogFilters toggle(ExerciseCatalogFacet facet, String id) {
    Set<String> toggled(Set<String> source) {
      final next = Set<String>.of(source);
      if (!next.add(id)) {
        next.remove(id);
      }
      return Set.unmodifiable(next);
    }

    return switch (facet) {
      ExerciseCatalogFacet.movementPattern => copyWith(
        movementPatternIds: toggled(movementPatternIds),
      ),
      ExerciseCatalogFacet.muscleRegion => copyWith(
        muscleRegionCategoryIds: toggled(muscleRegionCategoryIds),
      ),
      ExerciseCatalogFacet.equipment => copyWith(
        equipmentIds: toggled(equipmentIds),
      ),
      ExerciseCatalogFacet.level => copyWith(levelIds: toggled(levelIds)),
      ExerciseCatalogFacet.laterality => copyWith(
        lateralityIds: toggled(lateralityIds),
      ),
      ExerciseCatalogFacet.exerciseType => copyWith(
        exerciseTypeIds: toggled(exerciseTypeIds),
      ),
    };
  }

  ExerciseCatalogFilters copyWith({
    Set<String>? movementPatternIds,
    Set<String>? muscleRegionCategoryIds,
    Set<String>? equipmentIds,
    Set<String>? levelIds,
    Set<String>? lateralityIds,
    Set<String>? exerciseTypeIds,
  }) {
    return ExerciseCatalogFilters(
      movementPatternIds: movementPatternIds ?? this.movementPatternIds,
      muscleRegionCategoryIds:
          muscleRegionCategoryIds ?? this.muscleRegionCategoryIds,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      levelIds: levelIds ?? this.levelIds,
      lateralityIds: lateralityIds ?? this.lateralityIds,
      exerciseTypeIds: exerciseTypeIds ?? this.exerciseTypeIds,
    );
  }

  bool contains(ExerciseCatalogFacet facet, String id) {
    return switch (facet) {
      ExerciseCatalogFacet.movementPattern => movementPatternIds.contains(id),
      ExerciseCatalogFacet.muscleRegion => muscleRegionCategoryIds.contains(id),
      ExerciseCatalogFacet.equipment => equipmentIds.contains(id),
      ExerciseCatalogFacet.level => levelIds.contains(id),
      ExerciseCatalogFacet.laterality => lateralityIds.contains(id),
      ExerciseCatalogFacet.exerciseType => exerciseTypeIds.contains(id),
    };
  }
}

class ExerciseCatalog {
  ExerciseCatalog._({
    required List<ExerciseCatalogEntry> exercises,
    required this.movementPatterns,
    required this.muscleRegionCategories,
    required this.equipment,
    required this.levels,
    required this.lateralities,
    required this.exerciseTypes,
    required this.muscleRegionNames,
    required Set<String> availableAnimationIds,
  }) : exercises = List.unmodifiable(exercises),
       availableAnimationIds = Set.unmodifiable(availableAnimationIds),
       exercisesById = Map.unmodifiable({
         for (final exercise in exercises) exercise.id: exercise,
       });

  factory ExerciseCatalog.fromJsonDocuments({
    required String inventoryJson,
    required String categoriesJson,
    required String filtersJson,
    required String contentJson,
    required String muscleMappingsJson,
    required String mediaJson,
    required String compoundAnimationsJson,
    required String muscleOntologyJson,
  }) {
    final inventory = _decodeDocument(inventoryJson, 'inventory');
    final categories = _decodeDocument(categoriesJson, 'categories');
    final filters = _decodeDocument(filtersJson, 'filters');
    final content = _decodeDocument(contentJson, 'content');
    final muscleMappings = _decodeDocument(
      muscleMappingsJson,
      'muscleMappings',
    );
    final media = _decodeDocument(mediaJson, 'media');
    final compoundAnimations = _decodeDocument(
      compoundAnimationsJson,
      'compoundAnimations',
    );
    final muscleOntology = _decodeDocument(
      muscleOntologyJson,
      'muscleOntology',
    );

    final movementPatterns = _optionsById(
      _asObjectList(categories, 'movement_patterns'),
    );
    final muscleRegionCategories = _optionsById(
      _asObjectList(categories, 'muscle_region_categories'),
    );
    final equipmentOptions = _optionsById(
      _asObjectList(filters, 'equipment_filters'),
    );
    final levelOptions = _optionsById(_asObjectList(filters, 'level_filters'));
    final lateralityOptions = _optionsById(
      _asObjectList(filters, 'laterality_filters'),
    );
    final exerciseTypeOptions = _optionsById(
      _asObjectList(filters, 'exercise_type_filters'),
    );
    final categoryAssignments = _exerciseCategoryAssignments(categories);
    final filterAssignments = _exerciseFilterAssignments(filters);
    final instructionBlocks = _instructionBlocks(content);
    final exerciseContent = _exerciseContentAssignments(content);
    final exerciseMuscleMappings = _exerciseMuscleMappings(muscleMappings);
    final exerciseMedia = _exerciseMedia(media);
    final availableAnimationIds = _compoundAnimationIds(
      compoundAnimations,
      expectedAnimationSetId: _asString(
        media['animation_set_id'],
        'media.animation_set_id',
      ),
    );
    _validateMediaAnimationBindings(exerciseMedia, availableAnimationIds);
    final muscleRegionNames = _muscleRegionNames(muscleOntology);

    final inventoryRows = _asObjectList(inventory, 'exercises')
      ..sort(
        (left, right) => _asInt(
          left['display_order'],
          'display_order',
        ).compareTo(_asInt(right['display_order'], 'display_order')),
      );

    final exercises = <ExerciseCatalogEntry>[];
    for (final row in inventoryRows) {
      final id = _asString(row['id'], 'exercise.id');
      final categoryAssignment = _requiredLookup(
        categoryAssignments,
        id,
        'category assignment',
      );
      final filterAssignment = _requiredLookup(
        filterAssignments,
        id,
        'filter assignment',
      );
      final contentAssignment = _requiredLookup(
        exerciseContent,
        id,
        'content assignment',
      );
      final instructionBlock = _requiredLookup(
        instructionBlocks,
        contentAssignment.instructionBlockId,
        'instruction block',
      );
      final muscleMapping = _requiredLookup(
        exerciseMuscleMappings,
        id,
        'muscle mapping',
      );
      final media = _requiredLookup(exerciseMedia, id, 'exercise media');
      final movementPattern = _requiredLookup(
        movementPatterns,
        categoryAssignment.movementPatternId,
        'movement pattern',
      );
      final muscleCategoryOptions = categoryAssignment.muscleRegionCategoryIds
          .map(
            (categoryId) => _requiredLookup(
              muscleRegionCategories,
              categoryId,
              'muscle region category',
            ),
          )
          .toList(growable: false);
      final equipment = filterAssignment.equipmentIds
          .map(
            (equipmentId) =>
                _requiredLookup(equipmentOptions, equipmentId, 'equipment'),
          )
          .toList(growable: false);

      exercises.add(
        ExerciseCatalogEntry(
          id: id,
          displayOrder: _asInt(row['display_order'], 'display_order'),
          inventoryGroup: _asString(row['inventory_group'], 'inventory_group'),
          names: CatalogLocalizedText.fromJson(row['names'], 'names'),
          movementPattern: movementPattern,
          muscleRegionCategories: List.unmodifiable(muscleCategoryOptions),
          equipment: List.unmodifiable(equipment),
          level: _requiredLookup(
            levelOptions,
            filterAssignment.levelId,
            'level',
          ),
          laterality: _requiredLookup(
            lateralityOptions,
            filterAssignment.lateralityId,
            'laterality',
          ),
          exerciseType: _requiredLookup(
            exerciseTypeOptions,
            filterAssignment.exerciseTypeId,
            'exercise type',
          ),
          content: ExerciseInstructionContent(
            setup: instructionBlock.setup,
            execution: instructionBlock.execution,
            formCues: instructionBlock.formCues,
            commonErrors: instructionBlock.commonErrors,
            substitutionIds: contentAssignment.substitutionIds,
            regressionIds: contentAssignment.regressionIds,
          ),
          muscleMapping: muscleMapping,
          media: media,
        ),
      );
    }

    return ExerciseCatalog._(
      exercises: exercises,
      movementPatterns: _sortedOptions(movementPatterns),
      muscleRegionCategories: _sortedOptions(muscleRegionCategories),
      equipment: _sortedOptions(equipmentOptions),
      levels: _sortedOptions(levelOptions),
      lateralities: _sortedOptions(lateralityOptions),
      exerciseTypes: _sortedOptions(exerciseTypeOptions),
      muscleRegionNames: Map.unmodifiable(muscleRegionNames),
      availableAnimationIds: availableAnimationIds,
    );
  }

  final List<ExerciseCatalogEntry> exercises;
  final Map<String, ExerciseCatalogEntry> exercisesById;
  final List<CatalogOption> movementPatterns;
  final List<CatalogOption> muscleRegionCategories;
  final List<CatalogOption> equipment;
  final List<CatalogOption> levels;
  final List<CatalogOption> lateralities;
  final List<CatalogOption> exerciseTypes;
  final Map<String, CatalogLocalizedText> muscleRegionNames;
  final Set<String> availableAnimationIds;

  List<CatalogOption> optionsFor(ExerciseCatalogFacet facet) {
    return switch (facet) {
      ExerciseCatalogFacet.movementPattern => movementPatterns,
      ExerciseCatalogFacet.muscleRegion => muscleRegionCategories,
      ExerciseCatalogFacet.equipment => equipment,
      ExerciseCatalogFacet.level => levels,
      ExerciseCatalogFacet.laterality => lateralities,
      ExerciseCatalogFacet.exerciseType => exerciseTypes,
    };
  }

  ExerciseCatalogEntry? exerciseById(String id) => exercisesById[id];

  String muscleRegionName(String id, String localeCode) {
    return muscleRegionNames[id]?.resolve(localeCode) ??
        humanizeCatalogIdentifier(id);
  }

  List<ExerciseCatalogEntry> query({
    required String localeCode,
    String searchTerm = '',
    ExerciseCatalogFilters filters = const ExerciseCatalogFilters(),
  }) {
    final normalizedQuery = _normalizeSearch(searchTerm);
    return exercises
        .where((exercise) {
          return _matchesFilters(exercise, filters) &&
              _matchesSearch(exercise, normalizedQuery, localeCode);
        })
        .toList(growable: false);
  }

  List<ExerciseCatalogEntry> resolveExercises(List<String> ids) {
    return ids
        .map((id) => exercisesById[id])
        .whereType<ExerciseCatalogEntry>()
        .toList(growable: false);
  }

  bool _matchesFilters(
    ExerciseCatalogEntry exercise,
    ExerciseCatalogFilters filters,
  ) {
    return _selectedContains(filters.movementPatternIds, <String>[
          exercise.movementPattern.id,
        ]) &&
        _selectedContains(
          filters.muscleRegionCategoryIds,
          exercise.muscleRegionCategoryIds,
        ) &&
        _selectedContains(filters.equipmentIds, exercise.equipmentIds) &&
        _selectedContains(filters.levelIds, <String>[exercise.level.id]) &&
        _selectedContains(filters.lateralityIds, <String>[
          exercise.laterality.id,
        ]) &&
        _selectedContains(filters.exerciseTypeIds, <String>[
          exercise.exerciseType.id,
        ]);
  }

  bool _matchesSearch(
    ExerciseCatalogEntry exercise,
    String normalizedQuery,
    String localeCode,
  ) {
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchable = <String>[
      exercise.id,
      exercise.inventoryGroup,
      ...exercise.names.searchableValues,
      exercise.movementPattern.name(localeCode),
      ...exercise.movementPattern.names.searchableValues,
      ...exercise.muscleRegionCategories.expand(
        (option) => option.names.searchableValues,
      ),
      ...exercise.equipment.expand((option) => option.names.searchableValues),
      ...exercise.level.names.searchableValues,
      ...exercise.laterality.names.searchableValues,
      ...exercise.exerciseType.names.searchableValues,
      exercise.content.setup.resolve(localeCode),
      exercise.content.execution.resolve(localeCode),
      ...exercise.content.formCues.resolve(localeCode),
      ...exercise.content.commonErrors.resolve(localeCode),
      ...exercise.muscleMapping.primaryRegionIds.map(
        (id) => muscleRegionName(id, localeCode),
      ),
      ...exercise.muscleMapping.secondaryRegionIds.map(
        (id) => muscleRegionName(id, localeCode),
      ),
      ...exercise.muscleMapping.stabilizerRegionIds.map(
        (id) => muscleRegionName(id, localeCode),
      ),
    ];

    return searchable.any(
      (value) => _normalizeSearch(value).contains(normalizedQuery),
    );
  }
}

String humanizeCatalogIdentifier(String id) {
  return id
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _CategoryAssignment {
  const _CategoryAssignment({
    required this.movementPatternId,
    required this.muscleRegionCategoryIds,
  });

  final String movementPatternId;
  final List<String> muscleRegionCategoryIds;
}

class _FilterAssignment {
  const _FilterAssignment({
    required this.equipmentIds,
    required this.levelId,
    required this.lateralityId,
    required this.exerciseTypeId,
  });

  final List<String> equipmentIds;
  final String levelId;
  final String lateralityId;
  final String exerciseTypeId;
}

class _ContentAssignment {
  const _ContentAssignment({
    required this.instructionBlockId,
    required this.substitutionIds,
    required this.regressionIds,
  });

  final String instructionBlockId;
  final List<String> substitutionIds;
  final List<String> regressionIds;
}

class _InstructionBlock {
  const _InstructionBlock({
    required this.setup,
    required this.execution,
    required this.formCues,
    required this.commonErrors,
  });

  final CatalogLocalizedText setup;
  final CatalogLocalizedText execution;
  final CatalogLocalizedList formCues;
  final CatalogLocalizedList commonErrors;
}

Map<String, CatalogOption> _optionsById(List<Map<String, Object?>> rows) {
  return {
    for (final row in rows)
      _asString(row['id'], 'option.id'): CatalogOption.fromJson(row),
  };
}

List<CatalogOption> _sortedOptions(Map<String, CatalogOption> options) {
  return options.values.toList(growable: false)
    ..sort((left, right) => left.displayOrder.compareTo(right.displayOrder));
}

Map<String, _CategoryAssignment> _exerciseCategoryAssignments(
  Map<String, Object?> categories,
) {
  return {
    for (final row in _asObjectList(categories, 'exercise_categories'))
      _asString(row['exercise_id'], 'exercise_id'): _CategoryAssignment(
        movementPatternId: _asString(
          row['movement_pattern_id'],
          'movement_pattern_id',
        ),
        muscleRegionCategoryIds: List.unmodifiable(
          _asStringList(
            row['muscle_region_category_ids'],
            'muscle_region_category_ids',
          ),
        ),
      ),
  };
}

Map<String, _FilterAssignment> _exerciseFilterAssignments(
  Map<String, Object?> filters,
) {
  return {
    for (final row in _asObjectList(filters, 'exercise_filters'))
      _asString(row['exercise_id'], 'exercise_id'): _FilterAssignment(
        equipmentIds: List.unmodifiable(
          _asStringList(row['equipment_ids'], 'equipment_ids'),
        ),
        levelId: _asString(row['level_id'], 'level_id'),
        lateralityId: _asString(row['laterality_id'], 'laterality_id'),
        exerciseTypeId: _asString(row['exercise_type_id'], 'exercise_type_id'),
      ),
  };
}

Map<String, _InstructionBlock> _instructionBlocks(
  Map<String, Object?> content,
) {
  return {
    for (final row in _asObjectList(content, 'instruction_blocks'))
      _asString(row['id'], 'instruction_block.id'): _InstructionBlock(
        setup: CatalogLocalizedText.fromJson(row['setup'], 'setup'),
        execution: CatalogLocalizedText.fromJson(row['execution'], 'execution'),
        formCues: CatalogLocalizedList.fromJson(row['form_cues'], 'form_cues'),
        commonErrors: CatalogLocalizedList.fromJson(
          row['common_errors'],
          'common_errors',
        ),
      ),
  };
}

Map<String, _ContentAssignment> _exerciseContentAssignments(
  Map<String, Object?> content,
) {
  return {
    for (final row in _asObjectList(content, 'exercise_content'))
      _asString(row['exercise_id'], 'exercise_id'): _ContentAssignment(
        instructionBlockId: _asString(
          row['instruction_block_id'],
          'instruction_block_id',
        ),
        substitutionIds: List.unmodifiable(
          _asStringList(row['substitution_ids'], 'substitution_ids'),
        ),
        regressionIds: List.unmodifiable(
          _asStringList(row['regression_ids'], 'regression_ids'),
        ),
      ),
  };
}

Map<String, ExerciseMuscleMapping> _exerciseMuscleMappings(
  Map<String, Object?> muscleMappings,
) {
  return {
    for (final row in _asObjectList(muscleMappings, 'exercise_muscle_mappings'))
      _asString(row['exercise_id'], 'exercise_id'):
          ExerciseMuscleMapping.fromJson(row),
  };
}

Map<String, ExerciseMedia> _exerciseMedia(Map<String, Object?> media) {
  return {
    for (final row in _asObjectList(media, 'exercise_media'))
      _asString(row['exercise_id'], 'exercise_id'): ExerciseMedia.fromJson(row),
  };
}

Set<String> _compoundAnimationIds(
  Map<String, Object?> animations, {
  required String expectedAnimationSetId,
}) {
  final animationSetId = _asString(
    animations['animation_set_id'],
    'animation_set_id',
  );
  if (animationSetId != expectedAnimationSetId) {
    throw FormatException(
      'Media animation set "$expectedAnimationSetId" does not match '
      'compound animation contract "$animationSetId".',
    );
  }

  final expectedCount = _asInt(
    animations['exercise_animation_count'],
    'exercise_animation_count',
  );
  final ids = <String>{};
  for (final row in _asObjectList(animations, 'exercises')) {
    final animationId = _asString(row['animation_id'], 'animation_id');
    if (!ids.add(animationId)) {
      throw FormatException('Duplicate compound animation id "$animationId".');
    }
  }

  if (ids.length != expectedCount) {
    throw FormatException(
      'Expected $expectedCount compound animations, found ${ids.length}.',
    );
  }

  return Set.unmodifiable(ids);
}

void _validateMediaAnimationBindings(
  Map<String, ExerciseMedia> exerciseMedia,
  Set<String> availableAnimationIds,
) {
  final mediaAnimationIds = <String>{};

  for (final entry in exerciseMedia.entries) {
    final exerciseId = entry.key;
    final media = entry.value;
    final animationId = media.animationId;

    if (media.animationStatus == 'available' && animationId == null) {
      throw FormatException(
        'Exercise "$exerciseId" marks animation available without an '
        'animation_id.',
      );
    }

    if (animationId != null) {
      if (media.animationStatus != 'available') {
        throw FormatException(
          'Exercise "$exerciseId" references animation "$animationId" while '
          'status is "${media.animationStatus}".',
        );
      }
      if (!availableAnimationIds.contains(animationId)) {
        throw FormatException(
          'Exercise "$exerciseId" references unknown animation "$animationId".',
        );
      }
      mediaAnimationIds.add(animationId);
    }
  }

  final unreferencedAnimationIds = availableAnimationIds.difference(
    mediaAnimationIds,
  );
  if (unreferencedAnimationIds.isNotEmpty) {
    throw FormatException(
      'Compound animations not referenced by media: '
      '${unreferencedAnimationIds.join(', ')}.',
    );
  }
}

Map<String, CatalogLocalizedText> _muscleRegionNames(
  Map<String, Object?> muscleOntology,
) {
  final namesById = <String, CatalogLocalizedText>{};
  for (final group in _asObjectList(muscleOntology, 'groups')) {
    final regions = _asMap(group['regions'], 'regions');
    for (final region in regions.values) {
      final regionMap = _asMap(region, 'region');
      final id = _asString(regionMap['id'], 'region.id');
      namesById[id] = CatalogLocalizedText.fromJson(
        regionMap['names'],
        'region.names',
      );
    }
  }
  return namesById;
}

T _requiredLookup<T>(Map<String, T> source, String id, String label) {
  final value = source[id];
  if (value == null) {
    throw FormatException('Missing $label for "$id".');
  }
  return value;
}

bool _selectedContains(Set<String> selectedIds, List<String> actualIds) {
  return selectedIds.isEmpty || actualIds.any(selectedIds.contains);
}

Map<String, Object?> _decodeDocument(String source, String label) {
  final decoded = jsonDecode(source);
  if (decoded is Map) {
    return Map<String, Object?>.from(decoded);
  }
  throw FormatException('Expected object document for $label.');
}

List<Map<String, Object?>> _asObjectList(
  Map<String, Object?> source,
  String key,
) {
  final value = source[key];
  if (value is List) {
    return value.map((item) => _asMap(item, key)).toList(growable: false);
  }
  throw FormatException('Expected list for $key.');
}

Map<String, Object?> _asMap(Object? value, String fieldName) {
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }
  throw FormatException('Expected object for $fieldName.');
}

String _asString(Object? value, String fieldName) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected non-empty string for $fieldName.');
}

String? _asOptionalString(Object? value, String fieldName) {
  if (value == null) {
    return null;
  }
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected null or non-empty string for $fieldName.');
}

int _asInt(Object? value, String fieldName) {
  if (value is int) {
    return value;
  }
  throw FormatException('Expected integer for $fieldName.');
}

List<String> _asStringList(Object? value, String fieldName) {
  if (value is List) {
    return value
        .map((item) => _asString(item, fieldName))
        .toList(growable: false);
  }
  throw FormatException('Expected string list for $fieldName.');
}

String _normalizeSearch(String value) {
  return value
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
