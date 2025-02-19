// Project imports:
import '../../../../../../core/router.dart';
import '../pages/danbooru_my_uploads_page.dart';
import '../pages/tag_edit_upload_page.dart';
import '../types/danbooru_upload_post.dart';

final danbooruUploadRoutes = GoRoute(
  path: '/danbooru/uploads',
  name: 'uploads',
  pageBuilder: largeScreenAwarePageBuilder(
    builder: (context, state) => const DanbooruUploadsPage(),
  ),
  routes: [
    GoRoute(
      path: ':id',
      name: 'upload_edit',
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
