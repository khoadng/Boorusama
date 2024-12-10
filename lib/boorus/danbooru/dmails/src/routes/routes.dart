// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:boorusama/router.dart';
import '../pages/dmail_page.dart';

final danbooruDmailRoutes = GoRoute(
  path: '/danbooru/dmails',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruDmailPage(),
  ),
);
