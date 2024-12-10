// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../router.dart';
import '../blacklisted_tags_page.dart';

final danbooruBlacklistRoutes = GoRoute(
  path: '/internal/danbooru/settings/blacklist',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruBlacklistedTagsPage(),
  ),
);
