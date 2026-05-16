import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../education/sax_foundation_models.dart';
import '../music/sax_reference.dart';
import 'sax_card.dart';

class SaxFingeringCard extends StatefulWidget {
  const SaxFingeringCard({
    super.key,
    required this.noteLabel,
    this.title = 'الفينجرينج',
    this.fingering,
    this.summary,
  });

  final String noteLabel;
  final String title;
  final SaxFingering? fingering;
  final String? summary;

  @override
  State<SaxFingeringCard> createState() => _SaxFingeringCardState();
}

class _SaxFingeringCardState extends State<SaxFingeringCard> {
  late List<String> _availableTokens;
  late String _selectedToken;
  String? _focusedKeyId;

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant SaxFingeringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteLabel != widget.noteLabel) {
      _syncFromWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reference = lookupSaxReference(_selectedToken);
    final pressedKeyIds = widget.fingering == null
        ? reference.pressedKeyIds
        : _pressedKeyIdsForFingering(widget.fingering!);
    final focusedKey = _focusedKeyId == null
        ? null
        : _keySpecs.firstWhere((spec) => spec.id == _focusedKeyId);

    return SaxCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepTeal,
                ),
              ),
              if (focusedKey != null)
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, color: AppColors.muted),
                  onPressed: () => _showKeyDetail(focusedKey),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.fingering == null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final token in _availableTokens)
                  ChoiceChip(
                    label: Text(token),
                    selected: token == _selectedToken,
                    onSelected: (_) {
                      setState(() {
                        _selectedToken = token;
                        _focusedKeyId = null;
                      });
                    },
                  ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.softMint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                widget.noteLabel,
                style: const TextStyle(
                  color: AppColors.deepTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 0.74,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            size: Size(width, height),
                            painter: _ReferenceChartPainter(),
                          ),
                          for (final spec in _keySpecs)
                            _KeyMarker(
                              spec: spec,
                              width: width,
                              height: height,
                              isPressed: pressedKeyIds.contains(spec.id),
                              isFocused: _focusedKeyId == spec.id,
                              onTap: () {
                                setState(() {
                                  _focusedKeyId =
                                      _focusedKeyId == spec.id ? null : spec.id;
                                });
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 72,
                  child: CustomPaint(
                    painter: _MiniStaffPainter(reference.staffStepFromBottom, reference.token),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reference.token,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepTeal,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryPanel(reference, focusedKey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showKeyDetail(_KeySpec spec) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(spec.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(spec.description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(label: 'تم', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel(SaxReferenceNote reference, _KeySpec? focusedKey) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softMint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        focusedKey?.description ?? widget.summary ?? reference.summary,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, height: 1.4, fontSize: 13),
      ),
    );
  }

  void _syncFromWidget() {
    _availableTokens = _extractTokens(widget.noteLabel);
    _selectedToken = _availableTokens.first;
    _focusedKeyId = null;
  }

  List<String> _extractTokens(String raw) {
    // Search for explicit register keys first (e.g. G4, Bb3)
    final explicitMatches = RegExp(r'[A-G](?:#|b|d)?\d').allMatches(raw);
    if (explicitMatches.isNotEmpty) {
      return explicitMatches.map((m) => m.group(0)!).toList();
    }

    final matches = RegExp(r'[A-G](?:#|b|d)?').allMatches(raw.toUpperCase());
    final values = <String>[];
    for (final match in matches) {
      final token = match.group(0);
      if (token != null) {
        // Map simple token to a default register (usually 4 or 5)
        String mapped = token;
        if (RegExp(r'[D-G]').hasMatch(token)) {
          mapped = '${token}4';
        } else if (RegExp(r'[A-C]').hasMatch(token)) {
          mapped = '${token}4'; // Standard A4, B4, C4
        }

        if (!values.contains(mapped)) {
          values.add(mapped);
        }
      }
    }
    return values.isEmpty ? const ['G4'] : values;
  }

  Set<String> _pressedKeyIdsForFingering(SaxFingering fingering) {
    final pressed = <String>{};
    if (fingering.octaveKey) {
      pressed.add('octave');
    }
    if (fingering.leftIndex) {
      pressed.add('p1');
    }
    if (fingering.leftMiddle) {
      pressed.add('p2');
    }
    if (fingering.leftRing) {
      pressed.add('p3');
    }
    if (fingering.rightIndex) {
      pressed.add('p4');
    }
    if (fingering.rightMiddle) {
      pressed.add('p5');
    }
    if (fingering.rightRing) {
      pressed.add('p6');
    }
    if (fingering.sideKeys) {
      pressed.addAll(const {'side1', 'side2'});
    }
    if (fingering.palmKeys) {
      pressed.addAll(const {'palmD', 'palmE', 'palmF'});
    }
    if (fingering.lowKeys) {
      pressed.add('lowD');
    }
    return pressed;
  }
}

class _KeyMarker extends StatelessWidget {
  const _KeyMarker({
    required this.spec,
    required this.width,
    required this.height,
    required this.isPressed,
    required this.isFocused,
    required this.onTap,
  });

  final _KeySpec spec;
  final double width;
  final double height;
  final bool isPressed;
  final bool isFocused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: width * spec.x - (width * spec.width) / 2,
      top: height * spec.y - (height * spec.height) / 2,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width * spec.width,
          height: height * spec.height,
          decoration: BoxDecoration(
            color: isPressed ? AppColors.deepTeal : Colors.white,
            borderRadius: BorderRadius.circular(spec.radius),
            border: Border.all(
              color: isFocused ? AppColors.navyLight : AppColors.deepTeal,
              width: isFocused ? 2.5 : 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.deepTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final thin = Paint()
      ..color = AppColors.deepTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final thumbPath = Path()
      ..moveTo(size.width * 0.16, size.height * 0.14)
      ..quadraticBezierTo(
        size.width * 0.11,
        size.height * 0.17,
        size.width * 0.14,
        size.height * 0.24,
      );
    canvas.drawPath(thumbPath, stroke);

    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.48 + (i * 0.06));
      final top = size.height * 0.04;
      final path = Path()
        ..moveTo(x, top)
        ..quadraticBezierTo(
          x + size.width * 0.012,
          top + size.height * 0.03,
          x,
          top + size.height * 0.066,
        );
      canvas.drawPath(path, thin);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniStaffPainter extends CustomPainter {
  _MiniStaffPainter(this.staffStepFromBottom, this.token);

  final int staffStepFromBottom;
  final String token;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.deepTeal
      ..strokeWidth = 1.4;

    final left = size.width * 0.20;
    final right = size.width * 0.80;
    final top = size.height * 0.20;
    final lineSpacing = size.height * 0.12;
    final bottom = top + (lineSpacing * 4);

    // Draw standard 5 lines
    for (var i = 0; i < 5; i++) {
      final y = top + (i * lineSpacing);
      canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
    }

    final center = Offset(
      size.width * 0.50,
      bottom - (staffStepFromBottom * lineSpacing / 2),
    );

    // Draw Accidental
    if (token.contains('#') || token.contains('b') || token.contains('d')) {
      final accidental = token.contains('#') ? '#' : (token.contains('d') ? 'd' : 'b');
      final tp = TextPainter(
        text: TextSpan(
          text: accidental,
          style: const TextStyle(fontSize: 18, color: AppColors.deepTeal, fontFamily: 'serif'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx - 22, center.dy - 10));
    }

    // Draw Note Head
    final noteRect = Rect.fromCenter(center: center, width: 22, height: 15);
    canvas.drawOval(noteRect, Paint()..color = AppColors.deepTeal);

    // Draw Stem
    canvas.drawLine(
      Offset(center.dx + 10, center.dy),
      Offset(center.dx + 10, center.dy - 35),
      Paint()..color = AppColors.deepTeal..strokeWidth = 1.8,
    );

    // Draw Ledger Lines
    final ledgerPaint = Paint()..color = AppColors.deepTeal..strokeWidth = 1.4;
    if (staffStepFromBottom < 0) {
      for (var s = staffStepFromBottom; s <= 0; s += 2) {
        if (s % 2 == 0) {
          final y = bottom - (s * lineSpacing / 2);
          canvas.drawLine(Offset(center.dx - 16, y), Offset(center.dx + 16, y), ledgerPaint);
        }
      }
    }
    if (staffStepFromBottom > 8) {
      for (var s = 10; s <= staffStepFromBottom; s += 2) {
        final y = bottom - (s * lineSpacing / 2);
        canvas.drawLine(Offset(center.dx - 16, y), Offset(center.dx + 16, y), ledgerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniStaffPainter oldDelegate) {
    return oldDelegate.staffStepFromBottom != staffStepFromBottom || oldDelegate.token != token;
  }
}

class _KeySpec {
  const _KeySpec({
    required this.id,
    required this.label,
    required this.description,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.radius,
  });

  final String id;
  final String label;
  final String description;
  final double x;
  final double y;
  final double width;
  final double height;
  final double radius;
}

const _keySpecs = [
  _KeySpec(
    id: 'octave',
    label: 'مفتاح الأوكتاف',
    description: 'يستخدم لنقل النغمات إلى السجل العالي (الأوكتاف الثاني).',
    x: 0.18,
    y: 0.16,
    width: 0.075,
    height: 0.075,
    radius: 999,
  ),
  _KeySpec(
    id: 'p1',
    label: 'B Key (Left Index)',
    description: 'المفتاح الأول لليد اليسرى.',
    x: 0.31,
    y: 0.10,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p2',
    label: 'A Key (Left Middle)',
    description: 'المفتاح الثاني لليد اليسرى.',
    x: 0.31,
    y: 0.21,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p3',
    label: 'G Key (Left Ring)',
    description: 'المفتاح الثالث لليد اليسرى.',
    x: 0.31,
    y: 0.32,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p4',
    label: 'F Key (Right Index)',
    description: 'أول مفتاح لليد اليمنى.',
    x: 0.31,
    y: 0.46,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p5',
    label: 'E Key (Right Middle)',
    description: 'المفتاح الثاني لليد اليمنى.',
    x: 0.31,
    y: 0.58,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p6',
    label: 'D Key (Right Ring)',
    description: 'المفتاح الثالث لليد اليمنى.',
    x: 0.31,
    y: 0.70,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'sideBb',
    label: 'Side Bb',
    description: 'مفتاح جانبي يستخدم لعزف سي بيمول الوسطى.',
    x: 0.54,
    y: 0.25,
    width: 0.06,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'sideC',
    label: 'Side C',
    description: 'مفتاح جانبي يستخدم لتنويعات دو.',
    x: 0.54,
    y: 0.32,
    width: 0.06,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'palmD',
    label: 'Palm D',
    description: 'مفتاح النخلة لنغمة ري العالية.',
    x: 0.48,
    y: 0.05,
    width: 0.045,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'palmEb',
    label: 'Palm Eb',
    description: 'مفتاح النخلة لمي بيمول العالية.',
    x: 0.54,
    y: 0.05,
    width: 0.045,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'palmE',
    label: 'Palm E',
    description: 'مفتاح النخلة لمي العالية.',
    x: 0.60,
    y: 0.05,
    width: 0.045,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'palmF',
    label: 'Palm F',
    description: 'مفتاح النخلة لفا العالية.',
    x: 0.66,
    y: 0.05,
    width: 0.045,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'lowC',
    label: 'Low C',
    description: 'مفتاح دو المنخفضة (اليد اليمنى).',
    x: 0.44,
    y: 0.78,
    width: 0.09,
    height: 0.06,
    radius: 12,
  ),
  _KeySpec(
    id: 'lowEb',
    label: 'Low Eb',
    description: 'مفتاح مي بيمول المنخفضة.',
    x: 0.44,
    y: 0.85,
    width: 0.09,
    height: 0.06,
    radius: 12,
  ),
  _KeySpec(
    id: 'lowB',
    label: 'Low B',
    description: 'مفتاح سي المنخفضة (اليد اليسرى).',
    x: 0.12,
    y: 0.38,
    width: 0.08,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'lowBb',
    label: 'Low Bb',
    description: 'مفتاح سي بيمول المنخفضة (أقل نغمة).',
    x: 0.12,
    y: 0.46,
    width: 0.08,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'lowC#',
    label: 'Low C#',
    description: 'مفتاح دو دييز المنخفضة.',
    x: 0.12,
    y: 0.54,
    width: 0.08,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'leftPinkyAb',
    label: 'G# / Ab Key',
    description: 'مفتاح لا بيمول للخنصر الأيسر.',
    x: 0.12,
    y: 0.30,
    width: 0.08,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'sideF#',
    label: 'Side F#',
    description: 'المفتاح الجانبي العلوي لنغمة فا دييز العالية.',
    x: 0.58,
    y: 0.35,
    width: 0.06,
    height: 0.06,
    radius: 8,
  ),
  _KeySpec(
    id: 'quarterToneSide',
    label: 'Quarter Tone Modifier',
    description: 'مفتاح إضافي (تخيلي في هذا الشارت) لضبط الربع تون شرقيًا.',
    x: 0.60,
    y: 0.42,
    width: 0.05,
    height: 0.05,
    radius: 999,
  ),
];
