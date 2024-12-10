// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../downloads/bulks.dart';
import '../../downloads/manager.dart';
import '../../router.dart';

GoRoute downloadManager() => GoRoute(
      path: 'download_manager',
      name: '/download_manager',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => DownloadManagerGatewayPage(
          filter: state.uri.queryParameters['filter'],
          group: state.uri.queryParameters['group'],
        ),
      ),
    );

GoRoute bulkDownloads(Ref ref) => GoRoute(
      path: 'bulk_downloads',
      name: kBulkdownload,
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const BulkDownloadPage(),
      ),
    );
