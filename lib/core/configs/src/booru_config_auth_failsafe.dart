// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'booru_config_ref.dart';

class BooruConfigAuthFailsafe extends ConsumerWidget {
  const BooruConfigAuthFailsafe({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return config.hasLoginDetails() ? child : const UnauthorizedPage();
  }
}

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('You must be logged in to view this page'),
      ),
    );
  }
}
