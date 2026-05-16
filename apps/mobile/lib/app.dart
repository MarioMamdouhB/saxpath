import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saxpath_mobile/features/auth/login_screen.dart';
import 'package:saxpath_mobile/shared/services/language_controller.dart';
import 'package:saxpath_mobile/shared/services/language_scope.dart';
import 'package:saxpath_mobile/shared/services/settings_controller.dart';
import 'package:saxpath_mobile/shared/services/settings_scope.dart';
import 'package:saxpath_mobile/features/shell/main_app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saxpath_mobile/core/constants/app_strings.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/core/theme/app_theme.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/onboarding/screens/onboarding_questionnaire_screen.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/shared/widgets/saxpath_brand_mark.dart';

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
  late final SettingsController _settingsController;
  late final LanguageController _languageController;
  late final SaxPathApiClient _apiClient;
  AppProgressController? _progressController;
  bool _isServerSyncInFlight = false;
  bool _hasInitialSyncFailed = false;
  bool _isOnboardingCompleted = false;
  bool _isCheckingOnboarding = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apiClient = widget.apiClient ?? SaxPathApiClient();
    _progressControllerFuture = _loadProgressController();
    _settingsController = SettingsController();
    _languageController = LanguageController();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
        _isCheckingOnboarding = false;
      });
    }
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

    setState(() {
      _isServerSyncInFlight = true;
      _hasInitialSyncFailed = false;
    });

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
      if (mounted) {
        setState(() {
          _hasInitialSyncFailed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isServerSyncInFlight = false;
        });
      }
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
            home: Scaffold(
              body: _AppBootSplash(
                isSyncing: _isServerSyncInFlight,
                hasFailed: _hasInitialSyncFailed,
                onRetry: _syncProgressFromServer,
              ),
            ),
          );
        }

        final progressController = snapshot.requireData;

        return LanguageScope(
          controller: _languageController,
          child: SettingsScope(
            controller: _settingsController,
            child: AppProgressScope(
              controller: progressController,
              child: ListenableBuilder(
                listenable: Listenable.merge([_languageController, _settingsController]),
                builder: (context, _) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: AppStrings.appName,
                    theme: AppTheme.build(),
                    locale: _languageController.locale,
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
                              textDirection: _languageController.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                    home: StreamBuilder<AuthState>(
                      stream: Supabase.instance.client.auth.onAuthStateChange,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Scaffold(body: Center(child: CircularProgressIndicator()));
                        }

                        final session = snapshot.data?.session;
                        if (session == null) {
                          return const LoginScreen();
                        }

                        return _isCheckingOnboarding
                            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                            : (_isOnboardingCompleted
                                ? MainAppShell(apiClient: _apiClient)
                                : const OnboardingQuestionnaireScreen());
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppBootSplash extends StatelessWidget {
  const _AppBootSplash({
    required this.isSyncing,
    required this.hasFailed,
    required this.onRetry,
  });

  final bool isSyncing;
  final bool hasFailed;
  final VoidCallback onRetry;

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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SaxPathBrandMark(),
                  const SizedBox(height: 18),
                  Text(
                    hasFailed ? 'عذراً، تعذر الاتصال بالسيرفر' : 'جارٍ فتح جلسة اليوم...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasFailed
                        ? 'يمكنك المحاولة مرة أخرى أو البدء ببياناتك المحلية.'
                        : 'سنبدأ ببياناتك المحلية أولاً ثم نكمل المزامنة في الخلفية.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isSyncing)
                    const CircularProgressIndicator()
                  else if (hasFailed)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onRetry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            // Bypass for offline mode
                          },
                          child: const Text('المتابعة بدون مزامنة'),
                        ),
                      ],
                    ),
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
