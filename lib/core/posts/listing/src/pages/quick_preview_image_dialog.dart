// Flutter imports:
import 'package:flutter/material.dart';

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

    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: size.height * 0.85,
              maxWidth: size.width * 0.85,
            ),
            child: RawPostDetailsImage(
              imageUrlBuilder: (post) =>
                  post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
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
    );
  }
}
