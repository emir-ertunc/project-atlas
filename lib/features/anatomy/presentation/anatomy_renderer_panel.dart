import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/performance/performance_markers.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_interaction_controller.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_performance_policy.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class AnatomyRendererPanel extends StatefulWidget {
  const AnatomyRendererPanel({
    super.key,
    this.controller,
    this.rendererOptions,
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

  final AnatomyInteractionController? controller;
  final AnatomyRendererOptions? rendererOptions;

  @override
  State<AnatomyRendererPanel> createState() => _AnatomyRendererPanelState();
}

class _AnatomyRendererPanelState extends State<AnatomyRendererPanel> {
  late final AnatomyInteractionController _controller =
      widget.controller ?? AnatomyInteractionController();
  late final bool _ownsController = widget.controller == null;
  late final AnatomyRendererOptions _rendererOptions =
      widget.rendererOptions ?? AnatomyPerformancePolicy.defaultOptions();
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
                      Text(
                        l10n.anatomyRendererTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.anatomyRendererDescription,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.anatomyInteractionInstructions,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: viewportHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
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
                                      _controller.pickAt(
                                        details.localPosition,
                                        viewportSize,
                                      ),
                                    );
                                  },
                                  onScaleStart: (_) {
                                    _lastScale = 1;
                                  },
                                  onScaleUpdate: (details) {
                                    if (details.scale != 1) {
                                      final scaleDelta =
                                          details.scale / _lastScale;
                                      _lastScale = details.scale;
                                      _controller.zoomByScale(scaleDelta);
                                    }

                                    if (details.pointerCount <= 1) {
                                      _controller.rotateByDragDelta(
                                        details.focalPointDelta,
                                      );
                                    }
                                  },
                                  onScaleEnd: (_) {
                                    _lastScale = 1;
                                  },
                                  child: AnatomyRendererPlatformView(
                                    controller: _controller,
                                    rendererOptions: _rendererOptions,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _RendererInteractionSummary(controller: _controller),
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
}

double _viewportHeightFor(double availableHeight) {
  if (!availableHeight.isFinite) {
    return 280;
  }
  return (availableHeight * 0.42).clamp(220.0, 360.0);
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
