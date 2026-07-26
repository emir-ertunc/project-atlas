import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';

class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    required this.progress,
    this.size = AppComponentTokens.standardProgressRingSize,
    this.strokeWidth = AppComponentTokens.progressRingStroke,
    this.center,
    this.semanticLabel,
    this.color,
    this.trackColor,
    this.animate = true,
    super.key,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? center;
  final String? semanticLabel;
  final Color? color;
  final Color? trackColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = color ?? colorScheme.primary;
    final background = trackColor ?? colorScheme.surfaceContainerHighest;
    final label =
        semanticLabel ?? '${(normalizedProgress * 100).round()}% complete';

    Widget buildRing(double value) {
      return SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _ProgressRingPainter(
                progress: value,
                strokeWidth: strokeWidth,
                color: foreground,
                trackColor: background,
              ),
            ),
            if (center != null) ExcludeSemantics(child: center!),
          ],
        ),
      );
    }

    return Semantics(
      label: label,
      value: '${(normalizedProgress * 100).round()}%',
      child: animate
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: normalizedProgress),
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              builder: (context, value, child) => buildRing(value),
            )
          : buildRing(normalizedProgress),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = trackColor);

    if (progress <= 0) {
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor;
  }
}
