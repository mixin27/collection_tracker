import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({required this.label, required this.value, required this.color});
}

class ChartCard extends StatelessWidget {
  final List<ChartData> data;

  const ChartCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bar Chart
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
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${item.value.toInt()} (${percentage.toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? item.value / total : 0,
                        backgroundColor: item.color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),

            // Pie Chart
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: PieChartPainter(data: data, total: total),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double total;

  PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

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

      // Draw white border between segments
      final borderPaint = Paint()
        ..color = Colors.white
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

    // Draw center circle (donut chart effect)
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
