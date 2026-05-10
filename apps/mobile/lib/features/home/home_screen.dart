import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/analytics_event.dart';
import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/jazz_academy_screen.dart';
import 'package:saxpath_mobile/features/foundation/sax_foundation_screen.dart';
import 'package:saxpath_mobile/features/home/library_screen.dart';
import 'package:saxpath_mobile/features/home/practice_room_screen.dart';
import 'package:saxpath_mobile/features/home/practice_setup_screen.dart';
import 'package:saxpath_mobile/features/home/record_feedback_screen.dart';
import 'package:saxpath_mobile/features/progress/attempt_details_screen.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/shared/education/curriculum_service.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_repository.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/saxpath_brand_mark.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

import '../academy/mvp_curriculum_screen.dart';
import '../lessons/note_lesson_screen.dart';
import '../progress/progress_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    SaxPathApiClient? apiClient,
    this.dayNumber = 1,
  }) : apiClient = apiClient ?? SaxPathApiClient();

  final SaxPathApiClient apiClient;
  final int dayNumber;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _onboardingDismissedKey = 'home_onboarding_dismissed';

  final JazzCurriculumRepository _curriculumRepository =
      const JazzCurriculumRepository();
  final CurriculumService _curriculumService = const CurriculumService();
  final ScrollController _scrollController = ScrollController();
  late Future<DailyPlan> _dailyPlanFuture;
  late Future<List<Lesson>> _lessonsFuture;
  late Future<_HomeInsights> _homeInsightsFuture;
  int? _loadedDayNumber;
  bool _showOnboardingCard = false;

  @override
  void initState() {
    super.initState();
    _scheduleScrollReset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensurePreferredDayLoaded();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDataForDay(int dayNumber) {
    _loadedDayNumber = dayNumber;
    _dailyPlanFuture = widget.apiClient.getDailyPlan(dayNumber);
    _lessonsFuture = widget.apiClient.getLessons(dayNumber: dayNumber);
    _homeInsightsFuture = _loadInsights();
  }

  void _ensurePreferredDayLoaded() {
    final progressController = AppProgressScope.of(context);
    final preferredDayNumber = _preferredHomeDay(progressController);
    if (_loadedDayNumber == preferredDayNumber) {
      return;
    }

    _loadDataForDay(preferredDayNumber);
    _loadOnboardingState(preferredDayNumber);
    _scheduleScrollReset();
  }

  Future<_HomeInsights> _loadInsights() async {
    try {
      final latestAttempts = await widget.apiClient.getAttemptHistory(limit: 1);
      final latestEvents = await widget.apiClient.getAnalyticsEvents(limit: 1);

      return _HomeInsights(
        latestAttempt: latestAttempts.isEmpty ? null : latestAttempts.first,
        latestEvent: latestEvents.isEmpty ? null : latestEvents.first,
      );
    } catch (_) {
      return const _HomeInsights();
    }
  }

  int _preferredHomeDay(AppProgressController progressController) {
    if (progressController.isDayUnlocked(widget.dayNumber) &&
        !progressController.isDayCompleted(widget.dayNumber)) {
      return widget.dayNumber;
    }

    return progressController.currentDayNumber;
  }

  Future<void> _loadOnboardingState(int dayNumber) async {
    final preferences = await SharedPreferences.getInstance();
    final dismissed = preferences.getBool(_onboardingDismissedKey) ?? false;

    if (!mounted) {
      return;
    }

    setState(() {
      _showOnboardingCard = !dismissed && dayNumber == 1;
    });
  }

  Future<void> _dismissOnboardingCard() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingDismissedKey, true);

    if (!mounted) {
      return;
    }

    setState(() {
      _showOnboardingCard = false;
    });
  }

  void _openProgress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgressScreen(apiClient: widget.apiClient),
      ),
    );
  }

  void _openHomeDay(int dayNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          apiClient: widget.apiClient,
          dayNumber: dayNumber,
        ),
      ),
    );
  }

  void _openTodaySession(DailyPlan displayPlan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteLessonScreen(
          apiClient: widget.apiClient,
          dayPlan: displayPlan,
          lessonsFuture: _lessonsFuture,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressController = AppProgressScope.of(context);
    final activeDayNumber = _loadedDayNumber ?? _preferredHomeDay(progressController);
    final requestedDayNumber = widget.dayNumber;
    final showRequestedDayNotice = requestedDayNumber != activeDayNumber;

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
            icon: const Icon(Icons.manage_accounts_rounded),
          ),
          IconButton(
            tooltip: 'التقدم',
            onPressed: _openProgress,
            icon: const Icon(Icons.insights_rounded),
          ),
        ],
      ),
      body: FutureBuilder<DailyPlan>(
        future: _dailyPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _HomeErrorState(
              onRetry: () {
                setState(() {
                  _loadDataForDay(activeDayNumber);
                });
              },
            );
          }

          final plan = snapshot.requireData;
          final displayPlan = _planForProgressState(plan, progressController);
          final isUnlocked = progressController.isDayUnlocked(activeDayNumber);
          final isCompleted =
              progressController.isDayCompleted(activeDayNumber);
          final practiceTask = displayPlan.tasks.firstWhere(
            (task) => task.type == 'practice',
            orElse: () => displayPlan.tasks.first,
          );
          final continueDay = progressController.currentDayNumber;

          return FutureBuilder<_HomeInsights>(
            future: _homeInsightsFuture,
            builder: (context, insightsSnapshot) {
              final insights = insightsSnapshot.data ?? const _HomeInsights();

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      SectionTitle(
                        title: 'مرحباً، ${displayPlan.userName}',
                        subtitle:
                            'ابدأ من جلسة اليوم أولاً. بعد ذلك ستجد بقية الأقسام للمراجعة والدعم عند الحاجة.',
                      ),
                      const SizedBox(height: 20),
                      _TodaySessionCard(
                        dayPlan: displayPlan,
                        practiceTask: practiceTask,
                        continueDay: continueDay,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onStartToday: () => _openTodaySession(displayPlan),
                        onContinue: () => _openHomeDay(continueDay),
                      ),
                      const SizedBox(height: 16),
                      _HomeSyncBanner(
                        syncState: progressController.syncState,
                      ),
                      const SizedBox(height: 16),
                      _HomeProgressSnapshot(
                        currentDayNumber: progressController.currentDayNumber,
                        completedDaysCount:
                            progressController.completedDaysCount,
                        currentStreakDays:
                            progressController.currentStreakDays,
                      ),
                      if (_showOnboardingCard) ...[
                        const SizedBox(height: 16),
                        _OnboardingCard(
                          currentDayNumber: progressController.currentDayNumber,
                          currentStreakDays:
                              progressController.currentStreakDays,
                          onDismiss: _dismissOnboardingCard,
                          onStartToday: () => _openTodaySession(displayPlan),
                          onOpenProgress: _openProgress,
                        ),
                      ],
                      if (showRequestedDayNotice) ...[
                        const SizedBox(height: 16),
                        SaxCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progressController.isDayCompleted(requestedDayNumber)
                                    ? 'اليوم $requestedDayNumber مكتمل بالفعل. سنعرض لك الآن الجلسة المفتوحة الحالية حتى تواصل المسار الأساسي.'
                                    : 'اليوم $requestedDayNumber ما زال مغلقاً. سنعرض لك الآن اليوم المفتوح ${progressController.currentDayNumber} حتى تكمل المسار الصحيح.',
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () => _openHomeDay(
                                  progressController.currentDayNumber,
                                ),
                                child: Text(
                                  'اذهب إلى اليوم المفتوح ${progressController.currentDayNumber}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isCompleted && !showRequestedDayNotice) ...[
                        const SizedBox(height: 16),
                        const SaxCard(
                          child: Text(
                            'تم إكمال هذا اليوم. يمكنك مراجعته مرة أخرى أو متابعة اليوم المفتوح الحالي.',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _DailyFlowCard(
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                      ),
                      const SizedBox(height: 16),
                      _FocusCard(
                        weakness: _weaknessFocus(insights.latestAttempt),
                        listeningAssignment:
                            _listeningAssignment(insights.latestAttempt),
                        latestAttempt: insights.latestAttempt,
                        latestEvent: insights.latestEvent,
                        onOpenLatestAttempt: insights.latestAttempt == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AttemptDetailsScreen(
                                      entry: insights.latestAttempt!,
                                    ),
                                  ),
                                );
                              },
                        onOpenProgress: _openProgress,
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(
                        title: 'مسارات مساعدة',
                        subtitle:
                            'بعد إنهاء جلسة اليوم، استخدم هذه المسارات للمراجعة والتوسّع والتدريب الحر.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _PrimaryNavCard(
                            title: 'التعلّم',
                            subtitle:
                                'التأسيس، أكاديمية الجاز، ومنهج الثلاثين يوم.',
                            icon: Icons.school_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _LearnHubScreen(
                                    apiClient: widget.apiClient,
                                    curriculumRepository:
                                        _curriculumRepository,
                                    curriculumService: _curriculumService,
                                  ),
                                ),
                              );
                            },
                          ),
                          _PrimaryNavCard(
                            title: 'أدوات التدريب',
                            subtitle:
                                'ميترونوم، تدريبات إيقاع، تنقل بين المقامات، ومسارات مساندة.',
                            icon: Icons.tune_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PracticeRoomScreen(),
                                ),
                              );
                            },
                          ),
                          _PrimaryNavCard(
                            title: 'المكتبة',
                            subtitle:
                                'مراجع سريعة، كروت نغمات، ومساحات قراءة تدعم تمرين اليوم.',
                            icon: Icons.library_music_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LibraryScreen(
                                    apiClient: widget.apiClient,
                                  ),
                                ),
                              );
                            },
                          ),
                          _PrimaryNavCard(
                            title: 'التسجيل والتقييم',
                            subtitle:
                                'ادخل مباشرة للتسجيل، المراجعة، والتحليل على مادة اليوم.',
                            icon: Icons.mic_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecordFeedbackScreen(
                                    apiClient: widget.apiClient,
                                    dayPlan: displayPlan,
                                    lessonsFuture: _lessonsFuture,
                                  ),
                                ),
                              );
                            },
                          ),
                          _PrimaryNavCard(
                            title: 'التقدم',
                            subtitle:
                                'الأيام المفتوحة، النتائج السابقة، والمؤشرات الأساسية.',
                            icon: Icons.insights_rounded,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProgressScreen(
                                    apiClient: widget.apiClient,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _weaknessFocus(AttemptHistoryEntry? attempt) {
    if (attempt == null) {
      return 'ابدأ بمحاولة واحدة لنحدد بدقة هل الأولوية للوقت أو النغمة أو النطق.';
    }

    if (attempt.rhythmAccuracy <= attempt.pitchAccuracy &&
        attempt.rhythmAccuracy < 75) {
      return 'التركيز الآن على التوقيت والـ swing placement قبل زيادة السرعة.';
    }

    if (attempt.pitchAccuracy < 80) {
      return 'التركيز الآن على ثبات النغمة والـ intonation مع drone بطيء.';
    }

    return 'التركيز الآن على بناء phrase أوضح مع space وarticulation أدق.';
  }

  String _listeningAssignment(AttemptHistoryEntry? attempt) {
    if (attempt == null) {
      return 'اسمع phrase قصيرة 1-2 بار، ثم غنّها قبل أول عزف.';
    }

    if (attempt.dayNumber <= 2) {
      return 'اسمع pulse واضح وركز على quarter-note feel مع clap back.';
    }

    if (attempt.rhythmAccuracy < 75) {
      return 'اسمع off-beat eighths مع metronome على 2 و4 ثم قلّد placement.';
    }

    return 'اسمع جملة بلوز قصيرة وحدد أين تنتهي العبارة وكيف تُحل.';
  }

  DailyPlan _planForProgressState(
    DailyPlan plan,
    AppProgressController progressController,
  ) {
    if (progressController.isDayCompleted(plan.dayNumber)) {
      return plan.copyWith(
        progressPercent: 100,
        tasks: plan.tasks.map((task) => task.copyWith(status: 'done')).toList(),
      );
    }

    if (!progressController.isDayUnlocked(plan.dayNumber)) {
      return plan.copyWith(
        progressPercent: 0,
        tasks:
            plan.tasks.map((task) => task.copyWith(status: 'locked')).toList(),
      );
    }

    return plan.copyWith(
      progressPercent: progressController.progressPercentForDay(plan.dayNumber),
    );
  }

  void _scheduleScrollReset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.currentDayNumber,
    required this.currentStreakDays,
    required this.onDismiss,
    required this.onStartToday,
    required this.onOpenProgress,
  });

  final int currentDayNumber;
  final int currentStreakDays;
  final Future<void> Function() onDismiss;
  final VoidCallback onStartToday;
  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ابدأ من هنا',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ من جلسة اليوم وسنقودك تلقائياً من درس النغمة إلى الإيقاع ثم التمرين والنتيجة. افتح شاشة التقدم فقط إذا أردت مراجعة محاولاتك السابقة.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: 'اليوم المفتوح',
                value: '$currentDayNumber',
              ),
              _StatusPill(
                label: 'السلسلة الحالية',
                value: '$currentStreakDays يوم',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PrimaryButton(
                label: 'ابدأ جلسة اليوم',
                onPressed: onStartToday,
              ),
              OutlinedButton(
                onPressed: onOpenProgress,
                child: const Text('راجع التقدم'),
              ),
              TextButton(
                onPressed: () async {
                  await onDismiss();
                },
                child: const Text('إخفاء'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeSyncBanner extends StatelessWidget {
  const _HomeSyncBanner({
    required this.syncState,
  });

  final ProgressSyncState syncState;

  @override
  Widget build(BuildContext context) {
    final (title, message, accent) = switch (syncState) {
      ProgressSyncState.syncing => (
          'جارٍ تحديث التقدم',
          'فتحنا التطبيق فوراً، ويتم الآن مزامنة بياناتك مع الخادم في الخلفية.',
          AppColors.deepTeal,
        ),
      ProgressSyncState.failed => (
          'المزامنة متوقفة مؤقتاً',
          'سيستمر التطبيق بآخر بيانات محلية متاحة إلى أن تنجح المزامنة لاحقاً.',
          const Color(0xFFB26A1D),
        ),
      ProgressSyncState.synced => (
          'التقدم محدث',
          'بيانات الجلسات الحالية متزامنة مع الخادم.',
          AppColors.deepTeal,
        ),
      ProgressSyncState.localOnly => (
          'جاهز محلياً',
          'تم تجهيز جلسة اليوم من بيانات الجهاز، وسيتم التحديث عند توفر المزامنة.',
          AppColors.muted,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProgressSnapshot extends StatelessWidget {
  const _HomeProgressSnapshot({
    required this.currentDayNumber,
    required this.completedDaysCount,
    required this.currentStreakDays,
  });

  final int currentDayNumber;
  final int completedDaysCount;
  final int currentStreakDays;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatusPill(label: 'اليوم المفتوح', value: '$currentDayNumber'),
        _StatusPill(label: 'الأيام المكتملة', value: '$completedDaysCount'),
        _StatusPill(
          label: 'سلسلة الالتزام',
          value: '$currentStreakDays يوم',
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  const _TodaySessionCard({
    required this.dayPlan,
    required this.practiceTask,
    required this.continueDay,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onStartToday,
    required this.onContinue,
  });

  final DailyPlan dayPlan;
  final DailyTask practiceTask;
  final int continueDay;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onStartToday;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'جلسة اليوم',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اليوم ${dayPlan.dayNumber}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      practiceTask.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  '${dayPlan.totalMinutes} د',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: dayPlan.progressPercent / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            isCompleted
                ? 'أنهيت هذه الجلسة بالفعل. راجعها أو انتقل مباشرة إلى اليوم المفتوح التالي.'
                : isUnlocked
                    ? 'ابدأ الآن من درس النغمة، وبعدها سيقودك التطبيق تلقائياً عبر الإيقاع والتمرين حتى النتيجة.'
                    : 'ابدأ من اليوم المفتوح الحالي أولًا.',
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: isCompleted ? 'راجع جلسة اليوم' : 'ابدأ جلسة اليوم',
            onPressed: isUnlocked ? onStartToday : null,
          ),
          if (continueDay != dayPlan.dayNumber && isUnlocked) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onContinue,
              child: Text('اذهب إلى اليوم المفتوح $continueDay'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyFlowCard extends StatelessWidget {
  const _DailyFlowCard({
    required this.isUnlocked,
    required this.isCompleted,
  });

  final bool isUnlocked;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final status = isCompleted
        ? _FlowStepStatus.done
        : isUnlocked
            ? _FlowStepStatus.ready
            : _FlowStepStatus.locked;
    final steps = [
      _FlowStepData('استماع', Icons.hearing_rounded, status),
      _FlowStepData('تعلّم', Icons.school_rounded, status),
      _FlowStepData('تدريب', Icons.tune_rounded, status),
      _FlowStepData('تسجيل', Icons.mic_rounded, status),
      _FlowStepData('نتيجة', Icons.insights_rounded, status),
    ];

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'رحلة اليوم',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < steps.length; index++)
                _FlowStepChip(
                  number: index + 1,
                  step: steps[index],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowStepChip extends StatelessWidget {
  const _FlowStepChip({
    required this.number,
    required this.step,
  });

  final int number;
  final _FlowStepData step;

  @override
  Widget build(BuildContext context) {
    final color = switch (step.status) {
      _FlowStepStatus.done => AppColors.deepTeal,
      _FlowStepStatus.ready => Theme.of(context).colorScheme.primary,
      _FlowStepStatus.locked => AppColors.muted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.26)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$number',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 6),
          Icon(step.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            step.label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FlowStepData {
  const _FlowStepData(this.label, this.icon, this.status);

  final String label;
  final IconData icon;
  final _FlowStepStatus status;
}

enum _FlowStepStatus { done, ready, locked }

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.weakness,
    required this.listeningAssignment,
    required this.latestAttempt,
    required this.latestEvent,
    required this.onOpenLatestAttempt,
    required this.onOpenProgress,
  });

  final String weakness;
  final String listeningAssignment;
  final AttemptHistoryEntry? latestAttempt;
  final AnalyticsEvent? latestEvent;
  final VoidCallback? onOpenLatestAttempt;
  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final quickCoach = latestAttempt?.nextRecommendation ??
        'ابدأ بمحاولة فعلية، وبعدها سنعرض لك هنا أقرب تصحيح موسيقي واضح.';

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التركيز الآن',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text('نقطة الضعف: $weakness'),
          const SizedBox(height: 8),
          Text('مهمة الاستماع: $listeningAssignment'),
          const SizedBox(height: 8),
          Text('توجيه سريع: $quickCoach'),
          if (latestEvent != null) ...[
            const SizedBox(height: 8),
            Text('آخر نشاط: ${_eventLabel(latestEvent!)}'),
          ],
          if (latestAttempt != null) ...[
            const SizedBox(height: 8),
            Text(
              'آخر نتيجة: اليوم ${latestAttempt!.dayNumber} · النغمة ${latestAttempt!.pitchAccuracy}% · الإيقاع ${latestAttempt!.rhythmAccuracy}%',
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (onOpenLatestAttempt != null)
                OutlinedButton(
                  onPressed: onOpenLatestAttempt,
                  child: const Text('افتح آخر نتيجة'),
                ),
              FilledButton(
                onPressed: onOpenProgress,
                child: const Text('كل النتائج والتقدم'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryNavCard extends StatelessWidget {
  const _PrimaryNavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
              Icon(icon, color: AppColors.deepTeal),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnHubScreen extends StatelessWidget {
  const _LearnHubScreen({
    required this.apiClient,
    required this.curriculumRepository,
    required this.curriculumService,
  });

  final SaxPathApiClient apiClient;
  final JazzCurriculumRepository curriculumRepository;
  final CurriculumService curriculumService;

  @override
  Widget build(BuildContext context) {
    final pillars = curriculumRepository.getPillars();

    return Scaffold(
      appBar: AppBar(title: const Text('التعلّم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'مركز التعلّم',
            subtitle:
                'ابدأ من التأسيس، أو ادخل إلى أكاديمية الجاز، أو امشِ على منهج الثلاثين يوم.',
          ),
          const SizedBox(height: 16),
          _PrimaryNavCard(
            title: 'تأسيس الساكسفون',
            subtitle: 'وضع اليد، جدول الأصابع، أول النغمات، ومسار البداية.',
            icon: Icons.music_note_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SaxFoundationScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _PrimaryNavCard(
            title: 'أكاديمية الجاز',
            subtitle:
                '${pillars.length} محاور تعليمية للغة الجاز، البلوز، الإيقاع، والارتجال.',
            icon: Icons.auto_stories_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JazzAcademyScreen(apiClient: apiClient),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _PrimaryNavCard(
            title: 'منهج الثلاثين يوم',
            subtitle:
                'برنامج الشهر الأول: الصوت، السوينج، البلوز، guide tones، و ii-V-I.',
            icon: Icons.calendar_month_rounded,
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
        ],
      ),
    );
  }
}

class _HomeInsights {
  const _HomeInsights({
    this.latestAttempt,
    this.latestEvent,
  });

  final AttemptHistoryEntry? latestAttempt;
  final AnalyticsEvent? latestEvent;
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SaxCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تعذر تحميل خطة اليوم. تأكد أن الـ API شغال ثم حاول مرة أخرى.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _eventLabel(AnalyticsEvent event) {
  final dayLabel = event.dayNumber == null ? '' : ' - اليوم ${event.dayNumber}';

  switch (event.eventName) {
    case 'lesson_start':
      return 'بدء درس$dayLabel';
    case 'practice_finish':
      return 'إنهاء تمرين$dayLabel';
    case 'day_complete':
      return 'إكمال يوم$dayLabel';
    default:
      return '${event.eventName}$dayLabel';
  }
}
