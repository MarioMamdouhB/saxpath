import 'dart:math';
import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/music/sax_reference.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class ScaleLabScreen extends StatefulWidget {
  const ScaleLabScreen({super.key});

  @override
  State<ScaleLabScreen> createState() => _ScaleLabScreenState();
}

class _ScaleLabScreenState extends State<ScaleLabScreen> {
  String _selectedKey = 'C';

  final List<String> _circleKeys = [
    'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'Db', 'Ab', 'Eb', 'Bb', 'F'
  ];

  Map<String, List<String>> get _scaleNotes => {
    'C': ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5'],
    'G': ['G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'F#5', 'G5'],
    'F': ['F4', 'G4', 'A4', 'Bb4', 'C5', 'D5', 'E5', 'F5'],
    // Add others as needed for MVP
  };

  @override
  Widget build(BuildContext context) {
    final notes = _scaleNotes[_selectedKey] ?? _scaleNotes['C']!;

    return Scaffold(
      appBar: AppBar(title: const Text('مختبر السلالم والدائرة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'دائرة الخامسات التفاعلية',
            subtitle: 'اختر مفتاحاً لاستكشاف السلم وعزفه تفاعلياً.',
          ),
          const SizedBox(height: 24),
          _CircleOfFifthsWidget(
            selectedKey: _selectedKey,
            keys: _circleKeys,
            onKeySelected: (key) => setState(() => _selectedKey = key),
          ),
          const SizedBox(height: 32),
          Text(
            'سلم $_selectedKey الكبير (Major Scale)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepTeal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NoteStaffCard(
            title: 'نوتة السلم',
            noteLabel: notes.join(' '),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              children: [
                const Text('هل أنت جاهز للعزف؟', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('سنقوم بتشغيل إيقاع مصاحب (Backing Track) ونراقب دقة عزفك لكل نغمة.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Runner with Scale Pattern
                    },
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text('ابدأ التمرين التفاعلي'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepTeal, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleOfFifthsWidget extends StatelessWidget {
  final String selectedKey;
  final List<String> keys;
  final ValueChanged<String> onKeySelected;

  const _CircleOfFifthsWidget({
    required this.selectedKey,
    required this.keys,
    required this.onKeySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
              color: Colors.white,
            ),
          ),
          // Keys
          for (int i = 0; i < keys.length; i++)
            _buildKeyItem(i),
          // Center Info
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selectedKey, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.deepTeal)),
              const Text('Selected', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyItem(int index) {
    final angle = (index * 30 - 90) * (pi / 180);
    const radius = 120.0;
    final key = keys[index];
    final isSelected = selectedKey == key;

    return Transform.translate(
      offset: Offset(cos(angle) * radius, sin(angle) * radius),
      child: GestureDetector(
        onTap: () => onKeySelected(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.deepTeal : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isSelected ? AppColors.deepTeal : AppColors.border, width: 2),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.deepTeal.withValues(alpha: 0.3), blurRadius: 10)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            key,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.charcoal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
