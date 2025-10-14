// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/permissions/permission_utils.dart';
import '../../../downloads/downloader/types.dart';
import '../../../downloads/filename/types.dart';
import '../../../downloads/urls/types.dart';
import '../../../settings/types.dart';

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
    this.asyncTokenDelay = const Duration(milliseconds: 1000),
    this.onDownloadStart,
    this.androidSdkVersion,
    this.authChangedConfirmation,
  });

  DownloadConfigs copyWith({
    DownloadService? downloader,
    NotificationPermissionManager? notificationPermissionManager,
    Settings? settings,
    DownloadFilenameGenerator? fileNameBuilder,
    DownloadFileUrlExtractor? urlExtractor,
    DownloadExistChecker? existChecker,
    DirectoryExistChecker? directoryExistChecker,
    Map<String, String>? headers,
    Set<String>? blacklistedTags,
    String? baseUrl,
    String? quality,
    Duration? delayBetweenDownloads,
    Duration? delayBetweenRequests,
    Duration? asyncTokenDelay,
    VoidCallback? onDownloadStart,
    int? androidSdkVersion,
    Future<bool> Function()? authChangedConfirmation,
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
      asyncTokenDelay: asyncTokenDelay ?? this.asyncTokenDelay,
      onDownloadStart: onDownloadStart ?? this.onDownloadStart,
      androidSdkVersion: androidSdkVersion ?? this.androidSdkVersion,
      authChangedConfirmation:
          authChangedConfirmation ?? this.authChangedConfirmation,
    );
  }

  final DownloadService? downloader;
  final NotificationPermissionManager? notificationPermissionManager;
  final Settings? settings;
  final DownloadFilenameGenerator? fileNameBuilder;
  final DownloadFileUrlExtractor? urlExtractor;
  final DownloadExistChecker? existChecker;
  final DirectoryExistChecker? directoryExistChecker;
  final Map<String, String>? headers;
  final Set<String>? blacklistedTags;
  final String? baseUrl;
  final String? quality;
  final Duration? delayBetweenDownloads;
  final Duration? delayBetweenRequests;
  final Duration asyncTokenDelay;
  final VoidCallback? onDownloadStart;
  final int? androidSdkVersion;
  final Future<bool> Function()? authChangedConfirmation;
}

abstract class DownloadExistChecker {
  bool exists(String fileName, String path);
}

abstract interface class DirectoryExistChecker {
  bool exists(String path);
}
