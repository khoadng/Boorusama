// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../router.dart';
import '../pages/bulk_download_page.dart';

GoRoute bulkDownloadsRoutes(Ref ref) => GoRoute(
      path: 'bulk_downloads',
      name: kBulkdownload,
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const BulkDownloadPage(),
      ),
    );
