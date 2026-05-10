import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  static const _nameKey = 'profile.display_name';
  static const _languageKey = 'profile.language';
  static const _saxTypeKey = 'profile.sax_type';
  static const _experienceKey = 'profile.experience';
  static const _subscriptionKey = 'profile.subscription';

  final TextEditingController _nameController = TextEditingController();
  String _language = 'ar';
  SaxType _saxType = SaxType.altoEb;
  String _experience = 'beginner';
  String _subscription = 'free';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات والملف')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionTitle(
                  title: 'ملف التعلم',
                  subtitle:
                      'من هنا تضبط الاسم، اللغة، نوع الساكسفون، ومستوى البداية قبل التوسع في التمارين المخصصة.',
                ),
                const SizedBox(height: 16),
                SaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الهوية والواجهة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المتعلم',
                          hintText: 'مثال: أحمد',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'لغة الواجهة',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoicePill(
                            key: const ValueKey('language_ar'),
                            label: 'العربية',
                            selected: _language == 'ar',
                            onTap: () => setState(() => _language = 'ar'),
                          ),
                          _ChoicePill(
                            key: const ValueKey('language_en'),
                            label: 'English',
                            selected: _language == 'en',
                            onTap: () => setState(() => _language = 'en'),
                          ),
                        ],
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
                        'الآلة ومستوى الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اختيار نوع الساكسفون هنا يمهّد لاحقًا لضبط النقل والنوتة والتمارين المناسبة.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final saxType in SaxType.values)
                            _ChoicePill(
                              key: ValueKey('sax_type_${saxType.name}'),
                              label: _saxTypeLabel(saxType),
                              selected: _saxType == saxType,
                              onTap: () => setState(() => _saxType = saxType),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'مستوى البداية',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoicePill(
                            key: const ValueKey('experience_beginner'),
                            label: 'مبتدئ',
                            selected: _experience == 'beginner',
                            onTap: () =>
                                setState(() => _experience = 'beginner'),
                          ),
                          _ChoicePill(
                            key: const ValueKey('experience_intermediate'),
                            label: 'متوسط',
                            selected: _experience == 'intermediate',
                            onTap: () =>
                                setState(() => _experience = 'intermediate'),
                          ),
                          _ChoicePill(
                            key: const ValueKey('experience_advanced'),
                            label: 'متقدم',
                            selected: _experience == 'advanced',
                            onTap: () =>
                                setState(() => _experience = 'advanced'),
                          ),
                        ],
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
                        'وضع الاستخدام',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اختر وضع الحساب الحالي حتى تظل التفضيلات والواجهة على نفس السياق داخل هذا الجهاز.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoicePill(
                            key: const ValueKey('subscription_free'),
                            label: 'مجاني',
                            selected: _subscription == 'free',
                            onTap: () =>
                                setState(() => _subscription = 'free'),
                          ),
                          _ChoicePill(
                            key: const ValueKey('subscription_beta'),
                            label: 'بيتا خاصة',
                            selected: _subscription == 'beta',
                            onTap: () =>
                                setState(() => _subscription = 'beta'),
                          ),
                          _ChoicePill(
                            key: const ValueKey('subscription_pro'),
                            label: 'موسع',
                            selected: _subscription == 'pro',
                            onTap: () => setState(() => _subscription = 'pro'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملاحظات مهمة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'هذه الإعدادات تحفظ على هذا الجهاز الآن، وتساعدنا نثبت الاسم، اللغة، نوع الآلة، ومستوى البداية قبل أي تخصيص أعمق.',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'رحلة اليوم الأساسية، التقدم، والتسجيل هي المسارات الأكثر جاهزية الآن. أي توسعات لاحقة يجب أن تضيف وضوحًا لا ازدحامًا.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: _isSaving ? 'جارٍ الحفظ...' : 'حفظ الإعدادات',
                  onPressed: _isSaving ? null : _savePreferences,
                ),
              ],
            ),
    );
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();

    _nameController.text = preferences.getString(_nameKey) ?? 'أحمد';
    _language = preferences.getString(_languageKey) ?? 'ar';
    _experience = preferences.getString(_experienceKey) ?? 'beginner';
    _subscription = preferences.getString(_subscriptionKey) ?? 'free';

    final storedSaxType = preferences.getString(_saxTypeKey);
    _saxType = SaxType.values.firstWhere(
      (value) => value.name == storedSaxType,
      orElse: () => SaxType.altoEb,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nameKey, _nameController.text.trim());
    await preferences.setString(_languageKey, _language);
    await preferences.setString(_saxTypeKey, _saxType.name);
    await preferences.setString(_experienceKey, _experience);
    await preferences.setString(_subscriptionKey, _subscription);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات الأساسية لهذا الجهاز.'),
      ),
    );
  }

  String _saxTypeLabel(SaxType saxType) {
    switch (saxType) {
      case SaxType.altoEb:
        return 'Alto Eb';
      case SaxType.tenorBb:
        return 'Tenor Bb';
      case SaxType.sopranoBb:
        return 'Soprano Bb';
      case SaxType.baritoneEb:
        return 'Baritone Eb';
    }
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.deepTeal.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: selected ? AppColors.deepTeal : null,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.deepTeal.withValues(alpha: 0.3)
            : AppColors.border,
      ),
    );
  }
}
