// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../downloads/filename/providers.dart';
import '../../../downloads/filename/types.dart';
import '../../../images/providers.dart';
import '../../../widgets/booru_tooltip.dart';
import '../../post/types.dart';
import 'providers.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    required this.post,
    required this.auth,
    required this.configViewer,
    required this.download,
    this.filenameBuilder,
    this.imageCacheManager,
    super.key,
  });

  final Post post;
  final BooruConfigAuth auth;
  final BooruConfigViewer configViewer;
  final BooruConfigDownload download;
  final DownloadFilenameGenerator? filenameBuilder;
  final ImageCacheManager? imageCacheManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultImageCacheManager = ref.watch(
      defaultImageCacheManagerProvider,
    );
    final effectiveDownloadFilenameBuilder =
        filenameBuilder ??
        ref.watch(
          downloadFilenameBuilderProvider(auth),
        );

    return BooruTooltip(
      message: context.t.post.action.share,
      child: IconButton(
        splashRadius: 16,
        onPressed: () => ref
            .read(shareProvider)
            .sharePost(
              post,
              auth,
              context: context,
              configViewer: configViewer,
              download: download,
              filenameBuilder: effectiveDownloadFilenameBuilder,
              imageCacheManager: imageCacheManager ?? defaultImageCacheManager,
            ),
        icon: const Icon(Symbols.share),
      ),
    );
  }
}
