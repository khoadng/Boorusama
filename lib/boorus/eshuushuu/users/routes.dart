// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/router.dart';
import 'widgets.dart';

final eshuushuuUserDetailsRoutes = GoRoute(
  path: '/eshuushuu/users/:id',
  pageBuilder: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '');

    if (id == null) {
      return CupertinoPage(
        key: state.pageKey,
        child: const InvalidPage(message: 'Invalid user'),
      );
    }

    return CupertinoPage(
      key: state.pageKey,
      child: EshuushuuUserDetailsPage(
        userId: id,
        username: state.uri.queryParameters['name'],
      ),
    );
  },
);

void goToEshuushuuUserDetailsPage(
  WidgetRef ref, {
  required int userId,
  String? username,
}) {
  ref.router.push(
    Uri(
      pathSegments: ['', 'eshuushuu', 'users', '$userId'],
      queryParameters: {
        'name': ?username,
      },
    ).toString(),
  );
}
