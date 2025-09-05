// Project imports:
import '../../../router.dart';
import '../pages/bulk_download_completed_page.dart';
import '../pages/bulk_download_page.dart';
import '../pages/bulk_download_saved_task_page.dart';

const kBulkdownload = '/bulk_downloads';

final bulkDownloadsRoutes = GoRoute(
  path: 'bulk_downloads',
  pageBuilder: genericMobilePageBuilder(
    builder: (context, state) => const BulkDownloadPage(),
  ),
  routes: [
    GoRoute(
      path: 'completed',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const BulkDownloadCompletedPage(),
      ),
    ),
    GoRoute(
      path: 'saved',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const BulkDownloadSavedTaskPage(),
      ),
    ),
  ],
);
