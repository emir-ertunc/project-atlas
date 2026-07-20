import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';

class ExerciseThumbnail extends StatelessWidget {
  const ExerciseThumbnail({
    required this.exercise,
    required this.localeCode,
    this.size = 56,
    super.key,
  });

  static Key thumbnailKey(String exerciseId) =>
      Key('exercise-thumbnail-$exerciseId');

  static Key animationBadgeKey(String exerciseId) =>
      Key('exercise-animation-badge-$exerciseId');

  final ExerciseCatalogEntry exercise;
  final String localeCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      image: true,
      label: exercise.name(localeCode),
      child: SizedBox.square(
        key: thumbnailKey(exercise.id),
        dimension: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ExerciseThumbnailPainter(
                  variant: exercise.media.thumbnailVariant,
                  hasAnimation: exercise.media.hasAnimation,
                  colorScheme: theme.colorScheme,
                ),
              ),
            ),
            if (exercise.media.hasAnimation)
              Positioned(
                right: AppSpacing.xxs,
                bottom: AppSpacing.xxs,
                child: Container(
                  key: animationBadgeKey(exercise.id),
                  width: size * 0.30,
                  height: size * 0.30,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: size * 0.22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseThumbnailPainter extends CustomPainter {
  const _ExerciseThumbnailPainter({
    required this.variant,
    required this.hasAnimation,
    required this.colorScheme,
  });

  final String variant;
  final bool hasAnimation;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.shortestSide * 0.22);
    final background = Paint()..color = colorScheme.surfaceContainerHighest;
    final border = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), background);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), border);

    final accent = Paint()
      ..color = _accentColor(colorScheme, variant)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.16),
      Offset(size.width * 0.82, size.height * 0.16),
      accent,
    );

    final figure = Paint()
      ..color = colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final joint = Paint()
      ..color = colorScheme.onSurface
      ..style = PaintingStyle.fill;
    final equipment = Paint()
      ..color = colorScheme.onSurfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (variant) {
      case 'squat':
      case 'knee_extension':
        _drawSquat(canvas, size, figure, joint, equipment);
      case 'hinge':
      case 'hip_extension':
      case 'single_leg_hinge':
        _drawHinge(canvas, size, figure, joint, equipment);
      case 'horizontal_push':
      case 'chest_fly':
        _drawHorizontalPush(canvas, size, figure, joint, equipment);
      case 'vertical_push':
      case 'shoulder_abduction':
        _drawVerticalPush(canvas, size, figure, joint, equipment);
      case 'horizontal_pull':
      case 'shoulder_horizontal_abduction':
        _drawHorizontalPull(canvas, size, figure, joint, equipment);
      case 'vertical_pull':
      case 'shoulder_extension':
        _drawVerticalPull(canvas, size, figure, joint, equipment);
      case 'single_leg_squat':
      case 'lateral_lunge':
        _drawSingleLeg(canvas, size, figure, joint, equipment);
      case 'loaded_carry':
        _drawCarry(canvas, size, figure, joint, equipment);
      case 'conditioning':
        _drawConditioning(canvas, size, figure, joint, equipment);
      case 'core':
        _drawCore(canvas, size, figure, joint, equipment);
      default:
        _drawIsolation(canvas, size, figure, joint, equipment);
    }

    if (!hasAnimation) {
      final overlay = Paint()
        ..color = colorScheme.surface.withValues(alpha: 0.32)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), overlay);
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseThumbnailPainter oldDelegate) {
    return variant != oldDelegate.variant ||
        hasAnimation != oldDelegate.hasAnimation ||
        colorScheme != oldDelegate.colorScheme;
  }
}

Color _accentColor(ColorScheme colorScheme, String variant) {
  return switch (variant) {
    'squat' ||
    'knee_extension' ||
    'single_leg_squat' ||
    'lateral_lunge' ||
    'single_leg_hinge' => colorScheme.tertiary,
    'hinge' || 'hip_extension' => colorScheme.secondary,
    'horizontal_push' || 'vertical_push' || 'chest_fly' => colorScheme.primary,
    'horizontal_pull' || 'vertical_pull' => colorScheme.error,
    'core' => colorScheme.inversePrimary,
    'loaded_carry' || 'conditioning' => colorScheme.secondary,
    _ => colorScheme.primary,
  };
}

void _drawSquat(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.50, size.height * 0.32);
  final shoulder = Offset(size.width * 0.48, size.height * 0.43);
  final hip = Offset(size.width * 0.40, size.height * 0.60);
  final knee = Offset(size.width * 0.57, size.height * 0.72);
  final foot = Offset(size.width * 0.72, size.height * 0.82);

  canvas.drawLine(
    Offset(size.width * 0.28, size.height * 0.40),
    Offset(size.width * 0.72, size.height * 0.40),
    equipment,
  );
  _stick(canvas, [shoulder, hip, knee, foot], figure);
  _stick(canvas, [
    shoulder,
    Offset(size.width * 0.34, size.height * 0.50),
    Offset(size.width * 0.28, size.height * 0.40),
  ], figure);
  _head(canvas, head, joint, size);
}

