// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/platform.dart';
import '../../path.dart';

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
