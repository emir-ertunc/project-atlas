import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/app/router/app_router.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ProjectAtlasApp extends ConsumerWidget {
  const ProjectAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'project-atlas-app',
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
