import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';

class MasteryTrendGraph extends StatelessWidget {
  const MasteryTrendGraph({
    super.key,
    required this.deltas,
    required this.currentScore,
  });

  final List<int> deltas;
  final int currentScore;

  @override
  Widget build(BuildContext context) {
    if (deltas.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: Text('لا توجد بيانات كافية للرسم البياني بعد.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ),
      );
    }

    // Calculate historical points
    List<int> scores = [currentScore];
    int tempScore = currentScore;
    for (var delta in deltas) {
      tempScore -= delta;
      scores.add(tempScore);
    }
    scores = scores.reversed.toList();

    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _TrendPainter(scores: scores),
        size: Size.infinite,
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<int> scores;
  _TrendPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;

    final paint = Paint()
      ..color = AppColors.deepTeal
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.deepTeal.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final stepX = size.width / (scores.length - 1);

    path.moveTo(0, size.height - (scores[0] / 100 * size.height));

    for (int i = 1; i < scores.length; i++) {
      path.lineTo(i * stepX, size.height - (scores[i] / 100 * size.height));
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots for each point
    final dotPaint = Paint()..color = AppColors.deepTeal;
    for (int i = 0; i < scores.length; i++) {
      canvas.drawCircle(Offset(i * stepX, size.height - (scores[i] / 100 * size.height)), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
