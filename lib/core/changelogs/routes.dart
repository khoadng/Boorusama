// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/display/types.dart';
import '../router.dart';
import '../widgets/widgets.dart';
import 'dialog.dart';
import 'page.dart';
import 'providers.dart';

final changelogRoutes = GoRoute(
  path: '/changelog',
  name: 'changelog',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final landscape = context.orientation.isLandscape;

      final page = ChangelogPage(
        dialog: landscape,
      );

      return landscape
          ? BooruDialog(
              padding: const EdgeInsets.all(8),
              child: page,
            )
          : page;
    },
  ),
);

Future<void> goToChangelogPage(WidgetRef ref) {
  return ref.router.push(
    Uri(
      path: '/changelog',
    ).toString(),
  );
}

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
