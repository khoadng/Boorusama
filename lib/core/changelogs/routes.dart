// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'dialog.dart';
import 'providers.dart';

Future<void> showChangelogDialogIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  final shouldShow = await ref.read(changelogVisibilityNotifierProvider.future);

  if (shouldShow) {
    if (!context.mounted) return;

    final _ = await showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: 'changelog',
      ),
      builder: (context) => const ChangelogDialog(),
    );

    await ref.read(changelogVisibilityNotifierProvider.notifier).markAsSeen();
  }
}
