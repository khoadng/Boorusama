// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/display.dart';
import '../router.dart';
import '../widgets/booru_dialog.dart';
import 'widgets.dart';

final debuglogRoutes = GoRoute(
  path: '/debug_logs',
  name: 'debug_logs',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final landscape = context.orientation.isLandscape;

      const page = DebugLogsPage();

      return landscape
          ? const BooruDialog(
              padding: EdgeInsets.all(8),
              child: page,
            )
          : page;
    },
  ),
);

Future<void> goToDebuglogPage(WidgetRef ref) {
  return ref.router.push(
    Uri(
      path: '/debug_logs',
    ).toString(),
  );
}
