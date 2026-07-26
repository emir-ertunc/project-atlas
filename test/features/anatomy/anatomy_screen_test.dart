import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_training_heatmap_controller.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'shows Anatomy as a visual-first screen with missing measurements',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      try {
        await _pumpAnatomyScreen(tester, measurementRecords: const []);
        await tester.pumpAndSettle();

        expect(
          find.byKey(AnatomyRendererPanel.visualFirstStageKey),
          findsOneWidget,
        );
        expect(
          find.byKey(AnatomyRendererPanel.overlayControlsKey),
          findsOneWidget,
        );
        expect(find.text('Visual estimate'), findsOneWidget);
        expect(find.byKey(AnatomyScreen.measurementPromptKey), findsOneWidget);
        expect(find.text('Add measurements'), findsOneWidget);
        expect(
          find.byKey(AnatomyRendererPanel.visualEstimateDisclosureKey),
          findsOneWidget,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('hides the Anatomy measurement prompt when usable data exists', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await _pumpAnatomyScreen(
        tester,
        measurementRecords: [
          _measurementRecord(heightCentimeters: 182, weightKilograms: 84),
        ],
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(AnatomyRendererPanel.visualFirstStageKey),
        findsOneWidget,
      );
      expect(find.byKey(AnatomyScreen.measurementPromptKey), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<void> _pumpAnatomyScreen(
  WidgetTester tester, {
  required List<MeasurementRecord> measurementRecords,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        anatomyMeasurementRecordsProvider.overrideWith(
          (ref) => Stream.value(measurementRecords),
        ),
        anatomyTrainingHeatmapsProvider.overrideWith((ref) async {
          final now = DateTime.utc(2026, 7, 26, 12);
          return AnatomyTrainingHeatmapSet(
            ruleSetVersion: anatomyTrainingHeatmapRuleSetVersion,
            generatedAt: now,
            windowStart: now.subtract(defaultAnatomyTrainingHeatmapWindow),
            windowEnd: now,
            evidenceSetCount: 0,
            heatmaps: {
              for (final kind in AnatomyTrainingHeatmapKind.values)
                kind: AnatomyTrainingHeatmap(kind: kind, entries: const []),
            },
          );
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AnatomyScreen(),
      ),
    ),
  );
}

MeasurementRecord _measurementRecord({
  double? heightCentimeters,
  double? weightKilograms,
}) {
  final now = DateTime.utc(2026, 7, 26, 12);
  return MeasurementRecord(
    id: 'measurement-1',
    profileId: 'local-profile',
    measuredAt: now,
    origin: MeasurementOrigin.manual,
    createdAt: now,
    heightCentimeters: heightCentimeters,
    weightKilograms: weightKilograms,
  );
}
