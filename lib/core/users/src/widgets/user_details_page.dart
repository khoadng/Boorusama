// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    required this.body,
    super.key,
    this.actions = const [],
  });

  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('profile.profile').tr(),
        actions: actions,
      ),
      body: SafeArea(
        bottom: false,
        child: body,
      ),
    );
  }
}