void _drawHinge(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.62, size.height * 0.34);
  final shoulder = Offset(size.width * 0.56, size.height * 0.45);
  final hip = Offset(size.width * 0.36, size.height * 0.58);
  final knee = Offset(size.width * 0.42, size.height * 0.74);
  final foot = Offset(size.width * 0.62, size.height * 0.80);

  canvas.drawLine(
    Offset(size.width * 0.24, size.height * 0.80),
    Offset(size.width * 0.76, size.height * 0.80),
    equipment,
  );
  _stick(canvas, [head, shoulder, hip, knee, foot], figure);
  _stick(canvas, [
    shoulder,
    Offset(size.width * 0.60, size.height * 0.62),
    Offset(size.width * 0.62, size.height * 0.78),
  ], figure);
  _head(canvas, head, joint, size);
}

void _drawHorizontalPush(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  canvas.drawLine(
    Offset(size.width * 0.18, size.height * 0.66),
    Offset(size.width * 0.82, size.height * 0.66),
    equipment,
  );
  canvas.drawLine(
    Offset(size.width * 0.26, size.height * 0.34),
    Offset(size.width * 0.74, size.height * 0.34),
    equipment,
  );
  _stick(canvas, [
    Offset(size.width * 0.25, size.height * 0.58),
    Offset(size.width * 0.48, size.height * 0.56),
    Offset(size.width * 0.72, size.height * 0.60),
  ], figure);
  _stick(canvas, [
    Offset(size.width * 0.44, size.height * 0.52),
    Offset(size.width * 0.42, size.height * 0.42),
    Offset(size.width * 0.36, size.height * 0.34),
  ], figure);
  _stick(canvas, [
    Offset(size.width * 0.56, size.height * 0.52),
    Offset(size.width * 0.58, size.height * 0.42),
    Offset(size.width * 0.64, size.height * 0.34),
  ], figure);
  _head(canvas, Offset(size.width * 0.22, size.height * 0.54), joint, size);
}

void _drawVerticalPush(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.50, size.height * 0.35);
  final shoulder = Offset(size.width * 0.50, size.height * 0.45);
  final hip = Offset(size.width * 0.50, size.height * 0.62);
  final foot = Offset(size.width * 0.50, size.height * 0.82);

  canvas.drawLine(
    Offset(size.width * 0.30, size.height * 0.24),
    Offset(size.width * 0.70, size.height * 0.24),
    equipment,
  );
  _stick(canvas, [head, shoulder, hip, foot], figure);
  _stick(canvas, [
    Offset(size.width * 0.40, size.height * 0.46),
    Offset(size.width * 0.34, size.height * 0.34),
    Offset(size.width * 0.32, size.height * 0.24),
  ], figure);
  _stick(canvas, [
    Offset(size.width * 0.60, size.height * 0.46),
    Offset(size.width * 0.66, size.height * 0.34),
    Offset(size.width * 0.68, size.height * 0.24),
  ], figure);
  _head(canvas, head, joint, size);
}

void _drawHorizontalPull(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.62, size.height * 0.36);
  final shoulder = Offset(size.width * 0.56, size.height * 0.48);
  final hip = Offset(size.width * 0.34, size.height * 0.58);
  final knee = Offset(size.width * 0.42, size.height * 0.76);
  final foot = Offset(size.width * 0.66, size.height * 0.80);

  canvas.drawLine(
    Offset(size.width * 0.24, size.height * 0.56),
    Offset(size.width * 0.76, size.height * 0.56),
    equipment,
  );
  _stick(canvas, [head, shoulder, hip, knee, foot], figure);
  _stick(canvas, [
    shoulder,
    Offset(size.width * 0.46, size.height * 0.56),
    Offset(size.width * 0.38, size.height * 0.56),
  ], figure);
  _head(canvas, head, joint, size);
}

void _drawVerticalPull(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  canvas.drawLine(
    Offset(size.width * 0.25, size.height * 0.23),
    Offset(size.width * 0.75, size.height * 0.23),
    equipment,
  );
  final head = Offset(size.width * 0.50, size.height * 0.50);
  final shoulder = Offset(size.width * 0.50, size.height * 0.60);
  final hip = Offset(size.width * 0.50, size.height * 0.73);
  _stick(canvas, [head, shoulder, hip], figure);
  _stick(canvas, [
    Offset(size.width * 0.40, size.height * 0.58),
    Offset(size.width * 0.34, size.height * 0.42),
    Offset(size.width * 0.32, size.height * 0.23),
  ], figure);
  _stick(canvas, [
    Offset(size.width * 0.60, size.height * 0.58),
    Offset(size.width * 0.66, size.height * 0.42),
    Offset(size.width * 0.68, size.height * 0.23),
  ], figure);
  _head(canvas, head, joint, size);
}

