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
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Showing 120 of 120 exercises'), findsOneWidget);

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
    expect(find.text('Showing 120 of 120 exercises'), findsNothing);
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
    expect(find.text('Setup'), findsOneWidget);

    final detailScrollable = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Execution'),
      160,
      scrollable: detailScrollable,
    );
    expect(find.text('Execution'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Primary muscles'),
      240,
      scrollable: detailScrollable,
    );

    expect(find.text('Primary muscles'), findsOneWidget);
    expect(find.text('Right pectoralis major'), findsOneWidget);
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
