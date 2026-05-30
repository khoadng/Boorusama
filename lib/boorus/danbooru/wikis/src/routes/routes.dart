// Project imports:
import '../../../../../core/router.dart';
import '../pages/danbooru_wiki_page.dart';

final danbooruWikiRoutes = GoRoute(
  path: '/danbooru/wiki_pages/:wikiPageName',
  name: 'danbooru_wiki',
  pageBuilder: largeScreenAwarePageBuilder(
    builder: (context, state) {
      final wikiPageName = state.pathParameters['wikiPageName'];

      if (wikiPageName == null || wikiPageName.isEmpty) {
        return const InvalidPage(message: 'Invalid wiki title');
      }

      return DanbooruWikiPage(wikiPageName: wikiPageName);
    },
  ),
);
