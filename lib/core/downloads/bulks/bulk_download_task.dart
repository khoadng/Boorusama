// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/foundation/platform.dart';
import '../path/validator.dart';

enum BulkDownloadTaskStatus {
  created,
  queue,
  inProgress,
  canceled,
  error,
}

class PageProgress extends Equatable {
  const PageProgress({
    required this.completed,
    required this.perPage,
  });

  PageProgress copyWith({
    int? completed,
    int? perPage,
  }) {
    return PageProgress(
      completed: completed ?? this.completed,
      perPage: perPage ?? this.perPage,
    );
  }

  final int completed;
  final int perPage;

  @override
  List<Object?> get props => [completed];
}

class BulkDownloadOptions extends Equatable {
  const BulkDownloadOptions({
    required this.notications,
    required this.skipIfExists,
    required this.quality,
  });

  const BulkDownloadOptions.defaults()
      : notications = true,
        quality = null,
        skipIfExists = true;

  BulkDownloadOptions copyWith({
    bool? notications,
    bool? skipIfExists,
    DownloadQuality? Function()? quality,
  }) {
    return BulkDownloadOptions(
      notications: notications ?? this.notications,
      skipIfExists: skipIfExists ?? this.skipIfExists,
      quality: quality != null ? quality() : this.quality,
    );
  }

  final bool notications;
  final bool skipIfExists;
  final DownloadQuality? quality;

  @override
  List<Object?> get props => [
        notications,
        skipIfExists,
        quality,
      ];
}

class BulkDownloadTask extends Equatable with DownloadPathValidatorMixin {
  const BulkDownloadTask({
    required this.id,
    required this.status,
    required this.tags,
    required this.path,
    required this.estimatedDownloadSize,
    required this.coverUrl,
    required this.totalItems,
    required this.mixedMedia,
    required this.siteUrl,
    required this.pageProgress,
    required this.options,
    required this.error,
  });

  BulkDownloadTask.randomId({
    required this.tags,
    required this.path,
    required DownloadQuality quality,
  })  : id = 'task${DateTime.now().millisecondsSinceEpoch}',
        estimatedDownloadSize = null,
        coverUrl = null,
        totalItems = null,
        mixedMedia = null,
        siteUrl = null,
        pageProgress = null,
        error = null,
        options = const BulkDownloadOptions.defaults().copyWith(
          quality: () => quality,
        ),
        status = BulkDownloadTaskStatus.created;

  BulkDownloadTask copyWith({
    String? id,
    BulkDownloadTaskStatus? status,
    List<String>? tags,
    String? path,
    int? Function()? estimatedDownloadSize,
    String? Function()? coverUrl,
    int? Function()? totalItems,
    bool? Function()? mixedMedia,
    String? Function()? siteUrl,
    PageProgress? Function()? pageProgress,
    BulkDownloadOptions? options,
    String? Function()? error,
  }) {
    return BulkDownloadTask(
      id: id ?? this.id,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      path: path ?? this.path,
      estimatedDownloadSize:
          estimatedDownloadSize?.call() ?? this.estimatedDownloadSize,
      coverUrl: coverUrl?.call() ?? this.coverUrl,
      totalItems: totalItems?.call() ?? this.totalItems,
      mixedMedia: mixedMedia?.call() ?? this.mixedMedia,
      siteUrl: siteUrl?.call() ?? this.siteUrl,
      pageProgress: pageProgress?.call() ?? this.pageProgress,
      options: options ?? this.options,
      error: error?.call() ?? this.error,
    );
  }

  final String id;
  final BulkDownloadTaskStatus status;
  final List<String> tags;
  final String path;
  final int? estimatedDownloadSize;
  final int? totalItems;
  final bool? mixedMedia;
  final String? coverUrl;
  final String? siteUrl;
  final PageProgress? pageProgress;

  final BulkDownloadOptions options;

  final String? error;

  @override
  List<Object?> get props => [
        id,
        status,
        tags,
        path,
        estimatedDownloadSize,
        coverUrl,
        totalItems,
        mixedMedia,
        siteUrl,
        pageProgress,
        options,
        error,
      ];

  @override
  String? get storagePath => path;
}

extension BulkDownloadTaskX on BulkDownloadTask {
  String get query => tags.join(' ');
  String get displayName => tags.join(', ');
}

extension BulkDownloadTaskXX on BulkDownloadTask {
  bool valid({
    int? androidSdkInt,
  }) {
    if (tags.isEmpty) return false;
    if (path.isEmpty) return false;

    if (!isAndroid()) return true;

    return !shouldDisplayWarning(
      hasScopeStorage: hasScopedStorage(androidSdkInt) ?? true,
    );
  }
}
