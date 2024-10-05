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

extension PostDownloadX on WidgetRef {
  Future<PermissionStatus?> _getPermissionStatus() async {
    final perm = await read(deviceStoragePermissionProvider.future);
    return isAndroid() || isIOS() ? perm.storagePermission : null;
  }

  Settings get settings => read(settingsProvider);

  DownloadFileUrlExtractor get urlExtractor =>
      read(downloadFileUrlExtractorProvider(readConfig));

  void _showToastIfPossible({String? message}) {
    if (context.mounted) {
      showDownloadStartToast(context, message: message);
    }
  }

  Future<void> download(Post post) async {
    final perm = await _getPermissionStatus();

    await _download(
      this,
      post,
      permission: perm,
      settings: settings,
      downloadFileUrlExtractor: urlExtractor,
      onStarted: () {
        showDownloadStartToast(context);
      },
    );
  }

  Future<void> bulkDownload(
    List<Post> posts, {
    String? group,
    String? downloadPath,
  }) async {
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
  final downloadUrl = await downloadFileUrlExtractor.getDownloadFileUrl(
    post: downloadable,
    settings: settings,
  );

  final logger = ref.read(loggerProvider);

  if (fileNameBuilder == null) {
    logger.logE('Single Download', 'No file name builder found, aborting...');
    if (ref.context.mounted) {
      showErrorToast(ref.context, 'Download aborted, cannot create file name');
    }
    return;
  }

  if (downloadUrl == null || downloadUrl.isEmpty) {
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
          url: downloadUrl,
          filename: fileName,
          headers: {
            AppHttpHeaders.userAgentHeader:
                ref.read(userAgentGeneratorProvider(booruConfig)).generate(),
            ...ref.read(extraHttpHeaderProvider(booruConfig)),
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
    ref.read(deviceStoragePermissionProvider.notifier).requestPermission(
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
