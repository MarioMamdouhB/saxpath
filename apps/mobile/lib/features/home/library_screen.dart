import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/jazz_academy_screen.dart';
import 'package:saxpath_mobile/features/academy/mvp_curriculum_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_scale_lessons_screen.dart';
import 'package:saxpath_mobile/features/foundation/sax_foundation_screen.dart';
import 'package:saxpath_mobile/features/home/practice_room_screen.dart';
import 'package:saxpath_mobile/shared/education/curriculum_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
    required this.apiClient,
    SaxFoundationRepository? foundationRepository,
    CurriculumService? curriculumService,
  })  : foundationRepository =
            foundationRepository ?? const SaxFoundationRepository(),
        curriculumService = curriculumService ?? const CurriculumService();

  final SaxPathApiClient apiClient;
  final SaxFoundationRepository foundationRepository;
  final CurriculumService curriculumService;

  @override
  Widget build(BuildContext context) {
    final practicalTracks = [
      _TrackData(
        title: 'النغمة والصوت من البداية',
        subtitle:
            'وضع اليد، أول نغمة، الفينجرينج، وتثبيت الصوت قبل أي سرعة أو نظري.',
        bullets: const [
          'Long tones',
          'First notes',
          'Finger placement',
        ],
        actionLabel: 'افتح Foundation',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SaxFoundationScreen(),
            ),
          );
        },
      ),
      _TrackData(
        title: 'Scales + Phrase + Speed',
        subtitle:
            'ابدأ بالسلالم الأساسية، ثم حوّلها إلى phrases صغيرة، وبعدها ارفع السرعة تدريجيًا.',
        bullets: const [
          'Major scales',
          'Pentatonic',
          'Blues scale',
        ],
        actionLabel: 'افتح دروس السلالم',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FoundationScaleLessonsScreen(
                repository: foundationRepository,
              ),
            ),
          );
        },
      ),
      _TrackData(
        title: 'Rhythm + Tempo + Recording',
        subtitle:
            'عدّ، صفّق، عزف على نغمة واحدة، ثم تسجيل وتحليل بدل الحفظ النظري.',
        bullets: const [
          'Metronome work',
          'Tempo ladders',
          'Record and retry',
        ],
        actionLabel: 'افتح غرفة التدريب',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PracticeRoomScreen(),
            ),
          );
        },
      ),
      _TrackData(
        title: 'Blues + Jazz Language + Styles',
        subtitle:
            'بلوز، swing، guide tones، ii-V-I، وأمثلة كثيرة تبني لغة عزف حقيقية.',
        bullets: const [
          'Blues language',
          'Guide tones',
          'ii-V-I practice',
        ],
        actionLabel: 'افتح أكاديمية الجاز',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JazzAcademyScreen(apiClient: apiClient),
            ),
          );
        },
      ),
      _TrackData(
        title: 'مسار الشهر الأول الجاد',
        subtitle:
            'خطة أوسع تنقلك من tone وtime إلى البلوز، الجمل، التسجيل، وأول solo كامل.',
        bullets: const [
          '30-day structure',
          'Backing tracks',
          'Capstone review',
        ],
        actionLabel: 'افتح منهج 30 يوم',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MvpCurriculumScreen(
                curriculumService: curriculumService,
              ),
            ),
          );
        },
      ),
    ];

    const referenceSections = [
      _ReferenceSection(
        title: 'كتب الطريقة',
        subtitle:
            'هذه ليست مواد تُعرض للمستخدم في الدرس نفسه، بل جذور فكرية لمن يريد التعمّق.',
        entries: [
          _ReferenceEntry(
            title: 'Paul DeVille · Universal Method for Saxophone',
            body:
                'نحوّل فكرته إلى long tones، نغمات متجاورة، وتدرج بطيء ثم تحكم ثم تحدي.',
          ),
          _ReferenceEntry(
            title: 'Method-book tradition',
            body:
                'بدل عرض صفحات نظرية، نترجمها إلى drill صغير قابل للتكرار مع metronome وتسجيل.',
          ),
        ],
      ),
      _ReferenceSection(
        title: 'مناهج الأداء والمؤسسات',
        subtitle:
            'البرنامج يستلهم تسلسل التدرج من مناهج الساكسفون والأداء، لكن التطبيق يبني تمارينه بشكل عملي أصلي.',
        entries: [
          _ReferenceEntry(
            title: 'Eastman / Berklee / UNT',
            body:
                'نأخذ منهم فكرة التدرج: sound أولًا، ثم rhythm، ثم phrase، ثم recording checkpoints.',
          ),
          _ReferenceEntry(
            title: 'Studio-handbook mindset',
            body:
                'كل فكرة يجب أن تنتهي بعزف مسموع، لا بمجرد فهم نظري أو قراءة.',
          ),
        ],
      ),
      _ReferenceSection(
        title: 'كيف يستخدم SaxPath المراجع',
        subtitle:
            'هذا هو الجزء الأهم: المرجع لا يظهر كزحمة، بل يتحول إلى سلوك تدريبي داخل التطبيق.',
        entries: [
          _ReferenceEntry(
            title: 'Listen → Sing → Play → Record → Retry',
            body:
                'هذه الحلقة هي الترجمة العملية للنظري، وهي ما يتكرر داخل الدروس الأساسية.',
          ),
          _ReferenceEntry(
            title: 'Tempo ladders بدل الشرح الكثير',
            body:
                'أي skill جديدة يجب أن تبدأ أبطأ، تثبت، ثم ترتفع سرعتها تدريجيًا حتى تصبح قابلة للاستخدام.',
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المكتبة والمراجع')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                title: 'مركز التوسّع',
                subtitle:
                    'هذه الشاشة اختيارية. المسار الرئيسي يظل في جلسة اليوم، أما هنا فستجد المسارات العملية الأوسع وخزنة المراجع لمن يريدها فقط.',
              ),
              const SizedBox(height: 16),
              const SaxCard(
                child: Text(
                  'جوهر البرنامج هنا ليس “اقرأ عن الموسيقى”، بل: اسمع، قلّد، اضبط التيمبو، عزف الجملة، سجّلها، ثم صحّحها. المراجع موجودة أسفل الصفحة فقط لمن يريد فهم الخلفية.',
                ),
              ),
              const SizedBox(height: 16),
              const SectionTitle(
                title: 'مسارات عملية',
                subtitle:
                    'ابدأ من الهدف الذي تريد بناءه: sound، scales، rhythm، jazz language، أو خطة شهر كامل.',
              ),
              const SizedBox(height: 12),
              for (final track in practicalTracks) ...[
                _TrackCard(track: track),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              const SectionTitle(
                title: 'خزنة المراجع',
                subtitle:
                    'هذه المساحة ليست جزءًا من واجهة الدرس اليومية. افتحها فقط لو أردت معرفة من أين جاءت فلسفة التمرين.',
              ),
              const SizedBox(height: 12),
              for (final section in referenceSections) ...[
                _ReferenceCard(section: section),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
  });

  final _TrackData track;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            track.subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final bullet in track.bullets)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.softMint,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepTeal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: track.actionLabel,
            onPressed: track.onTap,
          ),
        ],
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({
    required this.section,
  });

  final _ReferenceSection section;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              section.subtitle,
              style: const TextStyle(
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ),
          children: [
            const SizedBox(height: 10),
            for (var index = 0; index < section.entries.length; index++) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.entries[index].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(section.entries[index].body),
                  ],
                ),
              ),
              if (index < section.entries.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackData {
  const _TrackData({
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;
  final String actionLabel;
  final VoidCallback onTap;
}

class _ReferenceSection {
  const _ReferenceSection({
    required this.title,
    required this.subtitle,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final List<_ReferenceEntry> entries;
}

class _ReferenceEntry {
  const _ReferenceEntry({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
