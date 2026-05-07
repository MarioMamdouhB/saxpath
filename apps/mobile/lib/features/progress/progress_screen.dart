import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقدم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: 'ملخص التقدم',
            subtitle: 'عرض مبسط لحالة المتعلم الحالية',
          ),
          SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completed days: 0'),
                SizedBox(height: 8),
                Text('Current day: 1'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






