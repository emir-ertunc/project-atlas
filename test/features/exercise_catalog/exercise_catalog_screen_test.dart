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
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_detail_screen.dart';
import 'package:project_atlas/features/program/presentation/program_builder_screen.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';

import '../../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleProvider.overrideWithValue(const Locale('en')),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
        ],
        child: const ProjectAtlasApp(),
      ),
    );
    await tester.pump();
  }

  Future<void> openCatalogTab(WidgetTester tester) async {
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

  testWidgets('renders catalog search, filters, and selectable results', (
    tester,
  ) async {
    await pumpApp(tester);
    await openCatalogTab(tester);

    expect(find.byKey(ProgramScreen.screenKey), findsOneWidget);
    expect(find.byKey(ExerciseCatalogScreen.searchFieldKey), findsOneWidget);
    expect(
      find.byKey(ExerciseCatalogScreen.filterSheetButtonKey),
      findsOneWidget,
    );
    expect(
      find.byKey(ExerciseCatalogScreen.compactFilterBarKey),
      findsOneWidget,
    );
    expect(find.text('120/120 exercises'), findsOneWidget);

    await tester.tap(find.byKey(ExerciseCatalogScreen.filterSheetButtonKey));
    await tester.pumpAndSettle();

    final squatFilter = find.byKey(
      ExerciseCatalogScreen.filterChipKey(
        ExerciseCatalogFacet.movementPattern,
        'squat',
      ),
    );
    expect(tester.widget<FilterChip>(squatFilter).selected, isFalse);

    await tester.ensureVisible(squatFilter);
    await tester.tap(squatFilter);
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.widget<FilterChip>(squatFilter).selected, isTrue);
    expect(find.text('120/120 exercises'), findsNothing);
  });

  testWidgets('adds a catalog exercise to a local program draft', (
    tester,
  ) async {
    await pumpApp(tester);
    await openCatalogTab(tester);

    await tester.enterText(
      find.byKey(ExerciseCatalogScreen.searchFieldKey),
      'barbell bench press',
    );
    await tester.pump(const Duration(milliseconds: 250));

    final addButton = find.byKey(
      ExerciseCatalogScreen.addToProgramButtonKey('barbell_bench_press'),
    );
    await _dragUntilFound(tester, addButton);
    await tester.tap(addButton);
    await tester.pump();

    expect(find.textContaining('Draft created'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.byKey(ProgramScreen.builderTabKey));
    await tester.tap(find.byKey(ProgramScreen.builderTabKey));
    await tester.pump();
    await _pumpUntilFound(
      tester,
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_bench_press')),
    );
  });

  testWidgets('searches the local catalog and opens exercise detail', (
    tester,
  ) async {
    await pumpApp(tester);
    await openCatalogTab(tester);

    await tester.enterText(
      find.byKey(ExerciseCatalogScreen.searchFieldKey),
      'barbell bench press',
    );
    await tester.pump(const Duration(milliseconds: 250));

    final benchCard = find.byKey(
      ExerciseCatalogScreen.exerciseCardKey('barbell_bench_press'),
    );
    await _dragUntilFound(tester, benchCard);
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
    await tester.tap(benchCard);
    await tester.pump();
    await _pumpUntilFound(tester, find.byKey(ExerciseDetailScreen.screenKey));

    expect(find.byKey(ExerciseDetailScreen.screenKey), findsOneWidget);
    expect(find.text('Barbell bench press'), findsWidgets);
    expect(find.byKey(ExerciseDetailScreen.mediaHeroKey), findsOneWidget);
    expect(
      find.byKey(
        ExerciseDetailScreen.addToProgramButtonKey('barbell_bench_press'),
      ),
      findsOneWidget,
    );
    final detailList = find.descendant(
      of: find.byKey(ExerciseDetailScreen.screenKey),
      matching: find.byType(ListView),
    );
    final detailScrollable = find.descendant(
      of: detailList,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(
        ExerciseDetailScreen.primaryMuscleChipKey('pectoralis_major_right'),
      ),
      160,
      scrollable: detailScrollable,
    );
    expect(
      find.byKey(
        ExerciseDetailScreen.primaryMuscleChipKey('pectoralis_major_right'),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Setup'),
      160,
      scrollable: detailScrollable,
    );
    expect(find.text('Setup'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Execution'),
      160,
      scrollable: detailScrollable,
    );
    expect(find.text('Execution'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(
        ExerciseDetailScreen.substitutionChipKey('dumbbell_bench_press'),
      ),
      240,
      scrollable: detailScrollable,
    );

    expect(
      find.byKey(
        ExerciseDetailScreen.substitutionChipKey('dumbbell_bench_press'),
      ),
      findsOneWidget,
    );
  });
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected widget was not found: $finder');
}

Future<void> _dragUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 12; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.dragFrom(const Offset(195, 720), const Offset(0, -420));
  }
  fail('Expected widget was not found after scrolling: $finder');
}
