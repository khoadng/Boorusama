// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../artist_search_page.dart';

final danbooruArtistRoutes = GoRoute(
  path: '/danbooru/artists',
  name: 'artist_search',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruArtistSearchPage(),
  ),
);
