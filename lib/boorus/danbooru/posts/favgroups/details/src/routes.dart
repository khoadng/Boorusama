// Project imports:
import '../../../../../../router.dart';
import '../../favgroups/favgroup.dart';
import 'favorite_group_details_page.dart';

final danbooruFavgroupDetailsRoutes = GoRoute(
  path: ':id',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruFavoriteGroup>(
    errorScreenMessage: 'Invalid group',
    fullScreen: true,
    pageBuilder: (context, state, group) => FavoriteGroupDetailsPage(
      group: group,
    ),
  ),
);
