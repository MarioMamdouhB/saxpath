import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/analytics_event.dart';
import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/home/practice_setup_screen.dart';
import 'package:saxpath_mobile/features/progress/attempt_details_screen.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/features/session/guided_session_runner_screen.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/saxpath_brand_mark.dart';
import 'package:saxpath_mobile/shared/music/ai_melody_generator.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/video_masterclass_card.dart';
import 'package:saxpath_mobile/shared/services/language_scope.dart';
import 'package:saxpath_mobile/shared/services/settings_scope.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart' show SaxType;

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

  final ScrollController _scrollController = ScrollController();
  late Future<DailyPlan> _dailyPlanFuture;
  late Future<_HomeInsights> _homeInsightsFuture;
  int? _loadedDayNumber;
  bool _showOnboardingCard = false;
  int? _lastKnownLevel;

  @override
  void initState() {
    super.initState();
    _scheduleScrollReset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensurePreferredDayLoaded();
    _checkLevelUp();
  }

  void _checkLevelUp() {
    final progress = AppProgressScope.of(context);
    if (_lastKnownLevel == null) {
      _lastKnownLevel = progress.level;
      return;
    }

    if (progress.level > _lastKnownLevel!) {
      _lastKnownLevel = progress.level;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLevelUpDialog(progress.level);
      });
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 مبروك! لقد ارتقيت', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'أنت الآن في المستوى $newLevel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('استمر في التدريب لتحقيق أهدافك الموسيقية!'),
          ],
        ),
        actions: [
          PrimaryButton(
            label: 'رائع!',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDataForDay(int dayNumber) {
    _loadedDayNumber = dayNumber;
    _dailyPlanFuture = widget.apiClient.getDailyPlan(dayNumber);
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
      final session = await widget.apiClient.getTodayPracticeSession();

      return _HomeInsights(
        latestAttempt: latestAttempts.isEmpty ? null : latestAttempts.first,
        latestEvent: latestEvents.isEmpty ? null : latestEvents.first,
        practiceSession: session,
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
        builder: (_) => GuidedSessionRunnerScreen(
          apiClient: widget.apiClient,
          dayPlan: displayPlan,
        ),
      ),
    );
  }

  void _showInstrumentSelector() {
    final settings = SettingsScope.of(context);
    final lang = LanguageScope.of(context);
    final current = settings.saxType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('اختر آلتك', 'Select Your Instrument'), textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...SaxType.values.map((type) {
              final isSelected = current == type;
              return ListTile(
                title: Text(type == SaxType.altoEb ? 'Alto (Eb) - ساكس ألتو' : 'Tenor (Bb) - ساكس تينور'),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.deepTeal) : null,
                onTap: () {
                  settings.setSaxType(type);
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(lang.translate('تغيير اللغة (English)', 'Switch to Arabic')),
              onTap: () {
                lang.setLanguage(lang.locale.languageCode == 'ar' ? 'en' : 'ar');
                Navigator.pop(context);
              },
            ),
          ],
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
            tooltip: 'اختر الآلة',
            onPressed: _showInstrumentSelector,
            icon: const Icon(Icons.settings_input_component_rounded),
          ),
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
                      _HomeTopBanner(streak: progressController.currentStreakDays),
                      const SizedBox(height: 20),
                      _TodaySessionCard(
                        dayPlan: displayPlan,
                        practiceTask: practiceTask,
                        focusTask: _focusTaskForPlan(displayPlan),
                        practiceSession: insights.practiceSession?.dayNumber ==
                                displayPlan.dayNumber
                            ? insights.practiceSession
                            : null,
                        continueDay: continueDay,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onStartToday: () => _openTodaySession(displayPlan),
                        onContinue: () => _openHomeDay(continueDay),
                      ),
                      const SizedBox(height: 24),
                      _QuickStartBigButton(
                        onPressed: isUnlocked ? () => _openTodaySession(displayPlan) : null,
                        label: isCompleted ? 'راجع تمرين اليوم' : 'تمرّن الآن (ابدأ فوراً)',
                      ),
                      const SizedBox(height: 24),
                      const _AiDailyChallengeCard(),
                      const SizedBox(height: 16),
                      const _DailyVideoTipCard(),
                      const SizedBox(height: 16),
                      _V31FocusReasonCard(displayPlan: displayPlan),
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
                        xpPoints: progressController.xpPoints,
                        level: progressController.level,
                        levelProgress: progressController.levelProgress,
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
                                      apiClient: widget.apiClient,
                                    ),
                                  ),
                                );
                              },
                        onOpenProgress: _openProgress,
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

  DailyTask? _focusTaskForPlan(DailyPlan plan) {
    for (final task in plan.tasks) {
      if (task.isFocusTask) {
        return task;
      }
    }
    return plan.tasks.isEmpty ? null : plan.tasks.first;
  }

  void _scheduleScrollReset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }
}

