import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum KeyKind { digit, operator, equals, edit, delete }

class KeyButton extends StatelessWidget {
  const KeyButton({
    super.key,
    required this.label,
    required this.kind,
    required this.onTap,
  });

  final String label;
  final KeyKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      KeyKind.digit => (scheme.surfaceContainerHighest, scheme.onSurface),
      KeyKind.edit => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
      KeyKind.delete => (scheme.errorContainer, scheme.onErrorContainer),
      KeyKind.operator => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      KeyKind.equals => (scheme.primary, scheme.onPrimary),
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 24,
              fontWeight: kind == KeyKind.equals
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
