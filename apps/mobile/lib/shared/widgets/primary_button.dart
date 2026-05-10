import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: hasBoundedWidth ? constraints.maxWidth : 0,
            maxWidth: hasBoundedWidth ? constraints.maxWidth : 360,
          ),
          child: FilledButton(
            onPressed: onPressed,
            child: Text(label),
          ),
        );
      },
    );
  }
}