class _HomeTopBanner extends StatelessWidget {
  final int streak;
  const _HomeTopBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مرحباً بك يا بطل!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            Text('يومك الـ $streak في رحلة الاحتراف', style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.fireplace_rounded, color: Colors.orange),
              const SizedBox(width: 4),
              Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
            ],
          ),
        ),
      ],
    );
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
    required this.xpPoints,
    required this.level,
    required this.levelProgress,
  });

  final int currentDayNumber;
  final int completedDaysCount;
  final int currentStreakDays;
  final int xpPoints;
  final int level;
  final double levelProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المستوى $level',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '$xpPoints XP',
                    style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: levelProgress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
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
    required this.focusTask,
    required this.practiceSession,
    required this.continueDay,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onStartToday,
    required this.onContinue,
  });

  final DailyPlan dayPlan;
  final DailyTask practiceTask;
  final DailyTask? focusTask;
  final PracticeSession? practiceSession;
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
          if (practiceSession != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.08,
                    ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    practiceSession!.stageTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(practiceSession!.stageSubtitleAr),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: practiceSession!.stageProgressPercent / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 8),
                  Text(practiceSession!.guidedPathLabel),
                  if (practiceSession!.adaptationReasonAr != null) ...[
                    const SizedBox(height: 8),
                    Text(practiceSession!.adaptationReasonAr!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            isCompleted
                ? 'أنهيت هذه الجلسة بالفعل. راجعها أو انتقل مباشرة إلى اليوم المفتوح التالي.'
                : isUnlocked
                    ? 'ابدأ الآن من درس النغمة، وبعدها سيقودك التطبيق تلقائياً عبر الإيقاع والتمرين حتى النتيجة.'
                    : 'ابدأ من اليوم المفتوح الحالي أولًا.',
          ),
          if (practiceTask.adaptationReasonAr != null) ...[
            const SizedBox(height: 10),
            Text(
              practiceTask.adaptationReasonAr!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (practiceTask.recommendedLoopTarget != null ||
              practiceTask.targetBpm != null ||
              practiceTask.supportsWaitMode) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (practiceTask.targetBpm != null)
                  _TodayInfoChip(label: 'BPM ${practiceTask.targetBpm}'),
                if (practiceTask.recommendedLoopTarget != null)
                  _TodayInfoChip(
                    label: '${practiceTask.recommendedLoopTarget} loops',
                  ),
                if (practiceTask.supportsWaitMode)
                  const _TodayInfoChip(label: 'Wait Mode'),
                if (practiceTask.isFocusTask)
                  const _TodayInfoChip(label: 'Focus Task'),
              ],
            ),
          ],
          if (focusTask != null) ...[
            const SizedBox(height: 10),
            Text(
              'بداية الجلسة اليوم: ${_focusEntryLabel(focusTask!)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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

  String _focusEntryLabel(DailyTask task) {
    return switch (task.blockType) {
      'note_fingering' => 'Note / Fingering',
      'rhythm_call_response' => 'Rhythm / Call-and-Response',
      'record_check' => 'Practice / Record Check',
      _ => 'Warm-up',
    };
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

class _TodayInfoChip extends StatelessWidget {
  const _TodayInfoChip({
    required this.label,
  });

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
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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

class _V31FocusReasonCard extends StatelessWidget {
  final DailyPlan displayPlan;

  const _V31FocusReasonCard({required this.displayPlan});

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.deepTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تركيز اليوم: ${displayPlan.tasks.first.title}. هذا التمرين يهدف لتثبيت ${displayPlan.tasks.first.skillTags.join(", ")}.',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartBigButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const _QuickStartBigButton({this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          shadowColor: AppColors.deepTeal.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 36),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiDailyChallengeCard extends StatelessWidget {
  const _AiDailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    final melody = AiMelodyGenerator.generateDailyChallenge();
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text('تحدي اليوم (مؤلف آلياً)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple)),
            ],
          ),
          const SizedBox(height: 12),
          NoteStaffCard(noteLabel: melody, title: 'اعزف هذه المقطوعة الجديدة'),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'ابدأ التحدي',
            onPressed: () {
              // Open Runner with custom melody
            },
          ),
        ],
      ),
    );
  }
}

class _DailyVideoTipCard extends StatelessWidget {
  const _DailyVideoTipCard();

  @override
  Widget build(BuildContext context) {
    return const VideoMasterclassCard(
      title: 'نصيحة اليوم: كيفية تنظيف الساكسفون',
      videoUrl: 'https://example.com/tip.mp4',
    );
  }
}

class _HomeInsights {
  const _HomeInsights({
    this.latestAttempt,
    this.latestEvent,
    this.practiceSession,
  });

  final AttemptHistoryEntry? latestAttempt;
  final AnalyticsEvent? latestEvent;
  final PracticeSession? practiceSession;
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
