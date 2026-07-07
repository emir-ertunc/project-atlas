import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLocaleProvider.overrideWithValue(locale)],
        child: const ProjectAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the initial route in English', (tester) async {
    await pumpApp(tester, const Locale('en'));

    expect(find.text('Project Atlas'), findsOneWidget);
    expect(find.text('Foundation setup complete'), findsOneWidget);
  });

  testWidgets('renders the initial route in Turkish', (tester) async {
    await pumpApp(tester, const Locale('tr'));

    expect(find.text('Project Atlas'), findsOneWidget);
    expect(find.text('Temel kurulum tamamlandı'), findsOneWidget);
  });
}
