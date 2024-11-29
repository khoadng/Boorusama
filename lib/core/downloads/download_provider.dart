// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/path.dart';

final downloadNotificationProvider = Provider<DownloadNotifications>((ref) {
  throw UnimplementedError();
});

final downloadServiceProvider =
    Provider.family<DownloadService, BooruConfigAuth>(
  (ref, config) {
    return BackgroundDownloader();
  },
  dependencies: [
    dioProvider,
    downloadNotificationProvider,
    currentBooruConfigProvider,
    settingsProvider,
  ],
);

String generateMd5FileNameFor(Post item, String fileUrl) =>
    '${item.md5}${sanitizedExtension(fileUrl)}';

String sanitizedExtension(String url) {
  return extension(sanitizedUrl(url));
}

String sanitizedUrl(String url) {
  final ext = extension(url);
  final indexOfQuestionMark = ext.indexOf('?');

  if (indexOfQuestionMark != -1) {
    final trimmedExt = ext.substring(0, indexOfQuestionMark);

    return url.replaceFirst(ext, trimmedExt);
  } else {
    return url;
  }
}

extension BooruConfigDownloadX on BooruConfig {
  bool get hasCustomDownloadLocation =>
      customDownloadLocation != null && customDownloadLocation!.isNotEmpty;
}
