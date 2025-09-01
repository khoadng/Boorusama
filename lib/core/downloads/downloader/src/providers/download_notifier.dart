// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../../foundation/loggers/providers.dart';
import '../../../../../foundation/permissions.dart';
import '../../../../../foundation/platform.dart';
import '../../../../../foundation/toast.dart';
import '../../../../analytics/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../http/http.dart';
import '../../../../http/providers.dart';
import '../../../../posts/post/post.dart';
import '../../../../posts/sources/source.dart';
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../filename/types.dart';
import '../../../urls/providers.dart';
import '../../../urls/types.dart';
import '../types/download.dart';
import '../types/metadata.dart';
import 'service_provider.dart';

final downloadNotifierProvider =
    NotifierProvider.family<DownloadNotifier, void, DownloadNotifierParams>(
      DownloadNotifier.new,
    );

typedef DownloadNotifierParams = ({
  BooruConfigAuth auth,
  BooruConfigDownload download,
  DownloadFilenameGenerator? filenameBuilder,
});

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
    final auth = arg.auth;
    final settings = ref.read(settingsProvider);
    final urlExtractor = ref.read(
      downloadFileUrlExtractorProvider(auth),
    );
    final perm = await _getPermissionStatus();
    final analyticsAsync = ref.read(analyticsProvider);

    final info = await _download(
      ref,
      post,
      params: arg,
      permission: perm,
      settings: settings,
      downloadFileUrlExtractor: urlExtractor,
      onStarted: () {
        final c = navigatorKey.currentState?.context;
        if (c != null) {
          showDownloadStartToast(c);
        }

        analyticsAsync.whenData(
          (analytics) {
            analytics?.logEvent(
              'single_download_start',
              parameters: {
                'hint_site': auth.booruType.name,
                'url': Uri.tryParse(auth.url)?.host,
              },
            );
          },
        );
      },
    );

    return info;
  }

  Future<void> bulkDownload(
    List<Post> posts, {
    String? group,
    String? downloadPath,
  }) async {
    final settings = ref.read(settingsProvider);
    final config = arg.auth;
    final urlExtractor = ref.read(downloadFileUrlExtractorProvider(config));
    final analyticsAsync = ref.read(analyticsProvider);

    // ensure that the booru supports bulk download
    if (!config.booruType.canDownloadMultipleFiles) {
      final context = navigatorKey.currentState?.context;

      showBulkDownloadUnsupportErrorToast(context);
      return;
    }

    final perm = await _getPermissionStatus();

    _showToastIfPossible(
      message: 'Downloading ${posts.length} files...',
    );

    analyticsAsync.whenData(
      (analytics) {
        analytics?.logEvent(
          'multiple_download_start',
          parameters: {
            'total': posts.length,
            'hint_site': config.booruType.name,
            'url': Uri.tryParse(config.url)?.host,
          },
        );
      },
    );

    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      await _download(
        ref,
        post,
        params: arg,
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

Future<DownloadTaskInfo?> _download(
  Ref ref,
  Post downloadable, {
  required Settings settings,
  required DownloadFileUrlExtractor downloadFileUrlExtractor,
  required DownloadNotifierParams params,
  PermissionStatus? permission,
  String? group,
  String? downloadPath,
  Map<String, String>? bulkMetadata,
  void Function()? onStarted,
}) async {
  final auth = params.auth;
  final downloadConfig = params.download;
  final service = ref.read(downloadServiceProvider);
  final fileNameBuilder = params.filenameBuilder;
  final logger = ref.read(loggerProvider);

  final headers = ref.read(httpHeadersProvider(auth));

  final deviceStoragePermissionNotifier = ref.read(
    deviceStoragePermissionProvider.notifier,
  );

  final notificationPermManager = ref.read(
    notificationPermissionManagerProvider,
  );

  final urlData = await downloadFileUrlExtractor.getDownloadFileUrl(
    post: downloadable,
    quality: settings.downloadQuality.name,
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
    onStarted?.call();

    final fileNameFuture = bulkMetadata != null
        ? fileNameBuilder.generateForBulkDownload(
            settings,
            downloadConfig,
            downloadable,
            metadata: bulkMetadata,
            downloadUrl: urlData.url,
          )
        : fileNameBuilder.generate(
            settings,
            downloadConfig,
            downloadable,
            downloadUrl: urlData.url,
          );

    final fileName = await fileNameFuture;

    final result = await service
        .downloadWithSettings(
          settings,
          config: downloadConfig,
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

    return result.fold(
      (e) => null,
      (info) => info,
    );
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
