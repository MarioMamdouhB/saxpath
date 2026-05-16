import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/music/sax_reference.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import 'package:saxpath_mobile/shared/services/settings_scope.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart' show SaxType, SaxTypeLabel;

class SaxAtlasScreen extends StatefulWidget {
  const SaxAtlasScreen({super.key});

  @override
  State<SaxAtlasScreen> createState() => _SaxAtlasScreenState();
}

class _SaxAtlasScreenState extends State<SaxAtlasScreen> {
  String _selectedNoteKey = 'G4';
  String _selectedRange = 'Standard';

  final List<String> _lowRange = ['Bb3', 'B3', 'C4', 'C#4', 'D4', 'Eb4'];
  final List<String> _standardRange = ['E4', 'F4', 'F#4', 'G4', 'Ab4', 'A4', 'Bd4', 'Bb4', 'B4', 'C5', 'C#5'];
  final List<String> _highRange = ['D5', 'Eb5', 'Ed5', 'E5', 'F5', 'F#5', 'G5', 'A5', 'B5', 'C6'];
  final List<String> _altissimoRange = ['D6', 'Eb6', 'E6', 'F6', 'F#6'];

  @override
  Widget build(BuildContext context) {
    final reference = lookupSaxReference(_selectedNoteKey);
    final settings = SettingsScope.of(context);
    final saxType = settings.saxType;

    return Scaffold(
      appBar: AppBar(title: const Text('قاموس النغمات (Sax Atlas)')),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _selectNextNote();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _selectPreviousNote();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionTitle(
              title: 'خريطة الساكسفون الشاملة',
              subtitle: 'تصفح كل النغمات من Bb المنخفضة إلى أعلى F#، مع دعم المقامات الشرقية.',
            ),
            const SizedBox(height: 16),
            _buildRangeSelector(),
            const SizedBox(height: 20),
            _buildNoteGrid(),
            const SizedBox(height: 24),
            _buildInstrumentBadge(saxType),
            const SizedBox(height: 12),
            SaxCard(
              child: Column(
                children: [
                  Text(
                    'نغمة ${reference.token} ($_selectedNoteKey)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SaxFingeringCard(noteLabel: _selectedNoteKey),
                  const SizedBox(height: 12),
                  _buildNoteInstructions(_selectedNoteKey, reference.token, saxType),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectNextNote() {
    final currentList = _getCurrentNoteList();
    final index = currentList.indexOf(_selectedNoteKey);
    if (index < currentList.length - 1) {
      setState(() => _selectedNoteKey = currentList[index + 1]);
    }
  }

  void _selectPreviousNote() {
    final currentList = _getCurrentNoteList();
    final index = currentList.indexOf(_selectedNoteKey);
    if (index > 0) {
      setState(() => _selectedNoteKey = currentList[index - 1]);
    }
  }

  List<String> _getCurrentNoteList() {
    return switch (_selectedRange) {
      'Low' => _lowRange,
      'Standard' => _standardRange,
      'High' => _highRange,
      'Altissimo' => _altissimoRange,
      _ => _standardRange,
    };
  }

  Widget _buildRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final range in ['Low', 'Standard', 'High', 'Altissimo'])
            _RangeTab(
              label: _rangeLabel(range),
              selected: _selectedRange == range,
              onTap: () => setState(() => _selectedRange = range),
            ),
        ],
      ),
    );
  }

  String _rangeLabel(String range) {
    return switch (range) {
      'Low' => 'المنخفضة',
      'Standard' => 'الأساسية',
      'High' => 'الأوكتاف الثاني',
      'Altissimo' => 'العالية (Palm)',
      _ => range,
    };
  }

  Widget _buildNoteGrid() {
    List<String> currentNoteKeys = _getCurrentNoteList();
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: currentNoteKeys.map((key) {
        final reference = lookupSaxReference(key);
        final isSelected = _selectedNoteKey == key;
        return InkWell(
          onTap: () => setState(() => _selectedNoteKey = key),
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.deepTeal : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.deepTeal.withValues(alpha: 0.3), blurRadius: 8)] : [],
            ),
            alignment: Alignment.center,
            child: Text(
              reference.token,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.deepTeal),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteInstructions(String key, String token, SaxType saxType) {
    String instruction = 'استخدم اليد اليسرى واليمنى كما هو موضح في الرسم.';
    if (_lowRange.contains(key)) instruction = 'اضغط بقوة نفس متزنة لضمان عدم اهتزاز النغمة المنخفضة.';
    if (_highRange.contains(key)) instruction = 'تأكد من ضغط مفتاح الأوكتاف (Octave Key) في الخلف.';
    if (_altissimoRange.contains(key)) instruction = 'استخدم مفاتيح الـ Palm Keys الجانبية مع ضغط هواء مركز.';
    if (token.contains('d')) instruction = 'نغمة شرقية (ربع تون). اضبط موضع الإصبع بدقة للحصول على التردد الصحيح.';
    if (saxType == SaxType.tenorBb && _lowRange.contains(key)) instruction += ' (التينور يحتاج دفع هواء أعمق قليلاً)';

    return Text(instruction, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.4));
  }

  Widget _buildInstrumentBadge(SaxType saxType) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.deepTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.2)),
        ),
        child: Text('عرض النغمات لساكسفون: ${saxType.label}', style: const TextStyle(color: AppColors.deepTeal, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RangeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label), selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.deepTeal.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: selected ? AppColors.deepTeal : AppColors.muted, fontWeight: FontWeight.bold),
      ),
    );
  }
}
