import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/tuner/tuner_screen.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/metronome_card.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class PracticeRoomScreen extends StatefulWidget {
  const PracticeRoomScreen({super.key});

  @override
  State<PracticeRoomScreen> createState() => _PracticeRoomScreenState();
}

class _PracticeRoomScreenState extends State<PracticeRoomScreen> {
  static const _tempoSteps = [60, 72, 84, 96, 108, 120];
  static const _keys = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'F#/Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  int _currentBpm = 84;
  String _selectedKey = 'C';
  int _tempoLadderIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('غرفة التدريب')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'غرفة التدريب',
            subtitle:
                'أدوات مباشرة للوقت، السمع، التكرار، والتنقل بين المفاتيح',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  size: 40,
                  color: AppColors.deepTeal,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دوزان الساكسفون (Tuner)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'اضبط نغماتك بدقة قبل البدء.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'افتح',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TunerScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MetronomeCard(
            initialBpm: _currentBpm,
            linkedPlaybackTitle: 'Loop Trainer',
            linkedPlaybackHint:
                'الـ loop والـ rhythm trainers في نفس الصفحة سيستخدمان نفس الـ BPM الموجود هنا حتى تظل التجربة متماسكة.',
            onBpmChanged: (value) {
              setState(() {
                _currentBpm = value;
              });
            },
          ),
          const SizedBox(height: 16),
          MockPlaybackCard(
            title: 'درون',
            caption: 'ثبت مركز النغمة ثم غنّ و العزف فوق drone واحد.',
            accentLabel: 'Concert $_selectedKey',
            pattern: PlaybackPattern.note,
            patternKey: _selectedKey,
            durationSeconds: 12,
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مدرب 12 مفتاح',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اختر المفتاح الحالي ثم راقب كيف يتغير الـ drone والـ loop على نفس السياق.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final key in _keys)
                      ChoiceChip(
                        label: Text(key),
                        selected: _selectedKey == key,
                        onSelected: (_) => setState(() => _selectedKey = key),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MockPlaybackCard(
            title: 'مدرب الجملة',
            caption:
                'استمع للّوب القصير ثم كرره على نفس الـ pulse قبل أن تغيّره.',
            accentLabel: '$_currentBpm BPM',
            pattern: PlaybackPattern.phrase,
            patternKey: _selectedKey,
            durationSeconds: 10,
            bpm: _currentBpm,
            countInBeats: 4,
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سلم السرعات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اصعد بالتيمبو تدريجيًا فقط بعد ثبات الإيقاع والنطق.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _tempoSteps.length; i++)
                      ChoiceChip(
                        label: Text('${_tempoSteps[i]}'),
                        selected: _tempoLadderIndex == i,
                        onSelected: (_) => setState(() {
                          _tempoLadderIndex = i;
                          _currentBpm = _tempoSteps[i];
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'السلم الحالي: ${_tempoSteps[_tempoLadderIndex]} BPM',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MockPlaybackCard(
            title: 'مدرب الإيقاع',
            caption:
                'Clap back ثم one-note playback ثم scale rhythm ثم two-bar improvisation.',
            accentLabel: 'Mode: Swing Grid',
            pattern: PlaybackPattern.rhythm,
            patternKey: 'count_4_4',
            durationSeconds: 12,
            bpm: _currentBpm,
            countInBeats: 4,
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backing Tracks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text('Medium Swing Blues in F'),
                SizedBox(height: 6),
                Text('Jazz Blues in Bb'),
                SizedBox(height: 6),
                Text('Minor Dorian Vamp'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
