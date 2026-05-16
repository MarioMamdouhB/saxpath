import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

enum RhythmDrillType { tap, clap, count }

class RhythmDrillCard extends StatefulWidget {
  const RhythmDrillCard({
    super.key,
    required this.type,
    required this.title,
    required this.targetCount,
    this.onCompleted,
  });

  final RhythmDrillType type;
  final String title;
  final int targetCount;
  final VoidCallback? onCompleted;

  @override
  State<RhythmDrillCard> createState() => _RhythmDrillCardState();
}

class _RhythmDrillCardState extends State<RhythmDrillCard> {
  int _currentCount = 0;
  bool _isDone = false;

  void _handleAction() {
    if (_isDone) return;

    setState(() {
      _currentCount++;
      if (_currentCount >= widget.targetCount) {
        _isDone = true;
        widget.onCompleted?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.type) {
      RhythmDrillType.tap => Icons.touch_app_rounded,
      RhythmDrillType.clap => Icons.front_hand_rounded,
      RhythmDrillType.count => Icons.record_voice_over_rounded,
    };

    final actionLabel = switch (widget.type) {
      RhythmDrillType.tap => 'انقر هنا مع النبض',
      RhythmDrillType.clap => 'صفق الآن',
      RhythmDrillType.count => 'عدّ بصوت عالٍ',
    };

    return SaxCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.deepTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (_isDone)
                const Icon(Icons.check_circle_rounded, color: Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: _currentCount / widget.targetCount,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(AppColors.deepTeal),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text('$_currentCount / ${widget.targetCount}', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 80,
            child: ElevatedButton(
              onPressed: _isDone ? null : _handleAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.paleMint,
                foregroundColor: AppColors.deepTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _isDone ? 'تم التدريب بنجاح' : actionLabel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
