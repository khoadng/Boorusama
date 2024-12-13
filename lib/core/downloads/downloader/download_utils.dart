// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../boorus/booru/src/booru_type.dart';
import '../../boorus/engine/providers.dart';
import '../../configs/config.dart';
import '../../configs/ref.dart';
import '../../foundation/http.dart';
import '../../foundation/loggers.dart';
import '../../foundation/permissions.dart';
import '../../foundation/platform.dart';
import '../../foundation/toast.dart';
import '../../http/providers.dart';
import '../../images/providers.dart';
import '../../posts/post/post.dart';
import '../../posts/sources/source.dart';
import '../../router.dart';
import '../../settings.dart';
import '../../settings/data.dart';
import '../l10n.dart';
import '../urls/download_url.dart';
import 'download_service.dart';
import 'metadata.dart';
import 'providers.dart';

extension PostDownloadX on WidgetRef {
  Future<PermissionStatus?> _getPermissionStatus() async {
    final perm = await read(deviceStoragePermissionProvider.future);
    return isAndroid() || isIOS() ? perm.storagePermission : null;
  }

  void _showToastIfPossible({String? message}) {
    if (context.mounted) {
      showDownloadStartToast(context, message: message);
    }
  }

  Future<void> download(Post post) async {
    final settings = read(settingsProvider);
    final urlExtractor = read(downloadFileUrlExtractorProvider(readConfigAuth));
    final perm = await _getPermissionStatus();

    await _download(
      this,
      post,
      permission: perm,
      settings: settings,
      downloadFileUrlExtractor: urlExtractor,
      onStarted: () {
        final c = navigatorKey.currentState?.context;
        if (c != null) {
          showDownloadStartToast(c);
        }
      },
    );
  }

  Future<void> bulkDownload(
    List<Post> posts, {
    String? group,
    String? downloadPath,
  }) async {
    final settings = read(settingsProvider);
    final config = readConfigAuth;
    final urlExtractor = read(downloadFileUrlExtractorProvider(config));

    // ensure that the booru supports bulk download
    if (!config.booruType.canDownloadMultipleFiles) {
      showBulkDownloadUnsupportErrorToast(context);
      return;
    }

    final perm = await _getPermissionStatus();

    _showToastIfPossible(
      message: 'Downloading ${posts.length} files...',
    );

    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      await _download(
        this,
        post,
        permission: perm,
        settings: settings,
        group: group,
        downloadPath: downloadPath,
        downloadFileUrlExtractor: urlExtractor,
        bulkMetadata: {
          'total': posts.length.toString(),
          'index': i.toString(),
        },
      );
    }
  }
}

Future<void> _download(
  WidgetRef ref,
  Post downloadable, {
  PermissionStatus? permission,
  required Settings settings,
  String? group,
  String? downloadPath,
  Map<String, String>? bulkMetadata,
  required DownloadFileUrlExtractor downloadFileUrlExtractor,
  void Function()? onStarted,
}) async {
  final booruConfig = ref.readConfig;
  final service = ref.read(downloadServiceProvider(booruConfig.auth));
  final fileNameBuilder =
      ref.read(currentBooruBuilderProvider)?.downloadFilenameBuilder;
  final logger = ref.read(loggerProvider);

  final headers = {
    AppHttpHeaders.userAgentHeader:
        ref.read(userAgentProvider(booruConfig.auth.booruType)),
    ...ref.read(extraHttpHeaderProvider(booruConfig.auth)),
  };

  final deviceStoragePermissionNotifier =
      ref.read(deviceStoragePermissionProvider.notifier);

  final urlData = await downloadFileUrlExtractor.getDownloadFileUrl(
    post: downloadable,
    quality: settings.downloadQuality,
  );

  if (fileNameBuilder == null) {
    logger.logE('Single Download', 'No file name builder found, aborting...');
    if (ref.context.mounted) {
      showErrorToast(ref.context, 'Download aborted, cannot create file name');
    }
    return;
  }

  if (urlData == null || urlData.url.isEmpty) {
    logger.logE('Single Download', 'No download url found, aborting...');
    if (ref.context.mounted) {
      showErrorToast(ref.context, 'Download aborted, no download url found');
    }
    return;
  }

  Future<void> download() async {
    onStarted?.call();

    final fileNameFuture = bulkMetadata != null
        ? fileNameBuilder.generateForBulkDownload(
            settings,
            booruConfig,
            downloadable,
            metadata: bulkMetadata,
            downloadUrl: urlData.url,
          )
        : fileNameBuilder.generate(
            settings,
            booruConfig,
            downloadable,
            downloadUrl: urlData.url,
          );

    final fileName = await fileNameFuture;

    await service
        .downloadWithSettings(
          settings,
          config: booruConfig,
          metadata: DownloaderMetadata(
            thumbnailUrl: downloadable.thumbnailImageUrl,
            fileSize: downloadable.fileSize,
            siteUrl: PostSource.from(downloadable.thumbnailImageUrl).url,
            group: group,
          ),
          url: urlData.url,
          filename: fileName,
          headers: {
            ...headers,
            if (urlData.cookie != null)
              AppHttpHeaders.cookieHeader: urlData.cookie!,
          },
          path: downloadPath,
        )
        .run();
  }

  // Platform doesn't require permissions, just download it right away
  if (permission == null) {
    download();
    return;
  }

  if (permission == PermissionStatus.granted) {
    download();
  } else {
    logger.logI('Single Download', 'Permission not granted, requesting...');
    deviceStoragePermissionNotifier.requestPermission(
      onDone: (isGranted) {
        if (isGranted) {
          download();
        } else {
          logger.logI(
            'Single Download',
            'Storage permission request denied, aborting...',
          );
        }
      },
    );
  }
}

void showDownloadStartToast(BuildContext context, {String? message}) {
  showToast(
    message ?? DownloadTranslations.downloadStartedNotification.tr(),
    context: context,
    position: const ToastPosition(
      align: Alignment.bottomCenter,
    ),
    textPadding: const EdgeInsets.all(12),
    textStyle: TextStyle(color: Theme.of(context).colorScheme.surface),
    backgroundColor: Theme.of(context).colorScheme.onSurface,
  );
}

void showBulkDownloadUnsupportErrorToast(BuildContext context) {
  showErrorToast(
    context,
    duration: const Duration(seconds: 3),
    'This booru does not support downloading multiple files',
  );
}
