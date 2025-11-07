// Project imports:
import '../../../../../core/router.dart';
import '../../favgroups/types.dart';
import 'favorite_group_details_page.dart';

final danbooruFavgroupDetailsRoutes = GoRoute(
  path: ':id',
  name: 'favorite_group_details',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruFavoriteGroup>(
    errorScreenMessage: 'Invalid group',
    fullScreen: true,
    pageBuilder: (context, state, group) => FavoriteGroupDetailsPage(
      group: group,
    ),
  ),
);
