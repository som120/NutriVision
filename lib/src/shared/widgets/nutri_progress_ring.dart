import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A circular progress indicator with animated gradient ring
class NutriProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Gradient? gradient;
  final Widget? child;

  const NutriProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.progressColor,
    this.gradient,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _GradientRingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              gradient:
                  gradient ??
                  LinearGradient(
                    colors: [
                      progressColor ?? AppColors.primary,
                      (progressColor ?? AppColors.primary).withValues(
                        alpha: 0.6,
                      ),
                    ],
                  ),
            ),
          ),
          // Center content
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
