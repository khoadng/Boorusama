// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../config/providers.dart';

class BooruConfigAuthFailsafe extends ConsumerWidget {
  const BooruConfigAuthFailsafe({
    required this.builder,
    super.key,
    this.hasLogin,
  });

  final WidgetBuilder builder;
  final bool? hasLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(booruLoginDetailsProvider(config));

    return hasLogin ?? loginDetails.hasLogin()
        ? builder(context)
        : const UnauthorizedPage();
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
