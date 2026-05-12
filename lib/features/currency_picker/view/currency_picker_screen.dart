import 'package:flutter/material.dart';

class CurrencyPickerArgs {
  const CurrencyPickerArgs({required this.availableCodes});
  const CurrencyPickerArgs.empty() : availableCodes = const [];
  final List<String> availableCodes;
}

class CurrencyPickerScreen extends StatelessWidget {
  const CurrencyPickerScreen({super.key, required this.args});
  final CurrencyPickerArgs args;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Picker (Phase I stub)')));
  }
}
