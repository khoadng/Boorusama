// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/images/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';

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
    final urlExtractor = read(downloadFileUrlExtractorProvider(readConfig));
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
    final urlExtractor = read(downloadFileUrlExtractorProvider(readConfig));
    final config = readConfig;

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
  final service = ref.read(downloadServiceProvider(booruConfig));
  final fileNameBuilder =
      ref.readBooruBuilder(booruConfig)?.downloadFilenameBuilder;
  final logger = ref.read(loggerProvider);

  final headers = {
    AppHttpHeaders.userAgentHeader:
        ref.read(userAgentGeneratorProvider(booruConfig)).generate(),
    ...ref.read(extraHttpHeaderProvider(booruConfig)),
  };

  final deviceStoragePermissionNotifier =
      ref.read(deviceStoragePermissionProvider.notifier);

  final urlData = await downloadFileUrlExtractor.getDownloadFileUrl(
    post: downloadable,
    settings: settings,
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
          )
        : fileNameBuilder.generate(settings, booruConfig, downloadable);

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
          logger.logI('Single Download',
              'Storage permission request denied, aborting...');
        }
      },
    );
  }
}
