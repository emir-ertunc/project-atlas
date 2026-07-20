import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';

import '../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLocaleProvider.overrideWithValue(const Locale('en')),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
        ],
        child: const ProjectAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('primary shell keeps labels, semantics, and tap targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    try {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);

      final navigationBarRect = tester.getRect(
        find.byKey(MainNavigationShell.navigationBarKey),
      );
      expect(
        navigationBarRect.height,
        greaterThanOrEqualTo(AppComponentTokens.navigationBarHeight),
      );
      expect(
        navigationBarRect.width / 5,
        greaterThanOrEqualTo(AppComponentTokens.minimumTouchTarget),
      );

      for (final label in const [
        'Today',
        'Program',
        'Anatomy',
        'Progress',
        'Settings',
      ]) {
        expect(_navigationLabel(label), findsOneWidget);
      }

      final headerNode = tester.getSemantics(
        find.byKey(FeatureRootScaffold.placeholderTitleKey),
      );
      expect(headerNode.label, 'Today');
      expect(headerNode.flagsCollection.isHeader, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('complete phase-one screens tolerate large text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);
    expect(tester.takeException(), isNull);

    for (final label in const ['Program', 'Anatomy', 'Progress', 'Settings']) {
      await tester.tap(_navigationLabel(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.tap(_navigationLabel('Today'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('anatomy controls preserve accessible touch targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    GoRouter.of(
      tester.element(find.byKey(TodayScreen.screenKey)),
    ).go(AnatomyScreen.path);
    await tester.pumpAndSettle();

    for (final key in const [
      AnatomyRendererPanel.resetCameraButtonKey,
      AnatomyRendererPanel.heatmapPreviewButtonKey,
    ]) {
      final size = tester.getSize(find.byKey(key));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }
  });
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}
