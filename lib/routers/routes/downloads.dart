// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/router.dart';

GoRoute downloadManager() => GoRoute(
      path: 'download_manager',
      name: '/download_manager',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => DownloadManagerGatewayPage(
          filter: state.uri.queryParameters['filter'],
        ),
      ),
    );

GoRoute bulkDownloads(Ref ref) => GoRoute(
      path: 'bulk_downloads',
      name: '/bulk_downloads',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) =>
            ref.read(currentBooruConfigProvider).booruType == BooruType.zerochan
                ? Scaffold(
                    appBar: AppBar(
                      title: const Text('Bulk Download'),
                    ),
                    body: const Center(
                      child: Text(
                          'Temporarily disabled due to an issue with getting the download link'),
                    ),
                  )
                : const BulkDownloadPage(),
      ),
    );
