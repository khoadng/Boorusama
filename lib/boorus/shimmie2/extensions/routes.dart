// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/router.dart';
import 'page.dart';

final shimmie2ExtensionsRoutes = GoRoute(
  path: '/shimmie2/ext_doc',
  name: 'extensions',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) => const Shimmie2ExtensionsPage(),
  ),
);

void goToShimmie2ExtensionsPage(WidgetRef ref) {
  ref.router.push('/shimmie2/ext_doc');
}
