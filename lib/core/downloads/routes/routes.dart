// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../router.dart';
import '../bulks/pages/bulk_download_page.dart';
import '../manager/download_manager_page.dart';

final downloadManagerRoutes = GoRoute(
  path: 'download_manager',
  name: '/download_manager',
  pageBuilder: genericMobilePageBuilder(
    builder: (context, state) => DownloadManagerGatewayPage(
      filter: state.uri.queryParameters['filter'],
      group: state.uri.queryParameters['group'],
    ),
  ),
);

GoRoute bulkDownloadsRoutes(Ref ref) => GoRoute(
      path: 'bulk_downloads',
      name: kBulkdownload,
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const BulkDownloadPage(),
      ),
    );
