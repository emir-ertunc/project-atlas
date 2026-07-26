import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/components/app_status_chip.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/performance/performance_markers.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_interaction_controller.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_performance_policy.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class AnatomyRendererPanel extends StatefulWidget {
  const AnatomyRendererPanel({
    super.key,
    this.controller,
    this.rendererOptions,
    this.trainingHeatmaps,
    this.compactMeasurementPrompt,
  });

  static const panelKey = Key('anatomy-renderer-panel');
  static const platformViewKey = Key('anatomy-renderer-platform-view');
  static const fallbackKey = Key('anatomy-renderer-fallback');
  static const performanceFallbackKey = Key(
    'anatomy-renderer-performance-fallback',
  );
  static const viewportGestureKey = Key('anatomy-renderer-viewport-gesture');
  static const resetCameraButtonKey = Key('anatomy-renderer-reset-camera');
  static const heatmapPreviewButtonKey = Key(
    'anatomy-renderer-preview-heatmap',
  );
  static const selectedRegionTextKey = Key('anatomy-renderer-selected-region');
  static const cameraStateTextKey = Key('anatomy-renderer-camera-state');
  static const heatmapLegendKey = Key('anatomy-renderer-heatmap-legend');
  static const visualEstimateDisclosureKey = Key(
    'anatomy-renderer-visual-estimate-disclosure',
  );
  static const trainingHeatmapCardKey = Key(
    'anatomy-renderer-training-heatmap-card',
  );
  static const trainedMuscleHeatmapButtonKey = Key(
    'anatomy-renderer-trained-muscle-heatmap',
  );
  static const weeklyVolumeHeatmapButtonKey = Key(
    'anatomy-renderer-weekly-volume-heatmap',
  );
  static const fatigueHeatmapButtonKey = Key(
    'anatomy-renderer-fatigue-heatmap',
  );
  static const trainingHeatmapStatusKey = Key(
    'anatomy-renderer-training-heatmap-status',
  );
  static const visualFirstStageKey = Key('anatomy-renderer-visual-first-stage');
  static const overlayControlsKey = Key('anatomy-renderer-overlay-controls');
  static const overlayTrainedMuscleHeatmapButtonKey = Key(
    'anatomy-renderer-overlay-trained-muscle-heatmap',
  );
  static const overlayWeeklyVolumeHeatmapButtonKey = Key(
    'anatomy-renderer-overlay-weekly-volume-heatmap',
  );
  static const overlayFatigueHeatmapButtonKey = Key(
    'anatomy-renderer-overlay-fatigue-heatmap',
  );

  final AnatomyInteractionController? controller;
  final AnatomyRendererOptions? rendererOptions;
  final AsyncValue<AnatomyTrainingHeatmapSet>? trainingHeatmaps;
  final Widget? compactMeasurementPrompt;

  @override
  State<AnatomyRendererPanel> createState() => _AnatomyRendererPanelState();
}

class _AnatomyRendererPanelState extends State<AnatomyRendererPanel> {
  late final AnatomyInteractionController _controller =
      widget.controller ?? AnatomyInteractionController();
  late final bool _ownsController = widget.controller == null;
  late final AnatomyRendererOptions _rendererOptions =
      widget.rendererOptions ?? AnatomyPerformancePolicy.defaultOptions();
  AnatomyTrainingHeatmapKind _selectedTrainingHeatmapKind =
      AnatomyTrainingHeatmapKind.trainedMuscle;
  double _lastScale = 1;

