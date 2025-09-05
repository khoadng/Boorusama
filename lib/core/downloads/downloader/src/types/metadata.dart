// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

class DownloaderMetadata extends Equatable {
  const DownloaderMetadata({
    required this.thumbnailUrl,
    required this.fileSize,
    required this.siteUrl,
    required this.group,
    this.isVideo = false,
  });

  factory DownloaderMetadata.fromJson(Map<String, dynamic> json) {
    return DownloaderMetadata(
      thumbnailUrl: json['thumbnailUrl'],
      fileSize: json['fileSize'],
      siteUrl: json['siteUrl'],
      group: json['group'],
      isVideo: json['isVideo'] ?? false,
    );
  }

  factory DownloaderMetadata.fromJsonString(String jsonString) {
    return tryDecodeJson(jsonString).fold(
      (l) => DownloaderMetadata.empty,
      (r) => DownloaderMetadata.fromJson(r),
    );
  }

  final String? thumbnailUrl;
  final int? fileSize;
  final String? siteUrl;
  final String? group;
  final bool isVideo;

  static const empty = DownloaderMetadata(
    thumbnailUrl: null,
    fileSize: null,
    siteUrl: null,
    group: null,
  );

  Map<String, dynamic> toJson() {
    return {
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'siteUrl': siteUrl,
      'group': group,
      'isVideo': isVideo,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [
    thumbnailUrl,
    fileSize,
    siteUrl,
    group,
    isVideo,
  ];
}
