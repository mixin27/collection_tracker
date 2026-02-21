import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({required this.label, required this.value, required this.color});
}

class ChartCard extends StatelessWidget {
  final List<ChartData> data;
  final String? emptyLabel;

  const ChartCard({required this.data, this.emptyLabel, super.key});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return AppCard(
        child: Center(
          child: Text(
            emptyLabel ?? 'No chart data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return AppCard(
      child: Column(
        children: [
          ...data.map((item) {
            final percentage = total > 0 ? (item.value / total) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${item.value.toInt()} (${percentage.toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: TweenAnimationBuilder<double>(
                      duration: AppMotion.slow,
                      tween: Tween(
                        begin: 0,
                        end: total > 0 ? item.value / total : 0,
                      ),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: item.color.withValues(alpha: 0.18),
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: PieChartPainter(
                data: data,
                total: total,
                centerColor: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      total.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double total;
  final Color centerColor;

  PieChartPainter({
    required this.data,
    required this.total,
    required this.centerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;

    double startAngle = -math.pi / 2;

    for (final item in data) {
      final sweepAngle = total > 0 ? (item.value / total) * 2 * math.pi : 0;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle.toDouble(),
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle.toDouble(),
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    final centerCirclePaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.56, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.total != total ||
        oldDelegate.centerColor != centerColor;
  }
}
