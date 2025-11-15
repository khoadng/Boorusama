// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../router.dart';
import '../../../tags/tag/providers.dart';
import '../../details/providers.dart';
import '../../details/types.dart';
import '../../listing/providers.dart';
import '../../post/types.dart';
import 'sliver_details_post_list.dart';

class DefaultInheritedArtistPostsSection<T extends Post>
    extends ConsumerWidget {
  const DefaultInheritedArtistPostsSection({
    super.key,
    this.limit,
  });

  final PreviewLimit? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<T>(context);
    final auth = ref.watchConfigAuth;

    final thumbUrlBuilder = ref.watch(gridThumbnailUrlGeneratorProvider(auth));
    final thumbSettings = ref.watch(gridThumbnailSettingsProvider(auth));
    final effectiveLimit = limit ?? const LimitedPreview.defaults();

    return MultiSliver(
      children: ref
          .watch(artistCharacterGroupProvider((post: post, auth: auth)))
          .maybeWhen(
            data: (data) => data.artistTags.isNotEmpty
                ? data.artistTags
                      .map(
                        (tag) => SliverDetailsPostList(
                          tag: tag,
                          onTap: () => goToArtistPage(ref, tag),
                          child: ref
                              .watch(
                                detailsArtistPostsProvider(
                                  (
                                    ref.watchConfigFilter,
                                    ref.watchConfigSearch,
                                    tag,
                                  ),
                                ),
                              )
                              .maybeWhen(
                                data: (data) => SliverPreviewPostGrid(
                                  auth: auth,
                                  posts: data,
                                  limit: effectiveLimit,
                                  imageUrl: (p) => thumbUrlBuilder.generateUrl(
                                    p,
                                    settings: thumbSettings,
                                  ),
                                ),
                                orElse: () =>
                                    const SliverPreviewPostGridPlaceholder(),
                              ),
                        ),
                      )
                      .toList()
                : [],
            orElse: () => [
              const SliverPreviewPostGridPlaceholder(),
            ],
          ),
    );
  }
}
