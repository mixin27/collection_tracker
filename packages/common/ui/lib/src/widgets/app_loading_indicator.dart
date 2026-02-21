import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoadingIndicator({
    this.size = 52,
    this.strokeWidth = 3,
    this.color,
    super.key,
  });

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1280),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _LoadingPainter(
            progress: _controller.value,
            color: color,
            trackColor: theme.colorScheme.outlineVariant,
            centerColor: theme.colorScheme.surface,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final Color centerColor;
  final double strokeWidth;

  _LoadingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.centerColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - strokeWidth * 1.2;

    final track = Paint()
      ..color = trackColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final start = -math.pi / 2 + (2 * math.pi * progress);
    final sweep = math.pi * (0.95 + (0.28 * math.sin(progress * 2 * math.pi)));

    final active = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      active,
    );

    final head = Offset(
      center.dx + radius * math.cos(start + sweep),
      center.dy + radius * math.sin(start + sweep),
    );

    final headPaint = Paint()..color = color;
    canvas.drawCircle(head, strokeWidth * 0.9, headPaint);

    final pulseScale = 0.78 + (0.12 * math.sin(progress * 2 * math.pi));
    final innerRadius = radius * 0.43 * pulseScale;

    final innerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);

    final cube = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: innerRadius * 1.1,
        height: innerRadius * 1.1,
      ),
      Radius.circular(innerRadius * 0.3),
    );
    final cubePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cube, cubePaint);
  }

  @override
  bool shouldRepaint(covariant _LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.centerColor != centerColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
