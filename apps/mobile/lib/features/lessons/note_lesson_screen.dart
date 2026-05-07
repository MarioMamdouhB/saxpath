import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import 'rhythm_lesson_screen.dart';

class NoteLessonScreen extends StatelessWidget {
  const NoteLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درس النغمة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'نغمة G / صول',
            subtitle: 'تعلم مكان النغمة وشكلها قبل العزف.',
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: SizedBox(
              height: 180,
              child: Center(child: Text('Staff Placeholder')),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'تعلم مكان نغمة G على المدرج واسمع صوتها قبل العزف.',
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            child: const Text('استمع للنغمة'),
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: SizedBox(
              height: 140,
              child: Center(child: Text('Fingering Placeholder')),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'التالي',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RhythmLessonScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}




