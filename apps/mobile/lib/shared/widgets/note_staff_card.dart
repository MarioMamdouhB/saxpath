import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../music/sax_reference.dart';
import 'sax_card.dart';

class NoteStaffCard extends StatelessWidget {
  const NoteStaffCard({
    super.key,
    required this.noteLabel,
    this.title = 'النغمة على المدرج',
  });

  final String noteLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 168,
            child: CustomPaint(
              painter: _StaffPainter(noteLabel),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffPainter extends CustomPainter {
  _StaffPainter(this.noteLabel);

  final String noteLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2.3;

    final leftInset = size.width * 0.08;
    final rightInset = size.width * 0.04;
    final lineSpacing = size.height * 0.16;
    final firstLineY = size.height * 0.23;
    final bottomLineY = firstLineY + (lineSpacing * 4);

    for (var i = 0; i < 5; i++) {
      final y = firstLineY + (i * lineSpacing);
      canvas.drawLine(
        Offset(leftInset, y),
        Offset(size.width - rightInset, y),
        paint,
      );
    }

    final clefPainter = TextPainter(
      text: const TextSpan(
        text: '𝄞',
        style: TextStyle(
          fontSize: 60,
          color: AppColors.charcoal,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    clefPainter.paint(canvas, Offset(leftInset - 2, firstLineY - 16));

    final tokens = _extractNoteTokens(noteLabel);
    final noteStartX = size.width * 0.56;
    final noteGap = tokens.length == 1 ? 0.0 : size.width * 0.11;

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final step = lookupSaxReference(token).staffStepFromBottom;
      final noteCenter = Offset(
        noteStartX + (i * noteGap),
        bottomLineY - (step * lineSpacing / 2),
      );

      final ovalRect = Rect.fromCenter(
        center: noteCenter,
        width: 28,
        height: 20,
      );
      canvas.drawOval(
        ovalRect,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.fill,
      );

      final stemStart = Offset(noteCenter.dx + 12, noteCenter.dy);
      final stemEnd = Offset(noteCenter.dx + 12, noteCenter.dy - 58);
      canvas.drawLine(
        stemStart,
        stemEnd,
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.6,
      );

      _drawLedgerLines(
        canvas,
        noteCenter: noteCenter,
        step: step,
        bottomLineY: bottomLineY,
        lineSpacing: lineSpacing,
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text: token,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(noteCenter.dx - (labelPainter.width / 2), size.height - 22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StaffPainter oldDelegate) {
    return oldDelegate.noteLabel != noteLabel;
  }

  void _drawLedgerLines(
    Canvas canvas, {
    required Offset noteCenter,
    required int step,
    required double bottomLineY,
    required double lineSpacing,
  }) {
    final ledgerPaint = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2;

    if (step < 0) {
      for (var currentStep = step; currentStep <= 0; currentStep += 2) {
        final y = bottomLineY - (currentStep * lineSpacing / 2);
        canvas.drawLine(
          Offset(noteCenter.dx - 18, y),
          Offset(noteCenter.dx + 18, y),
          ledgerPaint,
        );
      }
    }

    if (step > 8) {
      for (var currentStep = 8; currentStep <= step; currentStep += 2) {
        final y = bottomLineY - (currentStep * lineSpacing / 2);
        canvas.drawLine(
          Offset(noteCenter.dx - 18, y),
          Offset(noteCenter.dx + 18, y),
          ledgerPaint,
        );
      }
    }
  }

  List<String> _extractNoteTokens(String input) {
    final matches = RegExp(r'[A-G]').allMatches(input.toUpperCase());
    final tokens = <String>[];
    for (final match in matches) {
      final token = match.group(0);
      if (token != null) {
        tokens.add(token);
      }
    }
    return tokens.isEmpty ? const ['G'] : tokens;
  }
}
