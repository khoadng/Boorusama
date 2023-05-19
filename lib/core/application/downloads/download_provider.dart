// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/downloads/notification.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
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
