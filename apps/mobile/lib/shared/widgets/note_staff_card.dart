import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../music/sax_reference.dart';
import 'sax_card.dart';

class NoteStaffCard extends StatelessWidget {
  const NoteStaffCard({
    super.key,
    required this.noteLabel,
    this.title = 'النغمة على المدرج',
    this.highlightedIndex,
  });

  final String noteLabel;
  final String title;
  final int? highlightedIndex;

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
              painter: _StaffPainter(noteLabel, highlightedIndex),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffPainter extends CustomPainter {
  _StaffPainter(this.noteLabel, this.highlightedIndex);

  final String noteLabel;
  final int? highlightedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.8)
      ..strokeWidth = 2.0;

    final leftInset = size.width * 0.05;
    final rightInset = size.width * 0.05;
    final lineSpacing = 14.0; // Professional standard spacing
    final firstLineY = size.height * 0.28;
    final bottomLineY = firstLineY + (lineSpacing * 4);

    // Draw Staff Lines
    for (var i = 0; i < 5; i++) {
      final y = firstLineY + (i * lineSpacing);
      canvas.drawLine(
        Offset(leftInset, y),
        Offset(size.width - rightInset, y),
        paint,
      );
    }

    // Treble Clef
    final clefPainter = TextPainter(
      text: const TextSpan(
        text: '𝄞',
        style: TextStyle(
          fontSize: 82,
          color: AppColors.charcoal,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    clefPainter.paint(canvas, Offset(leftInset - 4, firstLineY - 18));

    final tokens = _extractNoteTokens(noteLabel);
    final noteStartX = size.width * 0.42; // More space for clef
    final noteGap = 42.0; // Professional standard spacing

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final reference = lookupSaxReference(token);
      final step = reference.staffStepFromBottom;
      final isHighlighted = highlightedIndex == i;

      final noteCenter = Offset(
        noteStartX + (i * noteGap),
        bottomLineY - (step * lineSpacing / 2),
      );

      final noteColor = isHighlighted ? Colors.green : AppColors.charcoal;

      // Draw Accidental (#, b, d)
      if (token.contains('#') || token.contains('b') || token.contains('d')) {
        final accidental = token.contains('#') ? '#' : (token.contains('d') ? 'd' : 'b');
        final accidentalPainter = TextPainter(
          text: TextSpan(
            text: accidental,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.charcoal,
              fontFamily: 'serif',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        accidentalPainter.paint(canvas, Offset(noteCenter.dx - 28, noteCenter.dy - 12));
      }

      // Draw rotated note head for professionalism
      canvas.save();
      canvas.translate(noteCenter.dx, noteCenter.dy);
      canvas.rotate(-0.2); // Slight slant
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 14 * 1.4, height: 14),
        Paint()
          ..color = noteColor
          ..style = PaintingStyle.fill,
      );
      canvas.restore();

      final stemStart = Offset(noteCenter.dx + (14 * 0.7), noteCenter.dy);
      final stemEnd = Offset(noteCenter.dx + (14 * 0.7), noteCenter.dy - 52);
      canvas.drawLine(
        stemStart,
        stemEnd,
        Paint()
          ..color = noteColor
          ..strokeWidth = 1.8,
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
    return oldDelegate.noteLabel != noteLabel || oldDelegate.highlightedIndex != highlightedIndex;
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
    // Improved regex to catch Note Names, Accidentals, and optional Register numbers
    final matches = RegExp(r'[A-G](?:#|b|d)?\d?').allMatches(input.toUpperCase());
    final tokens = <String>[];
    for (final match in matches) {
      final token = match.group(0);
      if (token != null) {
        tokens.add(token);
      }
    }
    return tokens.isEmpty ? const ['G4'] : tokens;
  }
}
