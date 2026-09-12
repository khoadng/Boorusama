// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../../foundation/permissions.dart';
import '../../../../../foundation/platform.dart';
import '../../../../configs/config/types.dart';
import '../../../../ddos/handler/providers.dart';
import '../../../../download_activity/activity.dart';
import '../../../../http/client/types.dart';
import '../../../../posts/post/types.dart';
import '../../../../posts/post/providers.dart';
import '../../../sidecar/types.dart';
import '../../../../router.dart';
import '../../../../settings/types.dart';
import '../../../filename/types.dart';
import '../../../urls/types.dart';
import '../types/download.dart';
import '../types/metadata.dart';
import '../types/download_network_policy.dart';
import '../types/observer.dart';
import 'download_network_policy_provider.dart';

final downloadNotifierProvider =
    NotifierProvider.family<DownloadNotifier, void, DownloadNotifierParams>(
      DownloadNotifier.new,
    );

typedef DownloadNotifierParams = ({
  BooruConfigAuth auth,
  BooruConfigDownload download,
  String? profileIconUrl,
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

  Future<DownloadTaskInfo?> download(
    Post post, {
    String? overrideUrl,
  }) async {
    final perm = await _getPermissionStatus();
    final observer = arg.observer;

    final info = await _download(
      ref,
      post,
      params: arg,
      permission: perm,
      overrideUrl: overrideUrl,
      onStarted: () {
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
    final networkConstraint = await resolveDownloadNetworkConstraint(
      ref,
      arg.settings.downloadNetworkPolicy,
    );
    if (networkConstraint == null) return;

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
        networkConstraint: networkConstraint,
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
  //FIXME: bad solution, need better design
  String? overrideUrl,
  DownloadNetworkConstraint? networkConstraint,
}) async {
  final downloadConfig = params.download;
  final service = params.downloader;
  final fileNameBuilder = params.filenameBuilder;
  final logger = params.logger;

  final headers = params.headers;

  final deviceStoragePermissionNotifier = ref.read(
    deviceStoragePermissionProvider.notifier,
  );

  final extractedUrlData = await params.downloadFileUrlExtractor
      .getDownloadFileUrl(
        post: downloadable,
        quality: params.settings.downloadQuality.name,
      );

  final urlData = overrideUrl != null
      ? DownloadUrlData(
          url: overrideUrl,
          cookie: null,
        )
      : extractedUrlData;

  if (fileNameBuilder == null) {
    logger.error('Single Download', 'No file name builder found, aborting...');
    // if (ref.context.mounted) {
    //   Kurumi.showErrorToast(ref.context, 'Download aborted, cannot create file name');
    // }
    return null;
  }

  if (urlData == null || urlData.url.isEmpty) {
    logger.error('Single Download', 'No download url found, aborting...');
    // if (ref.context.mounted) {
    //   Kurumi.showErrorToast(ref.context, 'Download aborted, no download url found');
    // }
    return null;
  }

  final resolvedNetworkConstraint =
      networkConstraint ??
      await resolveDownloadNetworkConstraint(
        ref,
        params.settings.downloadNetworkPolicy,
      );
  if (resolvedNetworkConstraint == null) return null;

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

    final bypassHeaders = await ref.read(
      bypassDdosHeadersProvider(urlData.url).future,
    );

    final result = await service.download(
      DownloadOptions.fromSettings(
        params.settings,
        config: downloadConfig,
        sidecar: params.settings.downloadSidecarFormat == SidecarFormat.off
            ? null
            : SidecarSnapshot.fromPost(
                downloadable,
                format: params.settings.downloadSidecarFormat,
                quality: params.settings.downloadQuality.name,
                site: params.auth.url,
                postUrl: ref
                    .read(postLinkGeneratorProvider(params.auth))
                    .getLink(downloadable),
              ),
        metadata: DownloaderMetadata(
          thumbnailUrl: downloadable.thumbnailImageUrl,
          fileSize: downloadable.fileSize,
          siteUrl: params.auth.url,
          profileIconUrl: params.profileIconUrl,
          group: group,
          isVideo: downloadable.isVideo,
        ),
        url: urlData.url,
        filename: fileName,
        headers: {
          ...headers,
          ...bypassHeaders,
          if (urlData.cookie != null)
            AppHttpHeaders.cookieHeader: urlData.cookie!,
        },
        customPath: downloadPath,
        networkConstraint: resolvedNetworkConstraint,
      ),
    );

    ref
        .read(immediateDownloadActivitiesProvider.notifier)
        .recordImmediateOutcome(
          result,
          label: fileName,
          thumbnailUrl: downloadable.thumbnailImageUrl,
        );

    return switch (result) {
      DownloadEnqueued(:final info) => () {
        onStarted?.call();

        return info;
      }(),
      DownloadCompleted(:final info) => () {
        onStarted?.call();
        return info;
      }(),
      DownloadSkipped(:final info) => () {
        onStarted?.call();
        return info;
      }(),
      final DownloadFailure e => () {
        final msg = e.error.getErrorMessage();

        logger.error(
          'Single Download',
          'Download failed: ${e.error.runtimeType}',
          sensitiveMessage: msg,
        );
      }(),
    };
  }

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

  Kurumi.showErrorToast(
    context,
    duration: const Duration(seconds: 5),
    message,
  );
}

void showDownloadStartToast(BuildContext context, {String? message}) {
  final colorScheme = Theme.of(context).colorScheme;

  showToast(
    message ?? context.t.download.notification.started,
    position: ToastPosition.bottom,
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 60,
    ),
    textPadding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: colorScheme.surfaceContainerHigh,
    textStyle: TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );
}

void showBulkDownloadUnsupportErrorToast(BuildContext? context) {
  if (context == null) return;

  Kurumi.showErrorToast(
    context,
    duration: const Duration(seconds: 3),
    'This booru does not support downloading multiple files',
  );
}
