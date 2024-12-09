// Project imports:
import 'package:boorusama/router.dart';
import 'danbooru_upload_post.dart';
import 'pages/danbooru_my_uploads_page.dart';
import 'pages/tag_edit_upload_page.dart';

final danbooruUploadRoutes = GoRoute(
  path: '/danbooru/uploads',
  pageBuilder: largeScreenAwarePageBuilder(
    builder: (context, state) => const DanbooruUploadsPage(),
  ),
  routes: [
    GoRoute(
      path: ':id',
      pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruUploadPost>(
        errorScreenMessage: 'Invalid upload',
        fullScreen: true,
        pageBuilder: (context, state, post) => TagEditUploadPage(
          post: post,
        ),
      ),
    ),
  ],
);
