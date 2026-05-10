import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/saxpath_api_client.dart';
import 'features/home/home_screen.dart';
import 'features/progress/state/app_progress_controller.dart';
import 'features/progress/state/app_progress_scope.dart';
import 'shared/widgets/saxpath_brand_mark.dart';

class SaxPathApp extends StatefulWidget {
  const SaxPathApp({
    super.key,
    this.apiClient,
  });

  final SaxPathApiClient? apiClient;

  @override
  State<SaxPathApp> createState() => _SaxPathAppState();
}

class _SaxPathAppState extends State<SaxPathApp> with WidgetsBindingObserver {
  late final Future<AppProgressController> _progressControllerFuture;
  late final SaxPathApiClient _apiClient;
  AppProgressController? _progressController;
  bool _isServerSyncInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apiClient = widget.apiClient ?? SaxPathApiClient();
    _progressControllerFuture = _loadProgressController();
  }

  Future<AppProgressController> _loadProgressController() async {
    final controller = await AppProgressController.load();
    _progressController = controller;
    unawaited(_syncProgressFromServer());

    return controller;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncProgressFromServer());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _syncProgressFromServer() async {
    if (_isServerSyncInFlight) {
      return;
    }

    _isServerSyncInFlight = true;
    final controller =
        _progressController ?? await _progressControllerFuture;
    controller.markSyncing();

    try {
      final serverProgress = await _apiClient.getLearnerProgress();
      await controller.syncFromSnapshot(
        serverProgress.completedDays,
        currentStreakDays: serverProgress.currentStreakDays,
        lastCompletedAt: serverProgress.lastCompletedAt,
        replace: true,
      );
      controller.markServerSynced();
    } catch (_) {
      // Keep local progress as a safe fallback when the backend is unavailable.
      controller.markServerSyncFailed();
    } finally {
      _isServerSyncInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppProgressController>(
      future: _progressControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            theme: AppTheme.build(),
            home: const Scaffold(
              body: _AppBootSplash(),
            ),
          );
        }

        final progressController = snapshot.requireData;

        return AppProgressScope(
          controller: progressController,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            theme: AppTheme.build(),
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.offWhite,
                ),
                child: Stack(
                  children: [
                    const PositionedDirectional(
                      top: -90,
                      end: -70,
                      child: _BackdropOrb(
                        size: 240,
                        colors: [
                          Color(0x140F2747),
                          Color(0x040F2747),
                        ],
                      ),
                    ),
                    const PositionedDirectional(
                      top: 220,
                      start: -90,
                      child: _BackdropOrb(
                        size: 220,
                        colors: [
                          Color(0x100F2747),
                          Color(0x030F2747),
                        ],
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
            home: HomeScreen(apiClient: _apiClient),
          ),
        );
      },
    );
  }
}

class _AppBootSplash extends StatelessWidget {
  const _AppBootSplash();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SaxPathBrandMark(),
                  SizedBox(height: 18),
                  Text(
                    'جارٍ فتح جلسة اليوم...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سنبدأ ببياناتك المحلية أولاً ثم نكمل المزامنة في الخلفية.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
