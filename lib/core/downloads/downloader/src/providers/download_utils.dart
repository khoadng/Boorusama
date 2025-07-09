// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../posts/post/post.dart';
import '../../providers.dart';
import '../types/download.dart';

extension PostDownloadX on WidgetRef {
  Future<DownloadTaskInfo?> download(Post post) async {
    return read(downloadNotifierProvider.notifier).download(post);
  }

  Future<void> bulkDownload(
    List<Post> posts, {
    String? group,
    String? downloadPath,
  }) async {
    return read(downloadNotifierProvider.notifier).bulkDownload(
      posts,
      group: group,
      downloadPath: downloadPath,
    );
  }
}
