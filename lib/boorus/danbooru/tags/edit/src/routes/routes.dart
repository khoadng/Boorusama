// Project imports:
import '../../../../../../core/router.dart';
import '../../../../posts/post/post.dart';
import '../tag_edit_page.dart';

final danbooruTagEditRoutes = GoRoute(
  path: '/internal/danbooru/posts/:id/editor',
  name: 'tag_edit',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPost>(
    errorScreenMessage: 'Invalid post',
    fullScreen: true,
    pageBuilder: (context, state, post) => DanbooruTagEditPage(
      post: post,
    ),
  ),
);
