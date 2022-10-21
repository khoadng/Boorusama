// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon(
    this.icon, {
    super.key,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      icon,
      size: 18,
    );
  }
}
