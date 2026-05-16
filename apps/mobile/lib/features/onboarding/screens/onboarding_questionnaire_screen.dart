import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/saxpath_brand_mark.dart';
import 'package:saxpath_mobile/features/auth/screens/login_screen.dart';

class OnboardingQuestionnaireScreen extends StatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  State<OnboardingQuestionnaireScreen> createState() => _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState extends State<OnboardingQuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Map<int, String> _selections = {};

  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      id: 'dream',
      title: 'ما هو حلمك مع الساكسفون؟',
      subtitle: 'سنقوم بتخصيص دروسك بناءً على هدفك',
      options: [
        OnboardingOption(id: 'pop', label: 'عزف أغاني المشاهير', icon: Icons.music_note),
        OnboardingOption(id: 'oriental', label: 'تعلم المقامات الشرقية', icon: Icons.account_balance),
        OnboardingOption(id: 'band', label: 'العزف في فرقة موسيقية', icon: Icons.groups),
        OnboardingOption(id: 'hobby', label: 'هواية شخصية ممتعة', icon: Icons.favorite),
      ],
    ),
    OnboardingQuestion(
      id: 'experience',
      title: 'ما هو مستواك الحالي؟',
      subtitle: 'لا تقلق، لدينا دروس لكل المستويات',
      options: [
        OnboardingOption(id: 'beginner', label: 'مبتدئ تماماً (أول مرة)', icon: Icons.star_border),
        OnboardingOption(id: 'intermediate', label: 'أعرف القليل من الأساسيات', icon: Icons.star_half),
        OnboardingOption(id: 'advanced', label: 'مستوى متوسط (أعزف مقطوعات)', icon: Icons.star),
      ],
    ),
    OnboardingQuestion(
      id: 'has_instrument',
      title: 'هل تمتلك آلة ساكسفون حالياً؟',
      subtitle: 'لنقترح عليك التمارين المناسبة لك',
      options: [
        OnboardingOption(id: 'yes', label: 'نعم، أمتلك واحدة', icon: Icons.check_circle_outline),
        OnboardingOption(id: 'no', label: 'ليس بعد، أبحث عن واحدة', icon: Icons.search),
        OnboardingOption(id: 'soon', label: 'أخطط لشراء واحدة قريباً', icon: Icons.shopping_cart_outlined),
      ],
    ),
    OnboardingQuestion(
      id: 'track',
      title: 'اختر مسارك التعليمي',
      subtitle: 'يمكنك دائماً تغيير المسار من الإعدادات',
      options: [
        OnboardingOption(
          id: 'beginner',
          label: 'دورة المبتدئين (Beginner Course)',
          icon: Icons.auto_stories_rounded,
        ),
        OnboardingOption(
          id: 'experienced',
          label: 'مسار المتمرسين (Experienced Path)',
          icon: Icons.insights_rounded,
        ),
        OnboardingOption(
          id: 'theory_intro',
          label: 'مقدمة نظرية (Theory Intro)',
          icon: Icons.lightbulb_outline,
        ),
      ],
    ),
  ];

  Future<void> _nextPage(OnboardingOption selectedOption) async {
    _selections[_currentPage] = selectedOption.id;

    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _saveResults();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();

    // Map internal IDs to the keys used in PracticeSetupScreen and V2CourseShellScreen
    final experience = _selections[1] ?? 'beginner';
    final track = _selections[3] ?? 'beginner';

    await prefs.setString('profile.experience', experience);
    await prefs.setString('v2.selected_track', track);
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SaxPathBrandMark(compact: true),
                  Text(
                    '${_currentPage + 1} / ${_questions.length}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: (_currentPage + 1) / _questions.length,
              backgroundColor: AppColors.paleMint,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepTeal),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _QuestionView(
                    question: _questions[index],
                    onOptionSelected: _nextPage,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingQuestion {
  final String id;
  final String title;
  final String subtitle;
  final List<OnboardingOption> options;

  OnboardingQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
  });
}

class OnboardingOption {
  final String id;
  final String label;
  final IconData icon;

  OnboardingOption({required this.id, required this.label, required this.icon});
}

class _QuestionView extends StatelessWidget {
  final OnboardingQuestion question;
  final Function(OnboardingOption) onOptionSelected;

  const _QuestionView({
    required this.question,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            question.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.deepTeal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final option = question.options[index];
                return InkWell(
                  onTap: () => onOptionSelected(option),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(option.icon, color: AppColors.deepTeal, size: 28),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepTeal,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.muted, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
