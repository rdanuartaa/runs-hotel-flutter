import 'package:flutter/material.dart';
import 'dart:math' as math;

// AREA CHART (Grafik Gunung)
class AreaChartWidget extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const AreaChartWidget({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || labels.isEmpty) return const SizedBox();
    
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CustomPaint(
              size: Size.infinite,
              painter: AreaChartPainter(values: values, color: color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.map((label) {
            return Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold));
          }).toList(),
        )
      ],
    );
  }
}

class AreaChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  AreaChartPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    double maxVal = 0;
    for (var v in values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1; // avoid division by zero

    final dx = size.width / (values.length > 1 ? values.length - 1 : 1);

    final path = Path();
    path.moveTo(0, size.height);

    final linePath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - (values[i] / maxVal * size.height);

      if (i == 0) {
        path.lineTo(x, y);
        linePath.moveTo(x, y);
      } else {
        // Simple smooth curve using bezier
        final prevX = (i - 1) * dx;
        final prevY = size.height - (values[i - 1] / maxVal * size.height);
        
        final controlPointX = prevX + (x - prevX) / 2;
        
        path.cubicTo(controlPointX, prevY, controlPointX, y, x, y);
        linePath.cubicTo(controlPointX, prevY, controlPointX, y, x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Fill Gradient
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.6), color.withOpacity(0.01)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Draw Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);
    
    // Draw Data Dots
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke;
    
    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - (values[i] / maxVal * size.height);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// PIE CHART / DONUT CHART
class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const PieChartWidget({super.key, required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200), // Diperlebar agar muat teks di luar
      painter: PieChartPainter(data: data, colors: colors),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.values.reduce((a, b) => a + b);
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.height / 2) * 0.6; // Perkecil pie chart (60% dari tinggi)
    final rect = Rect.fromCircle(center: center, radius: radius);

    int i = 0;
    for (var entry in data.entries) {
      final percentage = (entry.value / total) * 100;
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      
      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw Arc (Slice)
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      if (percentage >= 2) {
        // Draw Text Percentage Outside
        final midAngle = startAngle + sweepAngle / 2;
        
        // Garis penghubung
        final startLine = Offset(center.dx + radius * 0.9 * math.cos(midAngle), center.dy + radius * 0.9 * math.sin(midAngle));
        final elbowLine = Offset(center.dx + radius * 1.25 * math.cos(midAngle), center.dy + radius * 1.25 * math.sin(midAngle));
        final isRight = math.cos(midAngle) >= 0;
        final endLine = Offset(elbowLine.dx + (isRight ? 15 : -15), elbowLine.dy);

        final linePaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
          
        final path = Path()
          ..moveTo(startLine.dx, startLine.dy)
          ..lineTo(elbowLine.dx, elbowLine.dy)
          ..lineTo(endLine.dx, endLine.dy);
          
        canvas.drawPath(path, linePaint);

        // Teks Persentase
        final textSpan = TextSpan(
          text: '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        );
        
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        // Atur posisi text agar tidak nabrak garis
        final textX = isRight ? endLine.dx + 4 : endLine.dx - textPainter.width - 4;
        final textY = endLine.dy - textPainter.height / 2;
        
        textPainter.paint(canvas, Offset(textX, textY));
      }

      startAngle += sweepAngle;
      i++;
    }
    
    // Inner circle untuk membuat efek Donut Chart (Gunung ditengahnya bolong)
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    // Ukuran bolongan di tengah (45% dari radius pie chart)
    canvas.drawCircle(center, radius * 0.45, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
