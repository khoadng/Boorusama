// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../router.dart';
import '../artist_search_page.dart';

final danbooruArtistRoutes = GoRoute(
  path: '/danbooru/artists',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruArtistSearchPage(),
  ),
);
