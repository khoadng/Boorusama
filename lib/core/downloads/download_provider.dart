// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/file_name_generator.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/settings/settings.dart';

final downloadFileNameGeneratorProvider = Provider<FileNameGenerator>((ref) {
  throw UnimplementedError();
});

final downloadNotificationProvider = Provider<DownloadNotifications>((ref) {
  throw UnimplementedError();
});

final downloadUrlProvider =
    Provider.autoDispose.family<String, Post>((ref, post) {
  final settings = ref.watch(settingsProvider);

  if (post.isVideo) return post.sampleImageUrl;

  return switch (settings.downloadQuality) {
    DownloadQuality.original => post.originalImageUrl,
    DownloadQuality.sample => post.sampleImageUrl,
    DownloadQuality.preview => post.thumbnailImageUrl,
  };
});

final downloadServiceProvider = Provider<DownloadService>(
  (ref) {
    final dio = ref.watch(dioProvider(''));
    final notifications = ref.watch(downloadNotificationProvider);

    return DioDownloadService(dio, notifications);
  },
  dependencies: [
    dioProvider,
    downloadNotificationProvider,
  ],
);

class DownloadUrlBaseNameFileNameGenerator implements FileNameGenerator<Post> {
  @override
  String generateFor(Post item, String fileUrl) => basename(fileUrl);
}

class Md5OnlyFileNameGenerator implements FileNameGenerator<Post> {
  @override
  String generateFor(Post item, String fileUrl) =>
      '${item.md5}${extension(fileUrl)}';
}
