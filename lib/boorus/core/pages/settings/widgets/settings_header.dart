// Flutter imports:
import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
