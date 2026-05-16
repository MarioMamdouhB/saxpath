import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/models/skill_mastery.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/jazz_academy_screen.dart';
import 'package:saxpath_mobile/features/academy/mvp_curriculum_screen.dart';
import 'package:saxpath_mobile/features/home/home_screen.dart';
import 'package:saxpath_mobile/features/home/practice_setup_screen.dart';
import 'package:saxpath_mobile/features/progress/progress_screen.dart';
import 'package:saxpath_mobile/shared/education/curriculum_service.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/saxpath_brand_mark.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class V2CourseShellScreen extends StatefulWidget {
  const V2CourseShellScreen({
    super.key,
    required this.apiClient,
    this.curriculumService = const CurriculumService(),
  });

  final SaxPathApiClient apiClient;
  final CurriculumService curriculumService;

  @override
  State<V2CourseShellScreen> createState() => _V2CourseShellScreenState();
}

class _V2CourseShellScreenState extends State<V2CourseShellScreen> {
  static const _selectedTrackKey = 'v2.selected_track';
  static const _nameKey = 'profile.display_name';
  static const _experienceKey = 'profile.experience';

  bool _isLoading = true;
  String? _selectedTrack;
  String _displayName = 'المتعلم';
  String _experience = 'beginner';
  late Future<_V2DashboardSnapshot> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedTrack = preferences.getString(_selectedTrackKey);
      _displayName = preferences.getString(_nameKey) ?? 'المتعلم';
      _experience = preferences.getString(_experienceKey) ?? 'beginner';
      _isLoading = false;
    });
  }

  Future<void> _saveTrack(String trackId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedTrackKey, trackId);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedTrack = trackId;
    });
  }

  Future<void> _openTrack({
    required String trackId,
    required WidgetBuilder builder,
  }) async {
    await _saveTrack(trackId);
    if (!mounted) {
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: builder));
  }

  Future<_V2DashboardSnapshot> _loadDashboard() async {
    try {
      final session = await widget.apiClient.getTodayPracticeSession();
      final mastery = await widget.apiClient.getSkillMastery();
      return _V2DashboardSnapshot(session: session, mastery: mastery);
    } catch (_) {
      return const _V2DashboardSnapshot();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendedTrack = _recommendedTrackId();

    return Scaffold(
      appBar: AppBar(
        title: const SaxPathBrandMark(compact: true),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PracticeSetupScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_rounded),
          ),
          IconButton(
            tooltip: 'التقدم',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProgressScreen(apiClient: widget.apiClient),
                ),
              );
            },
            icon: const Icon(Icons.insights_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionTitle(
                  title: 'SaxPath V2',
                  subtitle:
                      'ابدأ من مسار واضح من أول ثانية. الواجهة هنا مبنية لتقليل الحيرة وجعل التدريب أقرب إلى product course حقيقي.',
                ),
                const SizedBox(height: 16),
                SaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً، $_displayName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المستوى الحالي: ${_experienceLabel(_experience)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'المسار المختار: ${_selectedTrackLabel(_selectedTrack)}',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedTrack == null
                            ? 'اختَر أول course يناسبك، ثم سنستخدم هذا الاختيار لتوضيح بداية رحلتك في v2.'
                            : 'تم حفظ هذا الاختيار كتوجّه أساسي لنسخة v2، ويمكنك تغييره في أي وقت.',
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          PrimaryButton(
                            label: _selectedTrack == null
                                ? 'Start Recommended Path'
                                : 'Resume Selected Path',
                            onPressed: () => _openTrackById(
                              _selectedTrack ?? recommendedTrack,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _openTrackById(recommendedTrack),
                            child: Text(
                              'Recommended: ${_selectedTrackLabel(recommendedTrack)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<_V2DashboardSnapshot>(
                  future: _dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SaxCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preparing Today\'s Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 10),
                            LinearProgressIndicator(),
                          ],
                        ),
                      );
                    }

                    final dashboard = snapshot.data;
                    if (dashboard == null || dashboard.session == null) {
                      return const SizedBox.shrink();
                    }

                    final session = dashboard.session!;
                    final mastery = dashboard.mastery;

                    return Column(
                      children: [
                        SaxCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today\'s Guided Session',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Day ${session.dayNumber} • ${session.totalMinutes} min',
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.stageTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(session.stageSubtitleAr),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value:
                                          session.stageProgressPercent / 100,
                                      minHeight: 8,
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(session.guidedPathLabel),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(session.recommendedFocusAr),
                              if (session.adaptationReasonAr != null) ...[
                                const SizedBox(height: 6),
                                Text(session.adaptationReasonAr!),
                              ],
                              if (session.weakSkill != null) ...[
                                const SizedBox(height: 6),
                                Text('Weak skill: ${session.weakSkill}'),
                              ],
                              const SizedBox(height: 12),
                              for (final block in session.blocks) ...[
                                _SessionBlockTile(block: block),
                                if (block != session.blocks.last)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1),
                                  ),
                              ],
                              const SizedBox(height: 14),
                              PrimaryButton(
                                label: 'Start Beginner Course',
                                onPressed: () => _openTrackById('beginner'),
                              ),
                            ],
                          ),
                        ),
                        if (mastery != null) ...[
                          const SizedBox(height: 16),
                          SaxCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mastery Snapshot',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mastery.weakSkill == null
                                      ? 'لا توجد نقطة ضعف محددة بعد.'
                                      : 'Focus now: ${mastery.weakSkill}',
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: mastery.skills
                                      .map(
                                        (entry) => Container(
                                          width: 150,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.focusLabel,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text('${entry.score}%'),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const SectionTitle(
                  title: 'Choose Your Course',
                  subtitle:
                      'ابدأ من Course واضح بدل الدخول إلى صفحات كثيرة من البداية.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _PathCard(
                      title: 'Beginner Course',
                      subtitle:
                          'التأسيس الكامل: الوضعية، النفَس، أول النغمات، والفينجرينج.',
                      icon: Icons.music_note_rounded,
                      selected: _selectedTrack == 'beginner',
                      onTap: () => _openTrack(
                        trackId: 'beginner',
                        builder: (_) => HomeScreen(apiClient: widget.apiClient),
                      ),
                    ),
                    _PathCard(
                      title: 'Experienced Path',
                      subtitle:
                          'الدخول السريع إلى الجاز، المهارات، والتدريب اليومي المتقدم.',
                      icon: Icons.auto_stories_rounded,
                      selected: _selectedTrack == 'experienced',
                      onTap: () => _openTrack(
                        trackId: 'experienced',
                        builder: (_) =>
                            JazzAcademyScreen(apiClient: widget.apiClient),
                      ),
                    ),
                    _PathCard(
                      title: 'Theory Intro',
                      subtitle:
                          'مفاهيم قصيرة ثم دخول مباشر إلى sound, swing, blues, و ii-V-I.',
                      icon: Icons.lightbulb_rounded,
                      selected: _selectedTrack == 'theory_intro',
                      onTap: () => _openTrack(
                        trackId: 'theory_intro',
                        builder: (_) => MvpCurriculumScreen(
                          curriculumService: widget.curriculumService,
                        ),
                      ),
                    ),
                    _PathCard(
                      title: 'Oriental Maqam',
                      subtitle:
                          'تعلم المقامات الشرقية: رصد، بياتي، وحجاز مع ربع التون.',
                      icon: Icons.temple_hindu_rounded,
                      selected: _selectedTrack == 'oriental',
                      onTap: () => _openTrack(
                        trackId: 'oriental',
                        builder: (_) => HomeScreen(apiClient: widget.apiClient),
                      ),
                    ),
                    _PathCard(
                      title: 'Settings',
                      subtitle:
                          'عدل الاسم، المستوى، نوع الساكسفون، وبداية التجربة.',
                      icon: Icons.settings_suggest_rounded,
                      selected: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PracticeSetupScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أثناء بناء v2 بالكامل، ما زالت المسارات الحالية متاحة هنا حتى لا نفقد أي جزء شغال من التطبيق.',
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          PrimaryButton(
                            label: 'Continue Daily Flow',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HomeScreen(apiClient: widget.apiClient),
                                ),
                              );
                            },
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProgressScreen(
                                    apiClient: widget.apiClient,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Open Progress'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _recommendedTrackId() {
    switch (_experience) {
      case 'advanced':
      case 'intermediate':
        return 'experienced';
      default:
        return 'beginner';
    }
  }

  Future<void> _openTrackById(String trackId) async {
    switch (trackId) {
      case 'beginner':
        await _openTrack(
          trackId: trackId,
          builder: (_) => HomeScreen(apiClient: widget.apiClient),
        );
        return;
      case 'experienced':
        await _openTrack(
          trackId: trackId,
          builder: (_) => JazzAcademyScreen(apiClient: widget.apiClient),
        );
        return;
      case 'theory_intro':
        await _openTrack(
          trackId: trackId,
          builder: (_) => MvpCurriculumScreen(
            curriculumService: widget.curriculumService,
          ),
        );
        return;
      case 'oriental':
        await _openTrack(
          trackId: trackId,
          builder: (_) => HomeScreen(apiClient: widget.apiClient),
        );
        return;
      default:
        await _openTrack(
          trackId: 'beginner',
          builder: (_) => HomeScreen(apiClient: widget.apiClient),
        );
        return;
    }
  }

  String _experienceLabel(String experience) {
    switch (experience) {
      case 'advanced':
        return 'متقدم';
      case 'intermediate':
        return 'متوسط';
      default:
        return 'مبتدئ';
    }
  }

  String _selectedTrackLabel(String? trackId) {
    switch (trackId) {
      case 'beginner':
        return 'Beginner Course';
      case 'experienced':
        return 'Experienced Path';
      case 'theory_intro':
        return 'Theory Intro';
      case 'oriental':
        return 'Oriental Maqam';
      default:
        return 'لم يتم الاختيار بعد';
    }
  }
}

class _V2DashboardSnapshot {
  const _V2DashboardSnapshot({
    this.session,
    this.mastery,
  });

  final PracticeSession? session;
  final SkillMasterySnapshot? mastery;
}

class _SessionBlockTile extends StatelessWidget {
  const _SessionBlockTile({
    required this.block,
  });

  final PracticeBlock block;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            '${block.durationMinutes}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(block.focusHintAr),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InlineTag(label: '${block.loopTarget} loops'),
                  if (block.supportsWaitMode)
                    const _InlineTag(label: 'Wait Mode'),
                  for (final note in block.visualFocusNotes)
                    _InlineTag(label: note),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
