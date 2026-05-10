import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/analytics_event.dart';
import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/learner_progress.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/shared/education/services/progress_service.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import 'attempt_details_screen.dart';
import '../home/home_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.apiClient,
  });

  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    final progressController = AppProgressScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('التقدم')),
      body: FutureBuilder<WeekOverview>(
        future: apiClient.getWeekOverview(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'تعذر تحميل بيانات التقدم حالياً.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final overview = snapshot.requireData;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
              const SectionTitle(
                title: 'خطة 30 يوم',
                subtitle: 'استعرض الأيام المتاحة واعرف سبب قفل كل مرحلة',
              ),
              const SizedBox(height: 16),
              SaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'اليوم الحالي: ${progressController.currentDayNumber}'),
                    const SizedBox(height: 8),
                    Text(
                      'الأيام المكتملة: ${progressController.completedDaysCount} من ${overview.totalDays}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سلسلة الالتزام الحالية: ${progressController.currentStreakDays} يوم',
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'إعادة ضبط التقدم',
                      onPressed: () async {
                        final shouldReset = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('إعادة ضبط التقدم'),
                              content: const Text(
                                'سيتم حذف التقدم المحلي والعودة إلى اليوم الأول فقط. هل تريد المتابعة؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(false);
                                  },
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                  child: const Text('تأكيد'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldReset != true) {
                          return;
                        }

                        var syncedWithServer = false;
                        try {
                          final serverProgress =
                              await apiClient.resetProgress();
                          await progressController.syncFromSnapshot(
                            serverProgress.completedDays,
                            currentStreakDays:
                                serverProgress.currentStreakDays,
                            lastCompletedAt: serverProgress.lastCompletedAt,
                            replace: true,
                          );
                          syncedWithServer = true;
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تعذر مزامنة إعادة الضبط مع الخادم، وسيتم الاعتماد على المسح المحلي مؤقتاً.',
                                ),
                              ),
                            );
                          }
                        }

                        if (!syncedWithServer) {
                          await progressController.reset();
                        }

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              syncedWithServer
                                  ? 'تمت إعادة ضبط التقدم ومزامنته مع الخادم.'
                                  : 'تمت إعادة ضبط التقدم المحلي.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProgressSyncCard(apiClient: apiClient),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                SaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أدوات المطور',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اختر اليوم الحالي مباشرة لتسريع الاختبار أو العرض.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var dayNumber = 1;
                              dayNumber <= overview.totalDays;
                              dayNumber++)
                            ChoiceChip(
                              label: Text('اليوم $dayNumber'),
                              selected: progressController.currentDayNumber ==
                                  dayNumber,
                              onSelected: (_) async {
                                await progressController
                                    .debugSetCurrentDay(dayNumber);

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم ضبط اليوم الحالي إلى $dayNumber.',
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () async {
                          await progressController.debugCompleteAllDays();

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تعليم الأسبوع الأول كمكتمل.'),
                            ),
                          );
                        },
                        child: const Text('إكمال الأسبوع الأول'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              for (final day in overview.days) ...[
                _WeekDayCard(
                  day: day.copyWith(
                    status: progressController.statusForDay(day.dayNumber),
                    progressPercent:
                        progressController.progressPercentForDay(day.dayNumber),
                  ),
                  onTap: progressController.isDayUnlocked(day.dayNumber)
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HomeScreen(
                                apiClient: apiClient,
                                dayNumber: day.dayNumber,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              _ProgressMetricsCard(apiClient: apiClient),
              const SizedBox(height: 16),
              _ServerProgressCard(apiClient: apiClient),
              const SizedBox(height: 16),
              _AttemptHistoryCard(apiClient: apiClient),
              const SizedBox(height: 16),
              _AnalyticsEventsCard(apiClient: apiClient),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressSyncCard extends StatefulWidget {
  const _ProgressSyncCard({
    required this.apiClient,
  });

  final SaxPathApiClient apiClient;

  @override
  State<_ProgressSyncCard> createState() => _ProgressSyncCardState();
}

class _ProgressSyncCardState extends State<_ProgressSyncCard> {
  var _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppProgressScope.of(context);
    final statusMessage = switch (controller.syncState) {
      ProgressSyncState.syncing => 'جارٍ مزامنة التقدم مع الخادم...',
      ProgressSyncState.synced => controller.lastServerSyncAt == null
          ? 'التقدم متزامن مع الخادم.'
          : 'آخر مزامنة ناجحة: ${_formatSyncTime(controller.lastServerSyncAt!)}',
      ProgressSyncState.failed =>
        'تعذر الوصول إلى الخادم آخر مرة. التطبيق يعمل حاليًا على النسخة المحلية.',
      ProgressSyncState.localOnly =>
        'لم تتم مزامنة التقدم مع الخادم بعد في هذه الجلسة.',
    };

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حالة المزامنة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(statusMessage),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isRefreshing ? null : () => _refreshFromServer(context),
            icon: _isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
            label: const Text('تحديث من الخادم'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshFromServer(BuildContext context) async {
    setState(() {
      _isRefreshing = true;
    });

    final controller = AppProgressScope.of(context);
    controller.markSyncing();

    try {
      final serverProgress = await widget.apiClient.getLearnerProgress();
      await controller.syncFromSnapshot(
        serverProgress.completedDays,
        currentStreakDays: serverProgress.currentStreakDays,
        lastCompletedAt: serverProgress.lastCompletedAt,
        replace: true,
      );
      controller.markServerSynced();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث التقدم من الخادم.'),
          ),
        );
      }
    } catch (_) {
      controller.markServerSyncFailed();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر تحديث التقدم من الخادم الآن. سيتم استخدام النسخة المحلية مؤقتاً.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String _formatSyncTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ProgressMetricsCard extends StatelessWidget {
  const _ProgressMetricsCard({
    required this.apiClient,
    ProgressService? progressService,
  }) : progressService = progressService ?? const ProgressService();

  final SaxPathApiClient apiClient;
  final ProgressService progressService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProgressDashboardSnapshot>(
      future: _loadMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SaxCard(
            child: Text('جارٍ حساب مؤشرات الأداء الموسيقي...'),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SaxCard(
            child: Text('تعذر حساب مؤشرات الأداء حالياً.'),
          );
        }

        final metrics = snapshot.requireData;
        final items = [
          ('Tone score', metrics.toneScore),
          ('Timing score', metrics.timingScore),
          ('Theory score', metrics.theoryScore),
          ('Ear score', metrics.earScore),
          ('Improvisation score', metrics.improvisationScore),
          ('Repertoire learned', metrics.repertoireLearned),
          ('Practice days', metrics.practiceDays),
        ];

        return SaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مؤشرات التقدم',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'ملخص سريع لحالة الصوت، التوقيت، النظرية، السمع، الارتجال، والالتزام اليومي.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final item in items)
                    Container(
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<ProgressDashboardSnapshot> _loadMetrics() async {
    final progress = await apiClient.getLearnerProgress();
    final attempts = await apiClient.getAttemptHistory(limit: 12);
    return progressService.buildDashboard(
      progress: progress,
      attempts: attempts,
    );
  }
}

class _ServerProgressCard extends StatelessWidget {
  const _ServerProgressCard({
    required this.apiClient,
  });

  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LearnerProgress>(
      future: apiClient.getLearnerProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SaxCard(
            child: Text('جارٍ تحميل ملخص التقدم المحفوظ على الخادم...'),
          );
        }

        if (snapshot.hasError) {
          return const SaxCard(
            child: Text('تعذر تحميل التقدم المحفوظ على الخادم حالياً.'),
          );
        }

        final progress = snapshot.requireData;
        return SaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التقدم على الخادم',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'هذه النسخة هي المرجع الأساسي عندما يكون الخادم متاحاً.',
              ),
              const SizedBox(height: 8),
              Text('سلسلة الالتزام الحالية: ${progress.currentStreakDays} يوم'),
              const SizedBox(height: 6),
              Text('اليوم الحالي المحفوظ: ${progress.currentDayNumber}'),
              const SizedBox(height: 6),
              Text(
                'الأيام المكتملة المحفوظة: ${progress.completedDaysCount} من ${progress.totalDays}',
              ),
              const SizedBox(height: 6),
              Text(
                progress.lastCompletedAt == null
                    ? 'آخر إكمال محفوظ: لا يوجد بعد'
                    : 'آخر إكمال محفوظ: ${_formatProgressTimestamp(progress.lastCompletedAt!)}',
              ),
              const SizedBox(height: 6),
              Text(
                progress.completedDays.isEmpty
                    ? 'لم يتم حفظ أي يوم مكتمل بعد.'
                    : 'الأيام المحفوظة: ${progress.completedDays.join(' - ')}',
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatProgressTimestamp(DateTime value) {
  final year = value.year.toString();
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$year/$month/$day - $hour:$minute';
}

class _AnalyticsEventsCard extends StatelessWidget {
  const _AnalyticsEventsCard({
    required this.apiClient,
  });

  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AnalyticsEvent>>(
      future: apiClient.getAnalyticsEvents(limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SaxCard(
            child: Text('جارٍ تحميل نشاط التحليلات الأخير...'),
          );
        }

        if (snapshot.hasError) {
          return const SaxCard(
            child: Text('تعذر تحميل نشاط التحليلات حالياً.'),
          );
        }

        final events = snapshot.requireData;
        return SaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نشاط التحليلات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (events.isEmpty)
                const Text('لا توجد أحداث تحليلات محفوظة بعد.')
              else
                for (var index = 0; index < events.length; index++) ...[
                  _AnalyticsEventTile(event: events[index]),
                  if (index < events.length - 1) const Divider(height: 20),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _AttemptHistoryCard extends StatelessWidget {
  const _AttemptHistoryCard({
    required this.apiClient,
  });

  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttemptHistoryEntry>>(
      future: apiClient.getAttemptHistory(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SaxCard(
            child: Text('جارٍ تحميل آخر المحاولات من الخادم...'),
          );
        }

        if (snapshot.hasError) {
          return const SaxCard(
            child: Text('تعذر تحميل سجل المحاولات حالياً.'),
          );
        }

        final history = snapshot.requireData;
        return SaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'آخر المحاولات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (history.isEmpty)
                const Text('لا توجد محاولات محفوظة على الخادم بعد.')
              else
                for (var index = 0; index < history.length; index++) ...[
                  _AttemptHistoryTile(
                    entry: history[index],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AttemptDetailsScreen(
                            entry: history[index],
                          ),
                        ),
                      );
                    },
                  ),
                  if (index < history.length - 1) const Divider(height: 20),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsEventTile extends StatelessWidget {
  const _AnalyticsEventTile({
    required this.event,
  });

  final AnalyticsEvent event;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${event.createdAt.year}/${event.createdAt.month.toString().padLeft(2, '0')}/${event.createdAt.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _eventLabel(event),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          event.dayNumber == null
              ? 'بدون يوم محدد'
              : 'اليوم ${event.dayNumber}',
        ),
        if (event.taskId != null) ...[
          const SizedBox(height: 4),
          Text('المهمة: ${event.taskId}'),
        ],
        const SizedBox(height: 4),
        Text('التاريخ: $dateLabel'),
      ],
    );
  }

  String _eventLabel(AnalyticsEvent event) {
    switch (event.eventName) {
      case 'lesson_start':
        return 'بدء درس';
      case 'practice_finish':
        return 'إنهاء تمرين';
      case 'day_complete':
        return 'إكمال يوم';
      default:
        return event.eventName;
    }
  }
}

class _AttemptHistoryTile extends StatelessWidget {
  const _AttemptHistoryTile({
    required this.entry,
    required this.onTap,
  });

  final AttemptHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${entry.createdAt.year}/${entry.createdAt.month.toString().padLeft(2, '0')}/${entry.createdAt.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اليوم ${entry.dayNumber} - ${entry.durationSeconds} ثانية',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pitch ${entry.pitchAccuracy}% | Rhythm ${entry.rhythmAccuracy}%',
                  ),
                  if (entry.retryReason != null) ...[
                    const SizedBox(height: 4),
                    Text('Retry: ${entry.retryReason}'),
                  ],
                  const SizedBox(height: 4),
                  Text('التاريخ: $dateLabel'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_left_rounded),
          ],
        ),
      ),
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({
    required this.day,
    required this.onTap,
  });

  final WeekDaySummary day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اليوم ${day.dayNumber}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(day.focusTitle),
            const SizedBox(height: 8),
            Text('${day.totalMinutes} دقيقة - ${_statusLabel(day.status)}'),
            const SizedBox(height: 8),
            Text('التقدم: ${day.progressPercent}%'),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'current':
        return 'اليوم الحالي';
      case 'up_next':
        return 'التالي';
      case 'planned':
        return 'مخطط';
      case 'locked':
        return 'مغلق';
      case 'retry_needed':
        return 'يحتاج إعادة محاولة';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }
}
