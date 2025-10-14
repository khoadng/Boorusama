// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../configs/config/types.dart';
import '../../../downloads/filename/types.dart';
import '../../post/types.dart';
import 'post_modal_share.dart';

final shareProvider = Provider.autoDispose((ref) => ShareService(ref));

class ShareService {
  ShareService(this.ref);

  final Ref ref;

  void sharePost(
    Post post,
    BooruConfigAuth config, {
    required BuildContext context,
    required BooruConfigViewer configViewer,
    required BooruConfigDownload download,
    required DownloadFilenameGenerator? filenameBuilder,
    required ImageCacheManager imageCacheManager,
  }) {
    final modal = PostModalShare(
      post: post,
      auth: config,
      viewer: configViewer,
      download: download,
      filenameBuilder: filenameBuilder,
      imageCacheManager: imageCacheManager,
    );

    const routeSettings = RouteSettings(name: 'post_share');

    Screen.of(context).size == ScreenSize.small
        ? showModalBottomSheet(
            context: context,
            routeSettings: routeSettings,
            builder: (context) => modal,
          )
        : showDialog(
            context: context,
            routeSettings: routeSettings,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: modal,
            ),
          );
  }
}
