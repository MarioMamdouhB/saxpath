import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/features/practice/widgets/mock_recording_card.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/widgets/metronome_card.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationExercisePlayerScreen extends StatefulWidget {
  const FoundationExercisePlayerScreen({
    super.key,
    required this.exercise,
    this.note,
    this.scale,
  });

  final FoundationPracticeExercise exercise;
  final FoundationNoteModel? note;
  final FoundationScaleLesson? scale;

  @override
  State<FoundationExercisePlayerScreen> createState() =>
      _FoundationExercisePlayerScreenState();
}

class _FoundationExercisePlayerScreenState
    extends State<FoundationExercisePlayerScreen> {
  late int _currentBpm;
  final Set<int> _checkedIndexes = <int>{};
  MockRecording? _recording;

  @override
  void initState() {
    super.initState();
    _currentBpm = widget.exercise.recommendedBpm;
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel =
        widget.note?.label ?? widget.scale?.noteSequence.join(' ');
    final subtitle = widget.note != null
        ? 'تمرين عملي على النغمة ${widget.note!.label}'
        : widget.scale != null
            ? 'تمرين عملي على ${widget.scale!.title}'
            : 'تمرين تأسيسي عملي';

    return Scaffold(
      appBar: AppBar(title: const Text('تمرين تأسيسي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: widget.exercise.title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.exercise.summary,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepTeal,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '${widget.exercise.durationMinutes} د',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.exercise.instructions,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (displayLabel != null) ...[
            const SizedBox(height: 16),
            NoteStaffCard(
              noteLabel: displayLabel,
              title: widget.note != null ? 'موقع النغمة' : 'خريطة السلم',
            ),
            const SizedBox(height: 16),
            SaxFingeringCard(
              noteLabel: displayLabel,
              title: widget.note != null ? 'مرجع الفينجرينج' : 'خريطة الفينجرينج',
            ),
          ],
          if (widget.note != null) ...[
            const SizedBox(height: 16),
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نقاط التركيز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.note!.fingering.handPositionTip),
                  const SizedBox(height: 6),
                  Text(widget.note!.fingering.embouchureTip),
                  const SizedBox(height: 6),
                  Text(widget.note!.fingering.airflowTip),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          MetronomeCard(
            initialBpm: _currentBpm,
            linkedPlaybackTitle: widget.exercise.title,
            linkedPlaybackHint:
                'اضبط النبض هنا أولًا. النموذج الصوتي أسفل هذه البطاقة سيبدأ بعد 4 عدات ميترونوم وعلى نفس الـ BPM الذي تختاره الآن.',
            onBpmChanged: (value) {
              setState(() {
                _currentBpm = value;
              });
            },
          ),
          const SizedBox(height: 16),
          MockPlaybackCard(
            title: 'استمع أولاً',
            caption:
                'اسمع النموذج ثم أعده على نفس الـ pulse. غيّر الـ BPM فقط عندما يثبت الصوت والحركة معًا.',
            accentLabel:
                displayLabel ?? '${widget.exercise.recommendedBpm} BPM',
            pattern: widget.exercise.playbackPattern,
            patternKey: widget.exercise.playbackKey,
            durationSeconds: widget.exercise.durationMinutes * 3,
            bpm: _currentBpm,
            countInBeats: 4,
            countInLabel:
                'قبل النموذج ستسمع 4 عدات ميترونوم بنفس السرعة التي اخترتها فوق حتى يكون الدخول أوضح.',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قائمة التمرين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                for (var index = 0;
                    index < widget.exercise.checkpoints.length;
                    index++)
                  CheckboxListTile(
                    value: _checkedIndexes.contains(index),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.deepTeal,
                    onChanged: (_) {
                      setState(() {
                        if (_checkedIndexes.contains(index)) {
                          _checkedIndexes.remove(index);
                        } else {
                          _checkedIndexes.add(index);
                        }
                      });
                    },
                    title: Text(widget.exercise.checkpoints[index]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MockRecordingCard(
            exerciseId: widget.exercise.id,
            dayNumber: 1,
            onChanged: (recording) {
              setState(() {
                _recording = recording;
              });
            },
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Text(
              _recording == null
                  ? 'يمكنك إنهاء التمرين بدون تسجيل، لكن تسجيل محاولة قصيرة هنا يعطيك نقطة مراجعة واضحة قبل الانتقال للجاز لاحقًا.'
                  : 'تم تجهيز تسجيل لهذه المحاولة. استمع إليه مرة واحدة واسأل نفسك: هل الوقت ثابت؟ وهل اللون الصوتي متساوٍ؟',
            ),
          ),
        ],
      ),
    );
  }
}
