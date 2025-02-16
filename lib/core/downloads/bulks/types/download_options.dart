// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/platform.dart';
import '../../path.dart';
import 'download_task.dart';

class DownloadOptions extends Equatable with DownloadPathValidatorMixin {
  const DownloadOptions({
    required this.path,
    required this.notifications,
    required this.skipIfExists,
    required this.perPage,
    required this.concurrency,
    required this.tags,
    this.quality,
  });

  factory DownloadOptions.initial({
    String? quality,
    List<String>? tags,
  }) {
    return DownloadOptions(
      path: '',
      notifications: true,
      skipIfExists: true,
      quality: quality,
      perPage: 100,
      concurrency: 5,
      tags: tags ?? [],
    );
  }

  factory DownloadOptions.fromTask(DownloadTask task) {
    return DownloadOptions(
      path: task.path,
      notifications: task.notifications,
      skipIfExists: task.skipIfExists,
      perPage: task.perPage,
      concurrency: task.concurrency,
      tags: task.tags?.split(' ') ?? [],
    );
  }

  final String path;
  final bool notifications;
  final bool skipIfExists;
  final String? quality;
  final int perPage;
  final int concurrency;
  final List<String> tags;

  DownloadOptions copyWith({
    String? path,
    bool? notifications,
    bool? skipIfExists,
    String? quality,
    int? perPage,
    int? concurrency,
    List<String>? tags,
  }) {
    return DownloadOptions(
      path: path ?? this.path,
      notifications: notifications ?? this.notifications,
      skipIfExists: skipIfExists ?? this.skipIfExists,
      quality: quality ?? this.quality,
      perPage: perPage ?? this.perPage,
      concurrency: concurrency ?? this.concurrency,
      tags: tags ?? this.tags,
    );
  }

  @override
  String? get storagePath => path;

  @override
  List<Object?> get props => [
        path,
        notifications,
        skipIfExists,
        quality,
        perPage,
        concurrency,
        tags,
      ];
}

extension DownloadOptionsX on DownloadOptions {
  bool valid({
    int? androidSdkInt,
    bool? android,
  }) {
    if (tags.isEmpty) return false;

    if (path.isEmpty) return false;

    final droid = android ?? isAndroid();

    if (!droid) return true;

    return isValidDownload(
      hasScopeStorage: hasScopedStorage(androidSdkInt) ?? true,
    );
  }
}
