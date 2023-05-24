// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';

final downloadFileNameGeneratorProvider = Provider<FileNameGenerator>((ref) {
  throw UnimplementedError();
});

final downloadNotificationProvider = Provider<DownloadNotifications>((ref) {
  throw UnimplementedError();
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
  String generateFor(Post item) => basename(item.downloadUrl);
}

class Md5OnlyFileNameGenerator implements FileNameGenerator<Post> {
  @override
  String generateFor(Post item) => '${item.md5}${extension(item.downloadUrl)}';
}
