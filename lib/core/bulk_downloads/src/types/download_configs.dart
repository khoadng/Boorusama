// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../downloads/downloader.dart';
import '../../../downloads/filename/generator_impl.dart';
import '../../../downloads/urls.dart';
import '../../../foundation/permissions/permission_utils.dart';
import '../../../settings/settings.dart';

class DownloadConfigs {
  const DownloadConfigs({
    this.downloader,
    this.notificationPermissionManager,
    this.settings,
    this.fileNameBuilder,
    this.urlExtractor,
    this.existChecker,
    this.directoryExistChecker,
    this.headers,
    this.blacklistedTags,
    this.baseUrl,
    this.quality,
    this.delayBetweenDownloads = const Duration(milliseconds: 200),
    this.delayBetweenRequests,
    this.onDownloadStart,
    this.androidSdkVersion,
  });

  DownloadConfigs copyWith({
    DownloadService? downloader,
    NotificationPermissionManager? notificationPermissionManager,
    Settings? settings,
    DownloadFileNameBuilder? fileNameBuilder,
    DownloadFileUrlExtractor? urlExtractor,
    DownloadExistChecker? existChecker,
    DirectoryExistChecker? directoryExistChecker,
    Map<String, String>? headers,
    Set<String>? blacklistedTags,
    String? baseUrl,
    String? quality,
    Duration? delayBetweenDownloads,
    Duration? delayBetweenRequests,
    VoidCallback? onDownloadStart,
    int? androidSdkVersion,
  }) {
    return DownloadConfigs(
      downloader: downloader ?? this.downloader,
      notificationPermissionManager:
          notificationPermissionManager ?? this.notificationPermissionManager,
      settings: settings ?? this.settings,
      fileNameBuilder: fileNameBuilder ?? this.fileNameBuilder,
      urlExtractor: urlExtractor ?? this.urlExtractor,
      existChecker: existChecker ?? this.existChecker,
      directoryExistChecker:
          directoryExistChecker ?? this.directoryExistChecker,
      headers: headers ?? this.headers,
      blacklistedTags: blacklistedTags ?? this.blacklistedTags,
      baseUrl: baseUrl ?? this.baseUrl,
      quality: quality ?? this.quality,
      delayBetweenDownloads:
          delayBetweenDownloads ?? this.delayBetweenDownloads,
      delayBetweenRequests: delayBetweenRequests ?? this.delayBetweenRequests,
      onDownloadStart: onDownloadStart ?? this.onDownloadStart,
      androidSdkVersion: androidSdkVersion ?? this.androidSdkVersion,
    );
  }

  final DownloadService? downloader;
  final NotificationPermissionManager? notificationPermissionManager;
  final Settings? settings;
  final DownloadFileNameBuilder? fileNameBuilder;
  final DownloadFileUrlExtractor? urlExtractor;
  final DownloadExistChecker? existChecker;
  final DirectoryExistChecker? directoryExistChecker;
  final Map<String, String>? headers;
  final Set<String>? blacklistedTags;
  final String? baseUrl;
  final String? quality;
  final Duration? delayBetweenDownloads;
  final Duration? delayBetweenRequests;
  final VoidCallback? onDownloadStart;
  final int? androidSdkVersion;
}

abstract class DownloadExistChecker {
  bool exists(String fileName, String path);
}

abstract interface class DirectoryExistChecker {
  bool exists(String path);
}
