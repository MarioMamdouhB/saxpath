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
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'العرض هنا صار أقرب إلى chart نظيف ومسطح: أبيض، navy، ومفاتيح واضحة من غير جسم ساكسفون زخرفي.',
            style: TextStyle(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
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
                    painter: _MiniStaffPainter(reference.staffStepFromBottom),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softMint,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        focusedKey?.label ?? 'مرجع النغمة ${reference.token}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.deepTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        focusedKey?.description ??
                            widget.summary ??
                            reference.summary,
                        maxLines: 5,
                        style: const TextStyle(
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _syncFromWidget() {
    _availableTokens = _extractTokens(widget.noteLabel);
    _selectedToken = _availableTokens.first;
    _focusedKeyId = null;
  }

  List<String> _extractTokens(String raw) {
    final matches = RegExp(r'[A-G]').allMatches(raw.toUpperCase());
    final values = <String>[];
    for (final match in matches) {
      final token = match.group(0);
      if (token != null && !values.contains(token)) {
        values.add(token);
      }
    }
    return values.isEmpty ? const ['G'] : values;
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
  _MiniStaffPainter(this.staffStepFromBottom);

  final int staffStepFromBottom;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.deepTeal
      ..strokeWidth = 1.4;

    final left = size.width * 0.20;
    final right = size.width * 0.80;
    final top = size.height * 0.24;
    final lineSpacing = size.height * 0.12;
    final bottom = top + (lineSpacing * 4);

    for (var i = 0; i < 5; i++) {
      final y = top + (i * lineSpacing);
      canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
    }

    final center = Offset(
      size.width * 0.50,
      bottom - (staffStepFromBottom * lineSpacing / 2),
    );
    final noteRect = Rect.fromCenter(center: center, width: 22, height: 15);
    canvas.drawOval(
      noteRect,
      Paint()
        ..color = AppColors.deepTeal
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(center.dx + 10, center.dy),
      Offset(center.dx + 10, center.dy - 28),
      Paint()
        ..color = AppColors.deepTeal
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniStaffPainter oldDelegate) {
    return oldDelegate.staffStepFromBottom != staffStepFromBottom;
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
    description:
        'هذا المفتاح الصغير في أعلى الشارت يستخدم مع نغمات السجل الأعلى في المرجع الحالي.',
    x: 0.18,
    y: 0.16,
    width: 0.075,
    height: 0.075,
    radius: 999,
  ),
  _KeySpec(
    id: 'p1',
    label: 'Pearl 1',
    description: 'المفتاح الأول لليد اليسرى في عمود الأصابع الرئيسي.',
    x: 0.31,
    y: 0.10,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p2',
    label: 'Pearl 2',
    description: 'المفتاح الثاني لليد اليسرى في العمود الرئيسي.',
    x: 0.31,
    y: 0.21,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p3',
    label: 'Pearl 3',
    description: 'المفتاح الثالث لليد اليسرى في العمود الرئيسي.',
    x: 0.31,
    y: 0.32,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'side1',
    label: 'Side Key 1',
    description:
        'مفتاح جانبي مساعد في يمين العمود، يظهر بوضوح في chart المرجعي.',
    x: 0.54,
    y: 0.29,
    width: 0.10,
    height: 0.052,
    radius: 8,
  ),
  _KeySpec(
    id: 'side2',
    label: 'Side Key 2',
    description: 'المفتاح الجانبي الثاني في نفس المجموعة اليمنى.',
    x: 0.58,
    y: 0.29,
    width: 0.10,
    height: 0.052,
    radius: 8,
  ),
  _KeySpec(
    id: 'palmD',
    label: 'Palm D',
    description:
        'مفتاح Palm D العلوي المستخدم مع نغمة D في هذا السجل من الشارت المرجعي.',
    x: 0.48,
    y: 0.07,
    width: 0.05,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'palmE',
    label: 'Palm E',
    description: 'Palm E معروض كمرجع بصري في أعلى الشارت.',
    x: 0.54,
    y: 0.07,
    width: 0.05,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'palmF',
    label: 'Palm F',
    description: 'Palm F معروض كمرجع بصري في أعلى الشارت.',
    x: 0.60,
    y: 0.07,
    width: 0.05,
    height: 0.06,
    radius: 999,
  ),
  _KeySpec(
    id: 'p4',
    label: 'Pearl 4',
    description: 'أول دائرة في الجزء السفلي من العمود.',
    x: 0.31,
    y: 0.46,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p5',
    label: 'Pearl 5',
    description: 'الدائرة الوسطى في الجزء السفلي.',
    x: 0.31,
    y: 0.58,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'p6',
    label: 'Pearl 6',
    description: 'آخر دائرة رئيسية في أسفل العمود.',
    x: 0.31,
    y: 0.70,
    width: 0.09,
    height: 0.072,
    radius: 999,
  ),
  _KeySpec(
    id: 'lowD',
    label: 'Low D',
    description:
        'المفتاح السفلي الأفقي المستخدم فقط عندما يحتاجه المرجع لهذه النغمة.',
    x: 0.12,
    y: 0.78,
    width: 0.10,
    height: 0.055,
    radius: 999,
  ),
];
