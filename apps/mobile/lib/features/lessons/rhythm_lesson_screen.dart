import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../practice/practice_screen.dart';

class RhythmLessonScreen extends StatelessWidget {
  const RhythmLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درس الإيقاع')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Quarter Note / نوار',
            subtitle: 'النوار يساوي عدة واحدة',
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  '♩',
                  style: TextStyle(fontSize: 72, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Center(
              child: Text(
                '1',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'التالي',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PracticeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}





