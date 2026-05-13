import 'package:flutter/material.dart';

class AlphabetIndex extends StatelessWidget {
  const AlphabetIndex({super.key, required this.onLetter});
  final ValueChanged<String> onLetter;

  static const _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _letters.map((l) {
        return InkWell(
          onTap: () => onLetter(l),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            child: Text(l, style: Theme.of(context).textTheme.labelSmall),
          ),
        );
      }).toList(),
    );
  }
}
