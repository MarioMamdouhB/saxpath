import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class NotationStepCard extends StatelessWidget {
  const NotationStepCard({
    super.key,
    required this.title,
    required this.description,
    this.noteLabel,
    this.isCompleted = false,
    this.onStart,
  });

  final String title;
  final String description;
  final String? noteLabel;
  final bool isCompleted;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24)
              else
                const Icon(Icons.play_circle_outline_rounded, color: AppColors.deepTeal, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: AppColors.muted, height: 1.4)),
          if (noteLabel != null) ...[
            const SizedBox(height: 16),
            NoteStaffCard(noteLabel: noteLabel!),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.grey[200] : AppColors.deepTeal,
                foregroundColor: isCompleted ? Colors.black87 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isCompleted ? 'إعادة التمرين' : 'ابدأ التمرين العملي'),
            ),
          ),
        ],
      ),
    );
  }
}
