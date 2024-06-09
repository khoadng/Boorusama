// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/functional.dart';

typedef DownloadFilenameBuilder = String Function();

enum DownloadFilter {
  all,
  pending,
  paused,
  inProgress,
  completed,
  failed,
}

enum DownloadFilter2 {
  all,
  pending,
  paused,
  inProgress,
  completed,
  canceled,
  failed,
}

class DownloaderMetadata extends Equatable {
  const DownloaderMetadata({
    required this.thumbnailUrl,
    required this.fileSize,
    required this.siteUrl,
  });

  final String? thumbnailUrl;
  final int? fileSize;
  final String? siteUrl;

  factory DownloaderMetadata.fromJson(Map<String, dynamic> json) {
    return DownloaderMetadata(
      thumbnailUrl: json['thumbnailUrl'],
      fileSize: json['fileSize'],
      siteUrl: json['siteUrl'],
    );
  }

  static const DownloaderMetadata empty = DownloaderMetadata(
    thumbnailUrl: null,
    fileSize: null,
    siteUrl: null,
  );

  factory DownloaderMetadata.fromJsonString(String jsonString) {
    return tryDecodeJson(jsonString).fold(
      (l) => DownloaderMetadata.empty,
      (r) => DownloaderMetadata.fromJson(r),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'siteUrl': siteUrl,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [thumbnailUrl, fileSize];
}
