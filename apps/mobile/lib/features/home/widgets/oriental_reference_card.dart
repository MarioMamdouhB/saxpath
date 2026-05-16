import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class OrientalReferenceCard extends StatelessWidget {
  const OrientalReferenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرجع المقامات الشرقية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'تعلم كيفية ضبط نغمات ربع التون (نصف بيمول) في المقامات العربية الأساسية.',
            style: TextStyle(color: AppColors.muted),
          ),
          SizedBox(height: 16),
          _MaqamRow(
            name: 'مقام الراست',
            notes: 'C D Ed F G A Bd c',
            description: 'الركوز على درجة دو (C)، ونغمة السيكا (Ed) والأوج (Bd).',
          ),
          Divider(height: 24),
          _MaqamRow(
            name: 'مقام البياتي',
            notes: 'D Ed F G A Bb C d',
            description: 'الركوز على درجة ري (D)، ونغمة السيكا (Ed).',
          ),
          Divider(height: 24),
          _MaqamRow(
            name: 'مقام السيكا',
            notes: 'Ed F G A Bd C D ed',
            description: 'الركوز على نغمة السيكا (Ed) مباشرة.',
          ),
        ],
      ),
    );
  }
}

class _MaqamRow extends StatelessWidget {
  const _MaqamRow({
    required this.name,
    required this.notes,
    required this.description,
  });

  final String name;
  final String notes;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.deepTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'شرقي',
                style: TextStyle(color: AppColors.deepTeal, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          notes,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 18,
            letterSpacing: 2,
            color: AppColors.deepTeal,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
      ],
    );
  }
}
