// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../images/providers.dart';
import '../../../details/widgets.dart';
import '../../../post/types.dart';
import '../../providers.dart';

class QuickPreviewImageDialog extends ConsumerWidget {
  const QuickPreviewImageDialog({
    super.key,
    required this.post,
    required this.config,
  });

  final Post post;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridThumbnailUrlBuilder = ref.watch(
      gridThumbnailUrlGeneratorProvider(config),
    );
    final placeholderImageUrl = gridThumbnailUrlBuilder.generateUrl(
      post,
      settings: ref.watch(gridThumbnailSettingsProvider(config)),
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.85,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                ),
                child: RawPostDetailsImage(
                  imageUrlBuilder: (post) => post.isVideo
                      ? post.videoThumbnailUrl
                      : post.sampleImageUrl,
                  thumbnailUrlBuilder: (post) => placeholderImageUrl,
                  imageCacheManager: ref.watch(
                    defaultImageCacheManagerProvider,
                  ),
                  post: post,
                  config: config,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
