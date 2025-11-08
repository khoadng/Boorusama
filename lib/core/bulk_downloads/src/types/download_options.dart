// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../downloads/path/types.dart';
import '../../../search/selected_tags/types.dart';
import 'download_task.dart';

class DownloadOptions extends Equatable {
  const DownloadOptions({
    required this.path,
    required this.notifications,
    required this.skipIfExists,
    required this.perPage,
    required this.concurrency,
    required this.tags,
    this.quality,
    this.blacklistedTags,
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
      tags: SearchTagSet.fromList(tags),
    );
  }

  factory DownloadOptions.fromTask(DownloadTask task) {
    return DownloadOptions(
      path: task.path,
      notifications: task.notifications,
      skipIfExists: task.skipIfExists,
      perPage: task.perPage,
      concurrency: task.concurrency,
      tags: SearchTagSet.fromString(task.tags),
      blacklistedTags: task.blacklistedTags,
    );
  }

  DownloadTask toTask({
    required String id,
  }) {
    return DownloadTask(
      id: id,
      path: path,
      notifications: notifications,
      skipIfExists: skipIfExists,
      createdAt: DateTime(1),
      updatedAt: DateTime(1),
      perPage: perPage,
      concurrency: concurrency,
      tags: tags.toString(),
      blacklistedTags: blacklistedTags,
    );
  }

  final String path;
  final bool notifications;
  final bool skipIfExists;
  final String? quality;
  final int perPage;
  final int concurrency;
  final SearchTagSet tags;
  final String? blacklistedTags;

  DownloadOptions copyWith({
    String? path,
    bool? notifications,
    bool? skipIfExists,
    String? quality,
    int? perPage,
    int? concurrency,
    SearchTagSet? tags,
    String? Function()? blacklistedTags,
  }) {
    return DownloadOptions(
      path: path ?? this.path,
      notifications: notifications ?? this.notifications,
      skipIfExists: skipIfExists ?? this.skipIfExists,
      quality: quality ?? this.quality,
      perPage: perPage ?? this.perPage,
      concurrency: concurrency ?? this.concurrency,
      tags: tags ?? this.tags,
      blacklistedTags: blacklistedTags != null
          ? blacklistedTags()
          : this.blacklistedTags,
    );
  }

  @override
  List<Object?> get props => [
    path,
    notifications,
    skipIfExists,
    quality,
    perPage,
    concurrency,
    tags,
    blacklistedTags,
  ];
}

extension DownloadOptionsX on DownloadOptions {
  bool valid({int? androidSdkInt}) {
    if (tags.isEmpty || path.isEmpty) return false;

    final pathInfo = PathInfo.from(path);

    return switch (pathInfo) {
      InvalidPath() => false,
      AndroidPathInfo() => !pathInfo.requiresPublicDirectory(androidSdkInt),
      _ => true, // iOS/Desktop always valid
    };
  }
}
