import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';

class LearningPathNode extends StatefulWidget {
  const LearningPathNode({
    super.key,
    required this.title,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    this.onTap,
    this.isExam = false,
  });

  final String title;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final bool isExam;
  final VoidCallback? onTap;

  @override
  State<LearningPathNode> createState() => _LearningPathNodeState();
}

class _LearningPathNodeState extends State<LearningPathNode> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isExam ? 110.0 : 85.0;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.isLocked ? null : widget.onTap,
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.05).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow / Depth
                Container(
                  width: size,
                  height: size,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: _getShadowColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                // Main Button
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: _getMainColor(),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isCurrent ? Colors.white : Colors.transparent,
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: widget.isLocked ? Colors.grey[500] : Colors.white,
                    size: widget.isExam ? 42 : 32,
                  ),
                ),
                // Progress Ring for current node
                if (widget.isCurrent)
                  SizedBox(
                    width: size + 16,
                    height: size + 16,
                    child: CircularProgressIndicator(
                      value: 0.3, // Example progress
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepTeal),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isLocked ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isLocked ? [] : [
              const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: widget.isLocked ? Colors.grey : AppColors.deepTeal,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Color _getMainColor() {
    if (widget.isLocked) return Colors.grey[300]!;
    if (widget.isExam) return const Color(0xFFFFC107); // Gold
    if (widget.isCompleted) return AppColors.deepTeal;
    return AppColors.primary;
  }

  Color _getShadowColor() {
    if (widget.isLocked) return Colors.grey[400]!;
    if (widget.isExam) return const Color(0xFFFFA000);
    if (widget.isCompleted) return const Color(0xFF0D3A42);
    return const Color(0xFF0A1F35);
  }

  IconData _getIcon() {
    if (widget.isLocked) return Icons.lock_rounded;
    if (widget.isCompleted) return Icons.check_rounded;
    if (widget.isExam) return Icons.emoji_events_rounded;
    return Icons.play_arrow_rounded;
  }
}
