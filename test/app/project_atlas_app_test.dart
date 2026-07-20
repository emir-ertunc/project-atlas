import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/design_system/tokens/app_color_tokens.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';

import '../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleProvider.overrideWithValue(locale),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
        ],
        child: const ProjectAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders English primary navigation on the Today route', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Program'), findsOneWidget);
    expect(find.text('Anatomy'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 0);
  });

  testWidgets('renders Turkish primary navigation labels', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester, const Locale('tr'));

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Program'), findsOneWidget);
    expect(find.text('Anatomi'), findsOneWidget);
    expect(find.text('İlerleme'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches branches and keeps visited branches mounted', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    final destinations = <(String, Key, String, int)>[
      ('Program', ProgramScreen.screenKey, ProgramScreen.path, 1),
      ('Anatomy', AnatomyScreen.screenKey, AnatomyScreen.path, 2),
      ('Progress', ProgressScreen.screenKey, ProgressScreen.path, 3),
      ('Settings', SettingsScreen.screenKey, SettingsScreen.path, 4),
    ];

    for (final (label, screenKey, path, index) in destinations) {
      await tester.tap(_navigationLabel(label));
      await tester.pumpAndSettle();

      expect(find.byKey(screenKey), findsOneWidget);
      expect(_navigationBar(tester).selectedIndex, index);
      expect(
        _router(tester, screenKey).routeInformationProvider.value.uri.path,
        path,
      );
    }

    expect(
      find.byKey(ProgramScreen.screenKey, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(AnatomyScreen.screenKey, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('supports deep links and redirects the legacy root', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    final router = _router(tester, TodayScreen.screenKey);
    router.go(AnatomyScreen.path);
    await tester.pumpAndSettle();

    expect(find.byKey(AnatomyScreen.screenKey), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 2);

    router.go('/');
    await tester.pumpAndSettle();

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 0);
  });

  testWidgets('installs semantic light and dark application themes', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.colorScheme, AppColorTokens.lightScheme);
    expect(app.darkTheme?.colorScheme, AppColorTokens.darkScheme);
  });
}

NavigationBar _navigationBar(WidgetTester tester) {
  return tester.widget<NavigationBar>(
    find.byKey(MainNavigationShell.navigationBarKey),
  );
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

GoRouter _router(WidgetTester tester, Key screenKey) {
  return GoRouter.of(tester.element(find.byKey(screenKey)));
}
