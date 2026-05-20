import 'package:flutter/material.dart';

class SwapButton extends StatelessWidget {
  const SwapButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: const Icon(Icons.swap_vert),
    );
  }
}
