import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SaxCard extends StatelessWidget {
  const SaxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: hasBoundedWidth ? constraints.maxWidth : 0,
            maxWidth: hasBoundedWidth ? constraints.maxWidth : 720,
          ),
          child: Container(
            padding: padding,
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border(
                  top: BorderSide(
                    color: AppColors.deepTeal.withValues(alpha: 0.10),
                    width: 1.5,
                  ),
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
