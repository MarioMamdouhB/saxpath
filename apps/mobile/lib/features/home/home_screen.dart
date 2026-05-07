import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../lessons/note_lesson_screen.dart';
import '../progress/progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> _tasks = [
    {
      'title': 'نغمة G / صول',
      'duration': 5,
      'status': 'next',
    },
    {
      'title': 'Quarter Note / نوار',
      'duration': 7,
      'status': 'locked',
    },
    {
      'title': 'تمرين G G A A',
      'duration': 10,
      'status': 'locked',
    },
    {
      'title': 'تسجيل المحاولة',
      'duration': 3,
      'status': 'locked',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaxPath'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
            icon: const Icon(Icons.insights_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'مرحباً، أحمد',
            subtitle: 'خطة اليوم لتعلم الساكسفون',
          ),
          const SizedBox(height: 20),
          const SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقدم اليومي',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  '0%',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'خطة اليوم',
            subtitle: '4 خطوات بسيطة وواضحة',
          ),
          const SizedBox(height: 12),
          SaxCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < _tasks.length; i++) ...[
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(
                      _tasks[i]['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${_tasks[i]['duration']} دقائق - ${_tasks[i]['status']}',
                    ),
                  ),
                  if (i < _tasks.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'ابدأ تمرين اليوم',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NoteLessonScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}




