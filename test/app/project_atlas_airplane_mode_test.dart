import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_catalog_screen.dart';
import 'package:project_atlas/features/program/presentation/program_builder_screen.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';

void main() {
  testWidgets('loads the bundled catalog while network clients are blocked', (
    tester,
  ) async {
    await _withNetworkBlocked(() async {
      _expectCatalogAssetsBundled();
      final catalog = _loadLocalCatalogFiles();
      expect(catalog.exercises, hasLength(120));

      await _pumpOfflineApp(tester, catalog: catalog);
      await _openCatalog(tester);

      expect(find.byKey(ExerciseCatalogScreen.searchFieldKey), findsOneWidget);
      expect(find.text('120/120 exercises'), findsOneWidget);

      await tester.enterText(
        find.byKey(ExerciseCatalogScreen.searchFieldKey),
        'barbell bench press',
      );
      await tester.pump(const Duration(milliseconds: 250));

      final benchCard = find.byKey(
        ExerciseCatalogScreen.exerciseCardKey('barbell_bench_press'),
      );
      await _dragUntilFound(tester, benchCard);

      expect(benchCard, findsOneWidget);
      expect(
        find.byKey(ExerciseCatalogScreen.thumbnailKey('barbell_bench_press')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ExerciseCatalogScreen.animationBadgeKey('barbell_bench_press'),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets(
    'creates a program draft with a catalog exercise while network clients are '
    'blocked',
    (tester) async {
      await _withNetworkBlocked(() async {
        _expectCatalogAssetsBundled();
        final catalog = _loadLocalCatalogFiles();
        await _pumpOfflineApp(tester, catalog: catalog);
        await _openProgramBuilder(tester);

        await tester.tap(
          find.byKey(ProgramBuilderScreen.createProgramButtonKey),
        );
        await tester.pump();
        await _pumpUntilFound(
          tester,
          find.byKey(ProgramBuilderScreen.programNameFieldKey),
        );

        await tester.enterText(
          find.byKey(ProgramBuilderScreen.programNameFieldKey),
          'Airplane mode strength block',
        );
        await _addCatalogExercise(
          tester,
          query: 'barbell bench press',
          exerciseId: 'barbell_bench_press',
        );

        expect(
          find.byKey(
            ProgramBuilderScreen.exerciseRowKey('barbell_bench_press'),
          ),
          findsOneWidget,
        );
        expect(_summaryText(tester), contains('1 exercises'));
      });
    },
  );
}

final _catalogAssetPaths = [
  ExerciseCatalogAssetLoader.inventoryAsset,
  ExerciseCatalogAssetLoader.categoriesAsset,
  ExerciseCatalogAssetLoader.filtersAsset,
  ExerciseCatalogAssetLoader.contentAsset,
  ExerciseCatalogAssetLoader.muscleMappingsAsset,
  ExerciseCatalogAssetLoader.mediaAsset,
  ExerciseCatalogAssetLoader.muscleOntologyAsset,
  ExerciseCatalogAssetLoader.compoundAnimationsAsset,
];

Future<T> _withNetworkBlocked<T>(Future<T> Function() body) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (SecurityContext? _) {
      throw StateError(
        'Unexpected network client creation during airplane-mode verification.',
      );
    },
  );
}

void _expectCatalogAssetsBundled() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  for (final assetPath in _catalogAssetPaths) {
    expect(pubspec, contains('- $assetPath'));
    expect(File(assetPath).existsSync(), isTrue, reason: assetPath);
  }
}

ExerciseCatalog _loadLocalCatalogFiles() {
  return ExerciseCatalog.fromJsonDocuments(
    inventoryJson: File(
      ExerciseCatalogAssetLoader.inventoryAsset,
    ).readAsStringSync(),
    categoriesJson: File(
      ExerciseCatalogAssetLoader.categoriesAsset,
    ).readAsStringSync(),
    filtersJson: File(
      ExerciseCatalogAssetLoader.filtersAsset,
    ).readAsStringSync(),
    contentJson: File(
      ExerciseCatalogAssetLoader.contentAsset,
    ).readAsStringSync(),
    muscleMappingsJson: File(
      ExerciseCatalogAssetLoader.muscleMappingsAsset,
    ).readAsStringSync(),
    mediaJson: File(ExerciseCatalogAssetLoader.mediaAsset).readAsStringSync(),
    compoundAnimationsJson: File(
      ExerciseCatalogAssetLoader.compoundAnimationsAsset,
    ).readAsStringSync(),
    muscleOntologyJson: File(
      ExerciseCatalogAssetLoader.muscleOntologyAsset,
    ).readAsStringSync(),
  );
}

Future<AppDatabase> _pumpOfflineApp(
  WidgetTester tester, {
  required ExerciseCatalog catalog,
}) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);

  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        appLocaleProvider.overrideWithValue(const Locale('en')),
        exerciseCatalogProvider.overrideWith((ref) => catalog),
      ],
      child: const ProjectAtlasApp(),
    ),
  );
  await tester.pump();

  return database;
}

