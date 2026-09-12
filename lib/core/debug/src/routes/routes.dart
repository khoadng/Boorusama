// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';

// Project imports:
import '../../../router.dart';
import '../pages/debug_logs_page.dart';

final debuglogRoutes = GoRoute(
  path: '/debug_logs',
  name: 'debug_logs',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final landscape = context.orientation.isLandscape;

      const page = DebugLogsPage();

      return landscape
          ? const KurumiDialog(
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
