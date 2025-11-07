// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/home/types.dart';
import '../../artists/search/widgets.dart';
import '../../favgroups/listing/widgets.dart';
import '../../forums/topics/widgets.dart';
import '../../pools/listing/widgets.dart';
import '../../posts/explores/widgets.dart';
import '../../posts/favorites/widgets.dart';
import '../../saved_searches/feed/widgets.dart';

final danbooruCustomHome = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('explore'): CustomHomeDataBuilder(
    displayName: (context) => context.t.explore.explore,
    builder: (context, _) => const DanbooruExplorePage(),
  ),
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: (context) => context.t.profile.favorites,
    builder: (context, _) => const DanbooruFavoritesPage(),
  ),
  const CustomHomeViewKey('artists'): CustomHomeDataBuilder(
    displayName: (context) => context.t.artists.title,
    builder: (context, _) => const DanbooruArtistSearchPage(),
  ),
  const CustomHomeViewKey('forum'): CustomHomeDataBuilder(
    displayName: (context) => context.t.forum.forum,
    builder: (context, _) => const DanbooruForumPage(),
  ),
  const CustomHomeViewKey('favgroup'): CustomHomeDataBuilder(
    displayName: (context) => context.t.favorite_groups.favorite_groups,
    builder: (context, _) => const FavoriteGroupsPage(),
  ),
  const CustomHomeViewKey('saved_searches'): CustomHomeDataBuilder(
    displayName: (context) => context.t.saved_search.saved_search,
    builder: (context, _) => const SavedSearchFeedPage(),
  ),
  const CustomHomeViewKey('pools'): CustomHomeDataBuilder(
    displayName: (context) => context.t.pool.pools,
    builder: (context, _) => const DanbooruPoolPage(),
  ),
};
