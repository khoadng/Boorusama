// Project imports:
import '../../../settings/settings.dart';
import '../../downloader.dart';
import '../../filename/generator_impl.dart';
import '../../urls.dart';

class DownloadConfigs {
  const DownloadConfigs({
    this.downloader,
    this.settings,
    this.fileNameBuilder,
    this.urlExtractor,
    this.existChecker,
    this.headers,
    this.blacklistedTags,
    this.baseUrl,
    this.quality,
    this.delayBetweenDownloads = const Duration(milliseconds: 200),
    this.delayBetweenRequests,
    this.androidSdkVersion,
  });

  final DownloadService? downloader;
  final Settings? settings;
  final DownloadFileNameBuilder? fileNameBuilder;
  final DownloadFileUrlExtractor? urlExtractor;
  final DownloadExistChecker? existChecker;
  final Map<String, String>? headers;
  final Set<String>? blacklistedTags;
  final String? baseUrl;
  final String? quality;
  final Duration? delayBetweenDownloads;
  final Duration? delayBetweenRequests;
  final int? androidSdkVersion;
}

abstract class DownloadExistChecker {
  bool exists(String fileName, String path);
}
