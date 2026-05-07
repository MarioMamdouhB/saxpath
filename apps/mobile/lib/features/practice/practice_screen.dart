import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../results/results_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التمرين')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'تمرين G G A A',
            subtitle: 'G G A A',
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BPM'),
                      SizedBox(height: 6),
                      Text(
                        '60',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Timer'),
                      SizedBox(height: 6),
                      Text(
                        '02:00',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Text('Metronome Placeholder'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('استمع'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('سجل'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'إنهاء التمرين',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResultsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}





