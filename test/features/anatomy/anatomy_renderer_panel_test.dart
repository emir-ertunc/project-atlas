import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_interaction_controller.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('uses performance fallback on Android by default', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    try {
      await tester.pumpWidget(
        _panelTestHost(child: const AnatomyRendererPanel()),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(AnatomyRendererPanel.panelKey), findsOneWidget);
      expect(
        find.byKey(AnatomyRendererPanel.performanceFallbackKey),
        findsOneWidget,
      );
      expect(find.byKey(AnatomyRendererPanel.fallbackKey), findsOneWidget);
      expect(find.byKey(AnatomyRendererPanel.platformViewKey), findsNothing);
      expect(find.textContaining('Safe preview'), findsWidgets);
      expect(find.textContaining('LOD: lod2'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('shows a safe fallback outside Android builds', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        _panelTestHost(child: const AnatomyRendererPanel()),
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
        find.textContaining('native viewer', findRichText: true),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('labels personalized anatomy as a visual estimate', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        _panelTestHost(child: const AnatomyRendererPanel()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(AnatomyRendererPanel.visualEstimateDisclosureKey),
        findsOneWidget,
      );
      expect(find.text('Visual estimate, not a medical scan'), findsOneWidget);
      expect(find.textContaining('cannot diagnose health'), findsOneWidget);
      expect(find.textContaining('body composition'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'keeps the fallback viewport visual-first with disclosure below',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;

      try {
        await tester.pumpWidget(
          _panelTestHost(child: const AnatomyRendererPanel()),
        );
        await tester.pumpAndSettle();

        final disclosure = find.byKey(
          AnatomyRendererPanel.visualEstimateDisclosureKey,
        );
        final stage = find.byKey(AnatomyRendererPanel.visualFirstStageKey);
        final viewport = find.byKey(AnatomyRendererPanel.viewportGestureKey);
        final fallback = find.byKey(AnatomyRendererPanel.fallbackKey);

        expect(disclosure, findsOneWidget);
        expect(stage, findsOneWidget);
        expect(viewport, findsOneWidget);
        expect(fallback, findsOneWidget);
        expect(
          tester.getTopLeft(stage).dy,
          lessThan(tester.getTopLeft(disclosure).dy),
        );
        expect(tester.getSize(stage).height, greaterThanOrEqualTo(360));
        expect(tester.getSize(stage).width, greaterThan(350));
        expect(
          find.text('Visual estimate, not a medical scan'),
          findsOneWidget,
        );
        expect(
          find.textContaining('native viewer', findRichText: true),
          findsOneWidget,
        );
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('applies preview heatmap and selects a semantic region', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        _panelTestHost(child: const AnatomyRendererPanel()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No heatmap applied'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(AnatomyRendererPanel.heatmapPreviewButtonKey),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(AnatomyRendererPanel.heatmapPreviewButtonKey),
      );
      await tester.pump();

      expect(find.text('Active heatmap regions'), findsOneWidget);
      expect(find.textContaining('pectoralis_major_right'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(AnatomyRendererPanel.viewportGestureKey),
      );
      await tester.pumpAndSettle();
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

  testWidgets(
    'applies trained, volume, and fatigue heatmaps from workout data',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final controller = AnatomyInteractionController();
      final now = DateTime.utc(2026, 7, 21, 12);
      final heatmaps = AnatomyTrainingHeatmapSet(
        ruleSetVersion: anatomyTrainingHeatmapRuleSetVersion,
        generatedAt: now,
        windowStart: now.subtract(defaultAnatomyTrainingHeatmapWindow),
        windowEnd: now,
        evidenceSetCount: 2,
        heatmaps: {
          AnatomyTrainingHeatmapKind.trainedMuscle: AnatomyTrainingHeatmap(
            kind: AnatomyTrainingHeatmapKind.trainedMuscle,
            entries: const [
              AnatomyTrainingHeatmapEntry(
                regionId: 'pectoralis_major_right',
                score: 0.9,
                rawValue: 3,
              ),
            ],
          ),
          AnatomyTrainingHeatmapKind.weeklyVolume: AnatomyTrainingHeatmap(
            kind: AnatomyTrainingHeatmapKind.weeklyVolume,
            entries: const [
              AnatomyTrainingHeatmapEntry(
                regionId: 'quadriceps_right',
                score: 1,
                rawValue: 2400,
              ),
            ],
          ),
          AnatomyTrainingHeatmapKind.fatigue: AnatomyTrainingHeatmap(
            kind: AnatomyTrainingHeatmapKind.fatigue,
            entries: const [
              AnatomyTrainingHeatmapEntry(
                regionId: 'hamstrings_right',
                score: 0.7,
                rawValue: 1.4,
              ),
            ],
          ),
        },
      );

      try {
        await tester.pumpWidget(
          _panelTestHost(
            child: AnatomyRendererPanel(
              controller: controller,
              trainingHeatmaps: AsyncData(heatmaps),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(AnatomyRendererPanel.trainingHeatmapCardKey),
          findsOneWidget,
        );
        expect(find.text('Muscle heatmaps'), findsOneWidget);
        expect(
          find.textContaining('strongest pectoralis_major_right'),
          findsOneWidget,
        );
        expect(
          find.byKey(AnatomyRendererPanel.overlayControlsKey),
          findsOneWidget,
        );
        expect(find.text('Visual estimate'), findsOneWidget);
        expect(
          find.byKey(AnatomyRendererPanel.overlayWeeklyVolumeHeatmapButtonKey),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(AnatomyRendererPanel.overlayWeeklyVolumeHeatmapButtonKey),
        );
        await tester.pump();

        expect(controller.heatmap, {'quadriceps_right': 1.0});
        expect(
          find.textContaining('strongest quadriceps_right'),
          findsOneWidget,
        );

        await tester.ensureVisible(
          find.byKey(AnatomyRendererPanel.trainedMuscleHeatmapButtonKey),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(AnatomyRendererPanel.trainedMuscleHeatmapButtonKey),
        );
        await tester.pump();

        expect(controller.heatmap, {'pectoralis_major_right': 0.9});
        expect(
          find.textContaining('strongest pectoralis_major_right'),
          findsOneWidget,
        );

        await tester.ensureVisible(
          find.byKey(AnatomyRendererPanel.fatigueHeatmapButtonKey),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(AnatomyRendererPanel.fatigueHeatmapButtonKey),
        );
        await tester.pump();

        expect(controller.heatmap, {'hamstrings_right': 0.7});
        expect(
          find.textContaining('strongest hamstrings_right'),
          findsOneWidget,
        );
      } finally {
        controller.dispose();
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('dragging the viewport changes the camera summary', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await tester.pumpWidget(
        _panelTestHost(child: const AnatomyRendererPanel()),
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

Widget _panelTestHost({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
