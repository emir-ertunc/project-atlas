import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('uses performance fallback on Android by default', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    try {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AnatomyRendererPanel()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(AnatomyRendererPanel.panelKey), findsOneWidget);
      expect(
        find.byKey(AnatomyRendererPanel.performanceFallbackKey),
        findsOneWidget,
      );
      expect(find.byKey(AnatomyRendererPanel.fallbackKey), findsOneWidget);
      expect(find.byKey(AnatomyRendererPanel.platformViewKey), findsNothing);
      expect(
        find.textContaining('Performance-safe semantic preview'),
        findsWidgets,
      );
      expect(find.textContaining('LOD: lod2'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('shows a safe fallback outside Android builds', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AnatomyRendererPanel()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(AnatomyRendererPanel.panelKey), findsOneWidget);
      expect(find.byKey(AnatomyRendererPanel.fallbackKey), findsOneWidget);
      expect(
        find.byKey(AnatomyRendererPanel.viewportGestureKey),
        findsOneWidget,
      );
      expect(
        find.byKey(AnatomyRendererPanel.heatmapPreviewButtonKey),
        findsOneWidget,
      );
      expect(
        find.textContaining('native Filament renderer', findRichText: true),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('applies preview heatmap and selects a semantic region', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AnatomyRendererPanel()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No heatmap applied'), findsOneWidget);

      await tester.tap(
        find.byKey(AnatomyRendererPanel.heatmapPreviewButtonKey),
      );
      await tester.pump();

      expect(find.text('Active heatmap regions'), findsOneWidget);
      expect(find.textContaining('pectoralis_major_right'), findsOneWidget);

      await tester.tapAt(
        tester.getCenter(find.byKey(AnatomyRendererPanel.viewportGestureKey)),
      );
      await tester.pumpAndSettle();

      final selectedRegionText = tester.widget<Text>(
        find.byKey(AnatomyRendererPanel.selectedRegionTextKey),
      );
      expect(selectedRegionText.data, contains('rhomboids_right'));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('dragging the viewport changes the camera summary', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AnatomyRendererPanel()),
        ),
      );
      await tester.pumpAndSettle();

      final initialText = tester
          .widget<Text>(find.byKey(AnatomyRendererPanel.cameraStateTextKey))
          .data;

      await tester.drag(
        find.byKey(AnatomyRendererPanel.viewportGestureKey),
        const Offset(40, -20),
      );
      await tester.pump();

      final updatedText = tester
          .widget<Text>(find.byKey(AnatomyRendererPanel.cameraStateTextKey))
          .data;

      expect(updatedText, isNot(initialText));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
