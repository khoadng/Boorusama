// Project imports:
import '../../../../core/router.dart';
import '../../posts/post/post.dart';
import 'danbooru_post_versions_page.dart';

final danbooruPostVersionRoutes = GoRoute(
  path: '/danbooru/post_versions',
  name: 'post_versions',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPost>(
    errorScreenMessage: 'Invalid post',
    pageBuilder: (context, state, post) => DanbooruPostVersionsPage.post(
      post: post,
    ),
  ),
);
