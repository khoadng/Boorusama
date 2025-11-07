// Project imports:
import 'artists/search/routes.dart';
import 'blacklist/routes.dart';
import 'comments/editor/routes.dart';
import 'dmails/routes.dart';
import 'favgroups/listing/routes.dart';
import 'forums/topics/routes.dart';
import 'pools/listing/routes.dart';
import 'posts/explores/routes.dart';
import 'posts/uploads/routes.dart';
import 'saved_searches/feed/routes.dart';
import 'saved_searches/listing/routes.dart';
import 'tags/edit/routes.dart';
import 'users/details/routes.dart';
import 'users/feedbacks/routes.dart';
import 'users/user/routes.dart';
import 'versions/routes.dart';

// Internal custom routes
final danbooruCustomRoutes = [
  danbooruSavedSearchFeedRoutes,
  danbooruExploreHotRoutes,
  danbooruBlacklistRoutes,
  danbooruTagEditRoutes,
  danbooruCommentEditorRoutes,
  danbooruFavoriterListRoutes,
  danbooruVoterListRoutes,
];

final danbooruRoutes = [
  ...danbooruDirectRoutes,
  ...danbooruCustomRoutes,
];

// Danbooru direct mapping routes
final danbooruDirectRoutes = [
  danbooruProfileRoutes,
  danbooruDmailRoutes,
  danbooruArtistRoutes,
  danbooruForumRoutes,
  danbooruFavgroupRoutes,
  danbooruExploreRoutes,
  danbooruSavedSearchRoutes,
  danbooruUserDetailsRoutes,
  danbooruPostVersionRoutes,
  danbooruPoolRoutes,
  danbooruUploadRoutes,
  danbooruUserFeedbackRoutes,
];
