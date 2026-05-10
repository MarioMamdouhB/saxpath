import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/learner_progress.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/jazz_daily_practice_generator_screen.dart';
import 'package:saxpath_mobile/features/academy/jazz_pillar_detail_screen.dart';
import 'package:saxpath_mobile/features/academy/mvp_curriculum_screen.dart';
import 'package:saxpath_mobile/features/foundation/sax_foundation_screen.dart';
import 'package:saxpath_mobile/shared/education/services/curriculum_service.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_models.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_repository.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class JazzAcademyScreen extends StatelessWidget {
  const JazzAcademyScreen({
    super.key,
    required this.apiClient,
    JazzCurriculumRepository? repository,
    CurriculumService? curriculumService,
  })  : repository = repository ?? const JazzCurriculumRepository(),
        curriculumService = curriculumService ?? const CurriculumService();

  final SaxPathApiClient apiClient;
  final JazzCurriculumRepository repository;
  final CurriculumService curriculumService;

  @override
  Widget build(BuildContext context) {
    final pillars = repository.getPillars();

    return Scaffold(
      appBar: AppBar(title: const Text('Jazz Education System')),
      body: FutureBuilder<_AcademyContext>(
        future: _loadContext(),
        builder: (context, snapshot) {
          final academyContext = snapshot.data;
          final skillTree = academyContext == null
              ? null
              : repository.buildSkillTree(
                  progress: academyContext.progress,
                  latestAttempt: academyContext.latestAttempt,
                );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                title: 'Learn',
                subtitle:
                    'ابدأ من مسار واضح، ثم ادخل لاحقًا إلى التفاصيل المتقدمة فقط عندما تحتاجها.',
              ),
              const SizedBox(height: 16),
              const SaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Here',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'المنطق التعليمي هنا مبني على Listen → Understand → Sing → Play → Improvise → Record → Evaluate → Repeat.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ابدأ من واحد من هذه المسارات الثلاثة: Foundation، منهج 30 يوم، أو Daily Practice Generator.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Primary Paths',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    _AcademyEntryTile(
                      title: 'Sax Foundation',
                      subtitle:
                          'ابدأ بالتأسيس: الوضعية، الفينجرينج، أول النغمات، والسلالم الأولى.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SaxFoundationScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _AcademyEntryTile(
                      title: '30-Day MVP Curriculum',
                      subtitle:
                          'منهج الشهر الأول: sound, swing, blues, guide tones, ii-V-I, first chorus solo.',
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
                    const SizedBox(height: 10),
                    _AcademyEntryTile(
                      title: 'Daily Practice Generator',
                      subtitle:
                          'خطة يومية متكيفة مع المستوى، الضعف الحالي، ونوع الساكسفون.',
                      onTap: academyContext == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      JazzDailyPracticeGeneratorScreen(
                                    repository: repository,
                                    progress: academyContext.progress,
                                    latestAttempt: academyContext.latestAttempt,
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
              if (academyContext != null) ...[
                const SizedBox(height: 16),
                SaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Snapshot',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اليوم الحالي: ${academyContext.progress.currentDayNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'آخر محاولة: ${academyContext.latestAttempt == null ? 'لا توجد بعد' : 'اليوم ${academyContext.latestAttempt!.dayNumber} - ${academyContext.latestAttempt!.completion}%'}',
                      ),
                    ],
                  ),
                ),
              ],
              if (skillTree != null) ...[
                const SizedBox(height: 16),
                _SkillTreeCard(snapshot: skillTree),
              ],
              const SizedBox(height: 16),
              SaxCard(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 12),
                  title: const Text(
                    'Browse Educational Pillars',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${pillars.length} pillars covering sound, rhythm, blues, improvisation, transcription, and more.',
                  ),
                  children: [
                    const Text(
                      'كل الأمثلة والتمارين هنا أصلية ومكتوبة للتطبيق، وليست نسخًا من lead sheets أو melodies أو etudes أو solos محمية بحقوق نشر.',
                    ),
                    const SizedBox(height: 12),
                    for (final pillar in pillars) ...[
                      _PillarCard(
                        pillar: pillar,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  JazzPillarDetailScreen(pillar: pillar),
                            ),
                          );
                        },
                      ),
                      if (pillar != pillars.last) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryButton(
                      label: 'Library / Reference Soon',
                      onPressed: null,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'المحتوى المرجعي المتقدم ما زال محتاج مرحلة تنظيم مستقلة بدل رصّه مع بداية التعلم.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_AcademyContext> _loadContext() async {
    final progress = await apiClient.getLearnerProgress();
    AttemptHistoryEntry? latestAttempt;
    try {
      final history = await apiClient.getAttemptHistory(limit: 1);
      latestAttempt = history.isEmpty ? null : history.first;
    } catch (_) {
      latestAttempt = null;
    }
    return _AcademyContext(progress: progress, latestAttempt: latestAttempt);
  }
}

class _AcademyEntryTile extends StatelessWidget {
  const _AcademyEntryTile({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _SkillTreeCard extends StatelessWidget {
  const _SkillTreeCard({
    required this.snapshot,
  });

  final SkillTreeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Tree',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Level: ${difficultyLevelLabel(snapshot.currentLevel)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Progress: ${snapshot.masteredNodes}/${snapshot.totalNodes} mastered · ${snapshot.overallProgressPercent}%',
          ),
          const SizedBox(height: 14),
          for (final level in snapshot.levels) ...[
            _SkillTreeLevelSection(level: level),
            if (level != snapshot.levels.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SkillTreeLevelSection extends StatelessWidget {
  const _SkillTreeLevelSection({
    required this.level,
  });

  final SkillTreeLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  level.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusPill(
                label: level.unlocked ? 'Unlocked' : 'Locked',
                status: level.unlocked
                    ? SkillTreeNodeStatus.available
                    : SkillTreeNodeStatus.locked,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(level.summary),
          const SizedBox(height: 8),
          Text(
            'Mastered: ${level.masteredCount}/${level.nodes.length} · ${level.progressPercent}%',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final node in level.nodes) _SkillTreeNodeChip(node: node),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillTreeNodeChip extends StatelessWidget {
  const _SkillTreeNodeChip({
    required this.node,
  });

  final SkillTreeNode node;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _statusColor(context, node.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            node.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${skillTreeNodeStatusLabel(node.status)} · ${node.progressPercent}%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, SkillTreeNodeStatus status) {
    switch (status) {
      case SkillTreeNodeStatus.locked:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      case SkillTreeNodeStatus.available:
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.10);
      case SkillTreeNodeStatus.inProgress:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16);
      case SkillTreeNodeStatus.mastered:
        return Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.18);
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.status,
  });

  final String label;
  final SkillTreeNodeStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SkillTreeNodeStatus.locked =>
        Theme.of(context).colorScheme.surfaceContainerHighest,
      SkillTreeNodeStatus.available =>
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
      SkillTreeNodeStatus.inProgress =>
        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
      SkillTreeNodeStatus.mastered =>
        Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.18),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AcademyContext {
  const _AcademyContext({
    required this.progress,
    required this.latestAttempt,
  });

  final LearnerProgress progress;
  final AttemptHistoryEntry? latestAttempt;
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.pillar,
    required this.onTap,
  });

  final JazzPillarTrack pillar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseCount = pillar.modules.fold<int>(
      0,
      (sum, module) => sum + module.exercises.length,
    );

    return SaxCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pillar.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              pillar.summary,
              style: const TextStyle(height: 1.45),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final source in pillar.sourceInspiration.take(2))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      source,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Modules: ${pillar.modules.length} | Exercises: $exerciseCount',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
