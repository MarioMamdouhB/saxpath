import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/audio/audio_analysis_service.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class MaqamLabScreen extends StatefulWidget {
  const MaqamLabScreen({super.key});

  @override
  State<MaqamLabScreen> createState() => _MaqamLabScreenState();
}

class _MaqamLabScreenState extends State<MaqamLabScreen> {
  String _selectedMaqam = 'البياتي (Bayati)';
  final AudioAnalysisService _audio = AudioAnalysisService();
  bool _isListening = false;
  AudioAnalysisResult? _latestResult;

  final List<String> _maqams = [
    'البياتي (Bayati)',
    'الراست (Rast)',
    'السيكاه (Sikah)',
    'الحجاز (Hijaz)',
    'العجم (Ajam)',
  ];

  @override
  void dispose() {
    _audio.stopAnalysis();
    _audio.dispose();
    super.dispose();
  }

  void _toggleListening() {
    if (_isListening) {
      _audio.stopAnalysis();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _latestResult = null;
      });
      // In Bayati, E should be E-half-flat (approx -50 cents)
      _audio.startAnalysis(targetNote: 'E');
      _audio.analysisStream.listen((res) {
        if (mounted) setState(() => _latestResult = res);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحرك الشرقي (Maqam Lab)')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'مختبر الربع تون والذكاء الاصطناعي',
            subtitle: 'تدرب على المقامات الشرقية بأدق تفاصيل الـ Cents.',
          ),
          const SizedBox(height: 24),
          _buildMaqamSelector(),
          const SizedBox(height: 20),
                SaxCard(
                  child: Column(
                    children: [
                      const Text('بوصلة الـ AI للربع تون', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      // Tuning Needle Simulation
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _TuningNeedlePainter(offset: _latestResult?.centOffset ?? 0.0),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (_latestResult?.centOffset.abs() ?? 100) < 60 ? Colors.green.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: (_latestResult?.centOffset.abs() ?? 100) < 60 ? Colors.green : AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _latestResult == null ? 'ابدأ العزف...' : 'الإزاحة: ${_latestResult!.centOffset.toStringAsFixed(1)} Cent',
                              style: TextStyle(
                                color: (_latestResult?.centOffset.abs() ?? 100) < 60 ? Colors.green : AppColors.muted,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: _isListening ? 'إيقاف الاستماع' : 'اختبر الربع تون (نغمة السيكا)',
                  onPressed: _toggleListening,
                ),
                const SizedBox(height: 16),
                const Text(
                  'سيقوم الذكاء الاصطناعي الآن بمقارنة تردد عزفك بتردد السيكا التاريخي (مثلاً 50 cent ناقصة).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Text('هذه ميزة فريدة من نوعها عالمياً لبرنامج SaxPath. جاري تطوير محرك الترددات الدقيق V4.'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaqamSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _maqams.map((maqam) {
        final isSelected = _selectedMaqam == maqam;
        return FilterChip(
          label: Text(maqam),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedMaqam = maqam),
          selectedColor: AppColors.deepTeal.withValues(alpha: 0.2),
          checkmarkColor: AppColors.deepTeal,
        );
      }).toList(),
    );
  }
}

class _TuningNeedlePainter extends CustomPainter {
  final double offset;
  _TuningNeedlePainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border..strokeWidth = 2;
    final needlePaint = Paint()..color = AppColors.deepTeal..strokeWidth = 4..strokeCap = StrokeCap.round;
    
    // Draw Scale
    canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), paint);
    for (var i = 0; i <= 10; i++) {
      final x = size.width * (i / 10);
      canvas.drawLine(Offset(x, size.height/2 - 5), Offset(x, size.height/2 + 5), paint);
    }

    // Draw Needle
    final needleX = size.width / 2 + (offset * (size.width / 2) / 100);
    canvas.drawLine(
      Offset(needleX.clamp(0, size.width), 0),
      Offset(needleX.clamp(0, size.width), size.height),
      needlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TuningNeedlePainter oldDelegate) => oldDelegate.offset != offset;
}
