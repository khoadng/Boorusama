// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../posts/post/types.dart';
import '../../../filename/providers.dart';
import '../types/download.dart';
import 'download_notifier.dart';

extension PostDownloadX on WidgetRef {
  Future<DownloadTaskInfo?> download(Post post) {
    return read(
      downloadNotifierProvider((
        auth: readConfigAuth,
        download: readConfigDownload,
        filenameBuilder: read(
          downloadFilenameBuilderProvider(readConfigAuth),
        ),
      )).notifier,
    ).download(post);
  }

  Future<void> bulkDownload(
    List<Post> posts, {
    String? group,
    String? downloadPath,
  }) {
    return read(
      downloadNotifierProvider((
        auth: readConfigAuth,
        download: readConfigDownload,
        filenameBuilder: read(
          downloadFilenameBuilderProvider(readConfigAuth),
        ),
      )).notifier,
    ).bulkDownload(
      posts,
      group: group,
      downloadPath: downloadPath,
    );
  }
}
