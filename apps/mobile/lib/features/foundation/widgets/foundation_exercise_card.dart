import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class FoundationExerciseCard extends StatelessWidget {
  const FoundationExerciseCard({
    super.key,
    required this.exercise,
    required this.onStart,
  });

  final FoundationPracticeExercise exercise;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${exercise.durationMinutes} د',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise.summary,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ExerciseMetaChip(label: '${exercise.recommendedBpm} BPM'),
              _ExerciseMetaChip(label: _categoryLabel(exercise.category)),
              if (exercise.relatedNoteIds.isNotEmpty)
                _ExerciseMetaChip(
                  label: 'Notes: ${exercise.relatedNoteIds.length}',
                ),
              if (exercise.relatedScaleIds.isNotEmpty)
                _ExerciseMetaChip(
                  label: 'Scale: ${exercise.relatedScaleIds.length}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'ابدأ التمرين',
            onPressed: onStart,
          ),
        ],
      ),
    );
  }

  String _categoryLabel(FoundationExerciseCategory category) {
    switch (category) {
      case FoundationExerciseCategory.warmup:
        return 'Warm-up';
      case FoundationExerciseCategory.noteFocus:
        return 'Note Focus';
      case FoundationExerciseCategory.scaleFlow:
        return 'Scale Flow';
      case FoundationExerciseCategory.coordination:
        return 'Coordination';
    }
  }
}

class _ExerciseMetaChip extends StatelessWidget {
  const _ExerciseMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.deepTeal,
        ),
      ),
    );
  }
}