Future<void> _openCatalog(WidgetTester tester) async {
  await tester.tap(_navigationLabel('Program'));
  await tester.pump();
  await _pumpUntilFound(tester, find.byKey(ProgramScreen.catalogTabKey));
  await tester.tap(find.byKey(ProgramScreen.catalogTabKey));
  await tester.pump(const Duration(milliseconds: 350));
  await _pumpUntilFound(
    tester,
    find.byKey(ExerciseCatalogScreen.searchFieldKey),
  );
}

Future<void> _openProgramBuilder(WidgetTester tester) async {
  await tester.tap(_navigationLabel('Program'));
  await tester.pump();
  await _pumpUntilFound(tester, find.byKey(ProgramScreen.builderTabKey));
  await tester.tap(find.byKey(ProgramScreen.builderTabKey));
  await tester.pump();
  await _pumpUntilFound(
    tester,
    find.byKey(ProgramBuilderScreen.createProgramButtonKey),
  );
}

Future<void> _addCatalogExercise(
  WidgetTester tester, {
  required String query,
  required String exerciseId,
}) async {
  final addButton = find.byKey(ProgramBuilderScreen.addExerciseButtonKey);
  await _pumpUntilButtonEnabled<FilledButton>(tester, addButton);
  await _tapVisible(tester, addButton);
  await tester.pump();
  await _pumpUntilFound(
    tester,
    find.byKey(ProgramBuilderScreen.exercisePickerSearchFieldKey),
  );

  await tester.enterText(
    find.byKey(ProgramBuilderScreen.exercisePickerSearchFieldKey),
    query,
  );
  await tester.pump(const Duration(milliseconds: 250));

  final option = find.byKey(
    ProgramBuilderScreen.exercisePickerOptionKey(exerciseId),
  );
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pump();
  await _pumpUntilNotFound(
    tester,
    find.byKey(ProgramBuilderScreen.exercisePickerSearchFieldKey),
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _ensureHittable(tester, finder);
  await tester.tap(finder);
}

Future<void> _ensureHittable(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(
    tester.element(finder),
    duration: Duration.zero,
    alignment: 0.35,
  );
  await tester.pump();
}

String _summaryText(WidgetTester tester) {
  final text = tester.widget<Text>(find.byKey(ProgramBuilderScreen.summaryKey));
  return text.data ?? '';
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 60; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected widget was not found: $finder');
}

Future<void> _pumpUntilNotFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 60; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isEmpty) {
      return;
    }
  }
  fail('Expected widget to disappear: $finder');
}

Future<void> _pumpUntilButtonEnabled<T extends ButtonStyleButton>(
  WidgetTester tester,
  Finder finder,
) async {
  for (var attempt = 0; attempt < 60; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      final button = tester.widget<T>(finder);
      if (button.onPressed != null) {
        return;
      }
    }
  }
  fail('Expected button to become enabled: $finder');
}

Future<void> _dragUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 12; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.dragFrom(const Offset(215, 760), const Offset(0, -420));
  }
  fail('Expected widget was not found after scrolling: $finder');
}