  @override
  void initState() {
    super.initState();
    PerformanceMarkers.mark('anatomy_panel_init');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceMarkers.mark('anatomy_panel_first_frame');
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Padding(
          key: AnatomyRendererPanel.panelKey,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportHeight = _viewportHeightFor(constraints.maxHeight);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VisualFirstStage(
                        height: viewportHeight,
                        controller: _controller,
                        rendererOptions: _rendererOptions,
                        trainingHeatmaps: widget.trainingHeatmaps,
                        selectedKind: _selectedTrainingHeatmapKind,
                        onApply: _applyTrainingHeatmap,
                        onScaleStart: () {
                          _lastScale = 1;
                        },
                        onScaleUpdate: (details) {
                          if (details.scale != 1) {
                            final scaleDelta = details.scale / _lastScale;
                            _lastScale = details.scale;
                            _controller.zoomByScale(scaleDelta);
                          }

                          if (details.pointerCount <= 1) {
                            _controller.rotateByDragDelta(
                              details.focalPointDelta,
                            );
                          }
                        },
                        onScaleEnd: () {
                          _lastScale = 1;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _RendererInteractionSummary(controller: _controller),
                      if (widget.compactMeasurementPrompt != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        widget.compactMeasurementPrompt!,
                      ],
                      const SizedBox(height: AppSpacing.md),
                      const _VisualEstimateDisclosureCard(),
                      if (widget.trainingHeatmaps != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _TrainingHeatmapCard(
                          heatmaps: widget.trainingHeatmaps!,
                          selectedKind: _selectedTrainingHeatmapKind,
                          onApply: _applyTrainingHeatmap,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _RendererCapabilitySummary(
                        rendererOptions: _rendererOptions,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _applyTrainingHeatmap(
    AnatomyTrainingHeatmapKind kind,
    AnatomyTrainingHeatmapSet heatmaps,
  ) {
    setState(() {
      _selectedTrainingHeatmapKind = kind;
    });
    _controller.setHeatmap(heatmaps.heatmapFor(kind).scores);
  }
}

double _viewportHeightFor(double availableHeight) {
  if (!availableHeight.isFinite) {
    return 420;
  }
  return (availableHeight * 0.58).clamp(360.0, 560.0);
}

class _VisualFirstStage extends StatelessWidget {
  const _VisualFirstStage({
    required this.height,
    required this.controller,
    required this.rendererOptions,
    required this.trainingHeatmaps,
    required this.selectedKind,
    required this.onApply,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
  });

  final double height;
  final AnatomyInteractionController controller;
  final AnatomyRendererOptions rendererOptions;
  final AsyncValue<AnatomyTrainingHeatmapSet>? trainingHeatmaps;
  final AnatomyTrainingHeatmapKind selectedKind;
  final void Function(
    AnatomyTrainingHeatmapKind kind,
    AnatomyTrainingHeatmapSet heatmaps,
  )
  onApply;
  final VoidCallback onScaleStart;
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;
  final VoidCallback onScaleEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      key: AnatomyRendererPanel.visualFirstStageKey,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      key: AnatomyRendererPanel.viewportGestureKey,
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) {
                        unawaited(
                          controller.pickAt(
                            details.localPosition,
                            viewportSize,
                          ),
                        );
                      },
                      onScaleStart: (_) => onScaleStart(),
                      onScaleUpdate: onScaleUpdate,
                      onScaleEnd: (_) => onScaleEnd(),
                      child: AnatomyRendererPlatformView(
                        controller: controller,
                        rendererOptions: rendererOptions,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                top: AppSpacing.sm,
                child: _ViewportOverlayControls(
                  heatmaps: trainingHeatmaps,
                  selectedKind: selectedKind,
                  onApply: onApply,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewportOverlayControls extends StatelessWidget {
  const _ViewportOverlayControls({
    required this.heatmaps,
    required this.selectedKind,
    required this.onApply,
  });

  final AsyncValue<AnatomyTrainingHeatmapSet>? heatmaps;
  final AnatomyTrainingHeatmapKind selectedKind;
  final void Function(
    AnatomyTrainingHeatmapKind kind,
    AnatomyTrainingHeatmapSet heatmaps,
  )
  onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      key: AnatomyRendererPanel.overlayControlsKey,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: AppRadii.large,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppStatusChip(
              label: l10n.anatomyOverlayVisualEstimate,
              icon: Icons.info_outline,
              tone: AppStatusTone.information,
            ),
            if (heatmaps == null)
              AppStatusChip(
                label: l10n.anatomyOverlayTapToInspect,
                icon: Icons.touch_app_outlined,
                tone: AppStatusTone.neutral,
              )
            else
              heatmaps!.when(
                data: (heatmapSet) => Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final kind in AnatomyTrainingHeatmapKind.values)
                      ChoiceChip(
                        key: _overlayHeatmapButtonKey(kind),
                        label: Text(_trainingHeatmapLabel(l10n, kind)),
                        selected: selectedKind == kind,
                        onSelected: (_) => onApply(kind, heatmapSet),
                      ),
                  ],
                ),
                loading: () => AppStatusChip(
                  label: l10n.anatomyTrainingHeatmapLoading,
                  icon: Icons.hourglass_empty,
                  tone: AppStatusTone.neutral,
                ),
                error: (_, _) => AppStatusChip(
                  label: l10n.anatomyTrainingHeatmapLoadError,
                  icon: Icons.error_outline,
                  tone: AppStatusTone.danger,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VisualEstimateDisclosureCard extends StatelessWidget {
  const _VisualEstimateDisclosureCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: AnatomyRendererPanel.visualEstimateDisclosureKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              semanticLabel: l10n.anatomyVisualEstimateIconLabel,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.anatomyVisualEstimateLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.anatomyVisualEstimateDescription,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.anatomyVisualEstimateInputNote,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingHeatmapCard extends StatelessWidget {
  const _TrainingHeatmapCard({
    required this.heatmaps,
    required this.selectedKind,
    required this.onApply,
  });

  final AsyncValue<AnatomyTrainingHeatmapSet> heatmaps;
  final AnatomyTrainingHeatmapKind selectedKind;
  final void Function(
    AnatomyTrainingHeatmapKind kind,
    AnatomyTrainingHeatmapSet heatmaps,
  )
  onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: AnatomyRendererPanel.trainingHeatmapCardKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.anatomyTrainingHeatmapTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.anatomyTrainingHeatmapDescription,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            heatmaps.when(
              data: (heatmapSet) => _TrainingHeatmapDataControls(
                heatmaps: heatmapSet,
                selectedKind: selectedKind,
                onApply: onApply,
              ),
              loading: () => Text(
                key: AnatomyRendererPanel.trainingHeatmapStatusKey,
                l10n.anatomyTrainingHeatmapLoading,
                style: theme.textTheme.labelMedium,
              ),
              error: (_, _) => Text(
                key: AnatomyRendererPanel.trainingHeatmapStatusKey,
                l10n.anatomyTrainingHeatmapLoadError,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingHeatmapDataControls extends StatelessWidget {
  const _TrainingHeatmapDataControls({
    required this.heatmaps,
    required this.selectedKind,
    required this.onApply,
  });

  final AnatomyTrainingHeatmapSet heatmaps;
  final AnatomyTrainingHeatmapKind selectedKind;
  final void Function(
    AnatomyTrainingHeatmapKind kind,
    AnatomyTrainingHeatmapSet heatmaps,
  )
  onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedHeatmap = heatmaps.heatmapFor(selectedKind);
    final strongestRegionId = selectedHeatmap.strongestEntry?.regionId;
    final previewEntries = selectedHeatmap.entries.take(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final kind in AnatomyTrainingHeatmapKind.values)
              ChoiceChip(
                key: _trainingHeatmapButtonKey(kind),
                label: Text(_trainingHeatmapLabel(l10n, kind)),
                selected: selectedKind == kind,
                onSelected: (_) => onApply(kind, heatmaps),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          key: AnatomyRendererPanel.trainingHeatmapStatusKey,
          selectedHeatmap.isEmpty
              ? l10n.anatomyTrainingHeatmapEmpty
              : l10n.anatomyTrainingHeatmapSummary(
                  selectedHeatmap.entries.length,
                  strongestRegionId ?? '',
                ),
          style: theme.textTheme.labelMedium,
        ),
        if (previewEntries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in previewEntries)
                _HeatmapChip(regionId: entry.regionId, score: entry.score),
            ],
          ),
        ],
      ],
    );
  }
}

class AnatomyRendererPlatformView extends StatelessWidget {
  const AnatomyRendererPlatformView({
    super.key,
    required this.controller,
    required this.rendererOptions,
  });

  final AnatomyInteractionController controller;
  final AnatomyRendererOptions rendererOptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        rendererOptions.usesPlatformView) {
      return AndroidView(
        key: AnatomyRendererPanel.platformViewKey,
        viewType: AnatomyRendererBridge.viewType,
        creationParams: <String, Object?>{
          'assetBundled': false,
          'contentDescription': l10n.anatomyRendererContentDescription,
          'expectedNodeExtras': AnatomyRendererBridge.requiredNodeExtras,
          'initialCameraPose': controller.cameraPose.toMap(),
          'initialHeatmap': controller.heatmap,
          'pickableRegionIds': controller.pickableRegionIds,
          ...rendererOptions.toCreationParams(),
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (viewId) {
          PerformanceMarkers.mark('anatomy_platform_view_created');
          controller.attachPlatformView(viewId);
        },
      );
    }

    final usesPerformanceFallback =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return Center(
      key: AnatomyRendererPanel.fallbackKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Semantics(
          key: usesPerformanceFallback
              ? AnatomyRendererPanel.performanceFallbackKey
              : null,
          liveRegion: usesPerformanceFallback,
          child: Text(
            usesPerformanceFallback
                ? l10n.anatomyRendererPerformanceFallback
                : l10n.anatomyRendererAndroidOnly,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _RendererInteractionSummary extends StatelessWidget {
  const _RendererInteractionSummary({required this.controller});

  final AnatomyInteractionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pose = controller.cameraPose;
    final selectedRegionId = controller.selectedRegionId;
    final heatmapEntries = controller.heatmap.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          key: AnatomyRendererPanel.cameraStateTextKey,
          l10n.anatomyRendererCameraState(
            pose.yawDegrees.toStringAsFixed(0),
            pose.pitchDegrees.toStringAsFixed(0),
            pose.zoom.toStringAsFixed(1),
          ),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          key: AnatomyRendererPanel.selectedRegionTextKey,
          selectedRegionId == null
              ? l10n.anatomyRendererNoRegionSelected
              : l10n.anatomyRendererSelectedRegion(selectedRegionId),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              key: AnatomyRendererPanel.resetCameraButtonKey,
              onPressed: controller.resetCamera,
              icon: const Icon(Icons.center_focus_strong),
              label: Text(l10n.anatomyRendererResetCamera),
            ),
            FilledButton.tonalIcon(
              key: AnatomyRendererPanel.heatmapPreviewButtonKey,
              onPressed: controller.applyPreviewHeatmap,
              icon: const Icon(Icons.local_fire_department_outlined),
              label: Text(l10n.anatomyRendererPreviewHeatmap),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          key: AnatomyRendererPanel.heatmapLegendKey,
          heatmapEntries.isEmpty
              ? l10n.anatomyRendererHeatmapEmpty
              : l10n.anatomyRendererHeatmapLegend,
          style: theme.textTheme.labelMedium,
        ),
        if (heatmapEntries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in heatmapEntries)
                _HeatmapChip(regionId: entry.key, score: entry.value),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeatmapChip extends StatelessWidget {
  const _HeatmapChip({required this.regionId, required this.score});

  final String regionId;
  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = Color.lerp(
      theme.colorScheme.surfaceContainerHighest,
      theme.colorScheme.primary,
      score,
    );

    return Chip(
      backgroundColor: backgroundColor,
      label: Text('$regionId ${(score * 100).round()}%'),
    );
  }
}

class _RendererCapabilitySummary extends StatefulWidget {
  const _RendererCapabilitySummary({required this.rendererOptions});

  final AnatomyRendererOptions rendererOptions;

  @override
  State<_RendererCapabilitySummary> createState() =>
      _RendererCapabilitySummaryState();
}

class _RendererCapabilitySummaryState
    extends State<_RendererCapabilitySummary> {
  late final Future<AnatomyRendererCapabilities> _capabilities =
      AnatomyRendererBridge().getCapabilities();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<AnatomyRendererCapabilities>(
      future: _capabilities,
      builder: (context, snapshot) {
        final capabilities = snapshot.data;
        final label = capabilities == null
            ? l10n.anatomyRendererStatusLoading
            : l10n.anatomyRendererStatus(
                capabilities.backend,
                capabilities.supportsGlb
                    ? l10n.anatomyRendererGlbSupported
                    : l10n.anatomyRendererGlbUnavailable,
                capabilities.assetBundled
                    ? l10n.anatomyRendererAssetBundled
                    : l10n.anatomyRendererAssetExternal,
              );
        final policyLabel = l10n.anatomyRendererPolicyStatus(
          _rendererModeLabel(l10n, widget.rendererOptions.mode),
          widget.rendererOptions.lodTier.wireName,
        );

        return Semantics(liveRegion: true, child: Text('$label\n$policyLabel'));
      },
    );
  }
}

String _rendererModeLabel(
  AppLocalizations l10n,
  AnatomyRendererMode rendererMode,
) {
  return switch (rendererMode) {
    AnatomyRendererMode.staticFallback =>
      l10n.anatomyRendererModeStaticFallback,
    AnatomyRendererMode.interactiveLite =>
      l10n.anatomyRendererModeInteractiveLite,
  };
}

Key _trainingHeatmapButtonKey(AnatomyTrainingHeatmapKind kind) {
  return switch (kind) {
    AnatomyTrainingHeatmapKind.trainedMuscle =>
      AnatomyRendererPanel.trainedMuscleHeatmapButtonKey,
    AnatomyTrainingHeatmapKind.weeklyVolume =>
      AnatomyRendererPanel.weeklyVolumeHeatmapButtonKey,
    AnatomyTrainingHeatmapKind.fatigue =>
      AnatomyRendererPanel.fatigueHeatmapButtonKey,
  };
}

Key _overlayHeatmapButtonKey(AnatomyTrainingHeatmapKind kind) {
  return switch (kind) {
    AnatomyTrainingHeatmapKind.trainedMuscle =>
      AnatomyRendererPanel.overlayTrainedMuscleHeatmapButtonKey,
    AnatomyTrainingHeatmapKind.weeklyVolume =>
      AnatomyRendererPanel.overlayWeeklyVolumeHeatmapButtonKey,
    AnatomyTrainingHeatmapKind.fatigue =>
      AnatomyRendererPanel.overlayFatigueHeatmapButtonKey,
  };
}

String _trainingHeatmapLabel(
  AppLocalizations l10n,
  AnatomyTrainingHeatmapKind kind,
) {
  return switch (kind) {
    AnatomyTrainingHeatmapKind.trainedMuscle =>
      l10n.anatomyTrainingHeatmapTrainedMuscle,
    AnatomyTrainingHeatmapKind.weeklyVolume =>
      l10n.anatomyTrainingHeatmapWeeklyVolume,
    AnatomyTrainingHeatmapKind.fatigue => l10n.anatomyTrainingHeatmapFatigue,
  };
}
