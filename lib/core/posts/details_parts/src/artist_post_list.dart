// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../router.dart';
import '../../../tags/tag/providers.dart';
import '../../../widgets/booru_visibility_detector.dart';
import '../../details/providers.dart';
import '../../details/types.dart';
import '../../listing/providers.dart';
import '../../post/types.dart';
import 'sliver_details_post_list.dart';

class DefaultInheritedArtistPostsSection<T extends Post>
    extends ConsumerStatefulWidget {
  const DefaultInheritedArtistPostsSection({
    super.key,
    this.limit,
    this.filterQuery,
  });

  final PreviewLimit? limit;
  final PostFilterQuery<T>? filterQuery;

  @override
  ConsumerState<DefaultInheritedArtistPostsSection<T>> createState() =>
      _DefaultInheritedArtistPostsSectionState<T>();
}

class _DefaultInheritedArtistPostsSectionState<T extends Post>
    extends ConsumerState<DefaultInheritedArtistPostsSection<T>> {
  final Map<String, VisibilityController> _visControllers = {};

  @override
  void dispose() {
    for (final controller in _visControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  VisibilityController _getController(String tag) {
    return _visControllers.putIfAbsent(tag, () => VisibilityController());
  }

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<T>(context);
    final auth = ref.watchConfigAuth;

    final thumbUrlBuilder = ref.watch(gridThumbnailUrlGeneratorProvider(auth));
    final thumbSettings = ref.watch(gridThumbnailSettingsProvider(auth));
    final effectiveLimit = widget.limit ?? const LimitedPreview.progressive();

    return MultiSliver(
      children: ref
          .watch(artistCharacterGroupProvider((post: post, auth: auth)))
          .maybeWhen(
            data: (data) => data.artistTags.isNotEmpty
                ? data.artistTags.expand(
                    (tag) {
                      final controller = _getController(tag);
                      return [
                        SliverToBoxAdapter(
                          child: BooruVisibilityDetector(
                            childKey: Key('artist-posts-$tag'),
                            controller: controller,
                          ),
                        ),
                        SliverDetailsPostList(
                          tag: tag,
                          subtitle: context.t.post.detail.artist,
                          onTap: () => _goToArtistPage(tag),
                          child: ListenableBuilder(
                            listenable: controller,
                            builder: (context, child) => controller.isVisible
                                ? ref
                                      .watch(
                                        detailsPostsProvider(
                                          (
                                            ref.watchConfigFilter,
                                            ref.watchConfigSearch,
                                            tag,
                                            widget.filterQuery ??
                                                postFilterQueryNone,
                                          ),
                                        ),
                                      )
                                      .maybeWhen(
                                        data: (data) => data.isNotEmpty
                                            ? SliverPreviewPostGrid(
                                                auth: auth,
                                                posts: data,
                                                limit: effectiveLimit,
                                                imageUrl: (p) =>
                                                    thumbUrlBuilder.generateUrl(
                                                      p,
                                                      settings: thumbSettings,
                                                    ),
                                                onShowAll: () =>
                                                    _goToArtistPage(tag),
                                              )
                                            : const SliverSizedBox(),
                                        orElse: () =>
                                            SliverPreviewPostGridPlaceholder(
                                              limit: effectiveLimit,
                                            ),
                                      )
                                : SliverPreviewPostGridPlaceholder(
                                    limit: effectiveLimit,
                                  ),
                          ),
                        ),
                      ];
                    },
                  ).toList()
                : [],
            orElse: () => [
              SliverPreviewPostGridPlaceholder(
                limit: effectiveLimit,
              ),
            ],
          ),
    );
  }

  void _goToArtistPage(String tag) {
    goToArtistPage(ref, tag);
  }
}
