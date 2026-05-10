import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SaxPathBrandMark extends StatelessWidget {
  const SaxPathBrandMark({
    super.key,
    this.label = 'SaxPath',
    this.compact = false,
    this.showWordmark = true,
  });

  final String label;
  final bool compact;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 34.0 : 40.0;
    final noteSize = compact ? 18.0 : 22.0;
    final dotSize = compact ? 5.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.deepTeal,
              borderRadius: BorderRadius.circular(compact ? 12 : 14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.music_note_rounded,
                  size: noteSize,
                  color: Colors.white,
                ),
                PositionedDirectional(
                  start: compact ? 7 : 8,
                  top: compact ? 8 : 9,
                  child: _KeyDot(size: dotSize),
                ),
                PositionedDirectional(
                  start: compact ? 8 : 9,
                  top: compact ? 15 : 17,
                  child: _KeyDot(size: dotSize),
                ),
                PositionedDirectional(
                  start: compact ? 13 : 15,
                  top: compact ? 21 : 24,
                  child: _KeyDot(size: dotSize),
                ),
              ],
            ),
          ),
          if (showWordmark) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 15 : 12,
                fontWeight: FontWeight.w900,
                color: AppColors.deepTeal,
                letterSpacing: compact ? 0 : 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeyDot extends StatelessWidget {
  const _KeyDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE0B23C),
        shape: BoxShape.circle,
      ),
    );
  }
}
