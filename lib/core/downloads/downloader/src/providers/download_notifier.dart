// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../../foundation/permissions.dart';
import '../../../../../foundation/platform.dart';
import '../../../../../foundation/toast.dart';
import '../../../../configs/config/types.dart';
import '../../../../http/client/types.dart';
import '../../../../posts/post/types.dart';
import '../../../../posts/sources/types.dart';
import '../../../../router.dart';
import '../../../../settings/types.dart';
import '../../../filename/types.dart';
import '../../../urls/types.dart';
import '../types/download.dart';
import '../types/metadata.dart';
import '../types/observer.dart';

final downloadNotifierProvider =
    NotifierProvider.family<DownloadNotifier, void, DownloadNotifierParams>(
      DownloadNotifier.new,
    );

typedef DownloadNotifierParams = ({
  BooruConfigDownload download,
  DownloadFileUrlExtractor downloadFileUrlExtractor,
  DownloadFilenameGenerator? filenameBuilder,
  DownloadObserver? observer,
  MultipleFileDownloadCheck canDownloadMultipleFiles,
  Map<String, String> headers,
  Settings settings,
  DownloadService downloader,
  Logger logger,
});

typedef MultipleFileDownloadCheck = bool Function();

class DownloadNotifier extends FamilyNotifier<void, DownloadNotifierParams> {
  @override
  void build(DownloadNotifierParams arg) {
    return;
  }

  Future<PermissionStatus?> _getPermissionStatus() async {
    final perm = await ref.read(deviceStoragePermissionProvider.future);
    return isAndroid() || isIOS() ? perm.storagePermission : null;
  }

  void _showToastIfPossible({String? message}) {
    final context = navigatorKey.currentState?.context;

    if (context != null && context.mounted) {
      showDownloadStartToast(context, message: message);
    }
  }

  Future<DownloadTaskInfo?> download(Post post) async {
    final perm = await _getPermissionStatus();
    final observer = arg.observer;

    final info = await _download(
      ref,
      post,
      params: arg,
      permission: perm,
      onStarted: () {
        final c = navigatorKey.currentState?.context;
        if (c != null) {
          showDownloadStartToast(c);
        }

        observer?.onSingleDownloadStart();
      },
    );

    return info;
  }

  Future<void> bulkDownload(
    List<Post> posts, {
    String? group,
    String? downloadPath,
  }) async {
    // ensure that the booru supports bulk download
    if (!arg.canDownloadMultipleFiles()) {
      final context = navigatorKey.currentState?.context;

      showBulkDownloadUnsupportErrorToast(context);
      return;
    }

    final perm = await _getPermissionStatus();

    _showToastIfPossible(
      message: 'Downloading ${posts.length} files...',
    );

    arg.observer?.onBulkDownloadStart(
      total: posts.length,
    );

    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      await _download(
        ref,
        post,
        params: arg,
        permission: perm,
        group: group,
        downloadPath: downloadPath,
        bulkMetadata: {
          'total': posts.length.toString(),
          'index': i.toString(),
        },
      );
    }
  }
}

Future<DownloadTaskInfo?> _download(
  Ref ref,
  Post downloadable, {
  required DownloadNotifierParams params,
  PermissionStatus? permission,
  String? group,
  String? downloadPath,
  Map<String, String>? bulkMetadata,
  void Function()? onStarted,
}) async {
  final downloadConfig = params.download;
  final service = params.downloader;
  final fileNameBuilder = params.filenameBuilder;
  final logger = params.logger;

  final headers = params.headers;

  final deviceStoragePermissionNotifier = ref.read(
    deviceStoragePermissionProvider.notifier,
  );

  final notificationPermManager = ref.read(
    notificationPermissionManagerProvider,
  );

  final urlData = await params.downloadFileUrlExtractor.getDownloadFileUrl(
    post: downloadable,
    quality: params.settings.downloadQuality.name,
  );

  if (fileNameBuilder == null) {
    logger.error('Single Download', 'No file name builder found, aborting...');
    // if (ref.context.mounted) {
    //   showErrorToast(ref.context, 'Download aborted, cannot create file name');
    // }
    return null;
  }

  if (urlData == null || urlData.url.isEmpty) {
    logger.error('Single Download', 'No download url found, aborting...');
    // if (ref.context.mounted) {
    //   showErrorToast(ref.context, 'Download aborted, no download url found');
    // }
    return null;
  }

  Future<DownloadTaskInfo?> download() async {
    final fileNameFuture = bulkMetadata != null
        ? fileNameBuilder.generateForBulkDownload(
            params.settings,
            downloadConfig,
            downloadable,
            metadata: bulkMetadata,
            downloadUrl: urlData.url,
          )
        : fileNameBuilder.generate(
            params.settings,
            downloadConfig,
            downloadable,
            downloadUrl: urlData.url,
          );

    final fileName = await fileNameFuture;

    final result = await service.download(
      DownloadOptions.fromSettings(
        params.settings,
        config: downloadConfig,
        metadata: DownloaderMetadata(
          thumbnailUrl: downloadable.thumbnailImageUrl,
          fileSize: downloadable.fileSize,
          siteUrl: PostSource.from(downloadable.thumbnailImageUrl).url,
          group: group,
          isVideo: downloadable.isVideo,
        ),
        url: urlData.url,
        filename: fileName,
        headers: {
          ...headers,
          if (urlData.cookie != null)
            AppHttpHeaders.cookieHeader: urlData.cookie!,
        },
        customPath: downloadPath,
      ),
    );

    return switch (result) {
      DownloadSuccess(:final info) => () {
        onStarted?.call();

        return info;
      }(),
      final DownloadFailure e => () {
        final msg = e.error.getErrorMessage();

        logger.error(
          'Single Download',
          msg,
        );

        showDownloadErrorToast(
          navigatorKey.currentState?.context,
          msg,
        );
      }(),
    };
  }

  await notificationPermManager.requestIfNotGranted();

  // Platform doesn't require permissions, just download it right away
  if (permission == null) {
    return download();
  }

  if (permission == PermissionStatus.granted) {
    return download();
  } else {
    logger.info('Single Download', 'Permission not granted, requesting...');
    DownloadTaskInfo? info;

    await deviceStoragePermissionNotifier.requestPermission(
      onDone: (isGranted) async {
        if (isGranted) {
          info = await download();
        } else {
          logger.info(
            'Single Download',
            'Storage permission request denied, aborting...',
          );
        }
      },
    );

    return info;
  }
}

void showDownloadErrorToast(
  BuildContext? context,
  String message,
) {
  if (context == null) return;
  if (!context.mounted) return;

  showErrorToast(
    context,
    duration: const Duration(seconds: 5),
    message,
  );
}

void showDownloadStartToast(BuildContext context, {String? message}) {
  showToast(
    message ?? context.t.download.notification.started,
    context: context,
    position: const ToastPosition(
      align: Alignment.bottomCenter,
    ),
    textPadding: const EdgeInsets.all(12),
    textStyle: TextStyle(color: Theme.of(context).colorScheme.surface),
    backgroundColor: Theme.of(context).colorScheme.onSurface,
  );
}

void showBulkDownloadUnsupportErrorToast(BuildContext? context) {
  if (context == null) return;

  showErrorToast(
    context,
    duration: const Duration(seconds: 3),
    'This booru does not support downloading multiple files',
  );
}
