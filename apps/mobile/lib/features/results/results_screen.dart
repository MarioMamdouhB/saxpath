import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../home/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'ملخص المحاولة',
            subtitle: 'نتيجة تجريبية للمرحلة الحالية',
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Row(
              children: [
                Expanded(child: _Metric(label: 'Pitch', value: '78%')),
                Expanded(child: _Metric(label: 'Rhythm', value: '64%')),
                Expanded(child: _Metric(label: 'Completion', value: '100%')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Text(
              'أداء جيد. النغمات قريبة، لكن حاول تثبيت التوقيت مع الميترونوم.',
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'العودة إلى الخطة',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}





