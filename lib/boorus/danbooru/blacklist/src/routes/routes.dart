// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../blacklisted_tags_page.dart';

final danbooruBlacklistRoutes = GoRoute(
  path: '/internal/danbooru/settings/blacklist',
  name: 'blacklisted_tags',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruBlacklistedTagsPage(),
  ),
);