void _drawSingleLeg(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.48, size.height * 0.32);
  final shoulder = Offset(size.width * 0.48, size.height * 0.44);
  final hip = Offset(size.width * 0.44, size.height * 0.58);
  _stick(canvas, [head, shoulder, hip], figure);
  _stick(canvas, [
    hip,
    Offset(size.width * 0.56, size.height * 0.72),
    Offset(size.width * 0.74, size.height * 0.80),
  ], figure);
  _stick(canvas, [
    hip,
    Offset(size.width * 0.32, size.height * 0.74),
    Offset(size.width * 0.22, size.height * 0.82),
  ], figure);
  canvas.drawLine(
    Offset(size.width * 0.16, size.height * 0.84),
    Offset(size.width * 0.84, size.height * 0.84),
    equipment,
  );
  _head(canvas, head, joint, size);
}

void _drawCarry(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.50, size.height * 0.32);
  final shoulder = Offset(size.width * 0.50, size.height * 0.44);
  final hip = Offset(size.width * 0.50, size.height * 0.62);
  _stick(canvas, [
    head,
    shoulder,
    hip,
    Offset(size.width * 0.58, size.height * 0.82),
  ], figure);
  _stick(canvas, [
    shoulder,
    Offset(size.width * 0.34, size.height * 0.58),
    Offset(size.width * 0.28, size.height * 0.72),
  ], figure);
  _stick(canvas, [
    shoulder,
    Offset(size.width * 0.66, size.height * 0.58),
    Offset(size.width * 0.72, size.height * 0.72),
  ], figure);
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(size.width * 0.28, size.height * 0.78),
      width: size.width * 0.12,
      height: size.height * 0.14,
    ),
    equipment,
  );
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(size.width * 0.72, size.height * 0.78),
      width: size.width * 0.12,
      height: size.height * 0.14,
    ),
    equipment,
  );
  _head(canvas, head, joint, size);
}

void _drawConditioning(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  _stick(canvas, [
    Offset(size.width * 0.62, size.height * 0.30),
    Offset(size.width * 0.48, size.height * 0.44),
    Offset(size.width * 0.42, size.height * 0.62),
    Offset(size.width * 0.28, size.height * 0.80),
  ], figure);
  _stick(canvas, [
    Offset(size.width * 0.48, size.height * 0.44),
    Offset(size.width * 0.74, size.height * 0.46),
  ], figure);
  canvas.drawLine(
    Offset(size.width * 0.22, size.height * 0.84),
    Offset(size.width * 0.78, size.height * 0.84),
    equipment,
  );
  _head(canvas, Offset(size.width * 0.62, size.height * 0.30), joint, size);
}

void _drawCore(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  canvas.drawLine(
    Offset(size.width * 0.18, size.height * 0.74),
    Offset(size.width * 0.82, size.height * 0.74),
    equipment,
  );
  _stick(canvas, [
    Offset(size.width * 0.26, size.height * 0.60),
    Offset(size.width * 0.48, size.height * 0.58),
    Offset(size.width * 0.72, size.height * 0.62),
  ], figure);
  _stick(canvas, [
    Offset(size.width * 0.48, size.height * 0.58),
    Offset(size.width * 0.52, size.height * 0.42),
  ], figure);
  _head(canvas, Offset(size.width * 0.22, size.height * 0.58), joint, size);
}

void _drawIsolation(
  Canvas canvas,
  Size size,
  Paint figure,
  Paint joint,
  Paint equipment,
) {
  final head = Offset(size.width * 0.50, size.height * 0.32);
  final shoulder = Offset(size.width * 0.50, size.height * 0.44);
  final hip = Offset(size.width * 0.50, size.height * 0.64);
  _stick(canvas, [head, shoulder, hip], figure);
  _stick(canvas, [
    shoulder,
    Offset(size.width * 0.68, size.height * 0.52),
    Offset(size.width * 0.72, size.height * 0.66),
  ], figure);
  canvas.drawCircle(
    Offset(size.width * 0.72, size.height * 0.69),
    size.shortestSide * 0.06,
    equipment,
  );
  _head(canvas, head, joint, size);
}

void _stick(Canvas canvas, List<Offset> points, Paint paint) {
  for (var index = 0; index < points.length - 1; index += 1) {
    canvas.drawLine(points[index], points[index + 1], paint);
  }
}

void _head(Canvas canvas, Offset center, Paint paint, Size size) {
  canvas.drawCircle(center, size.shortestSide * 0.055, paint);
}
