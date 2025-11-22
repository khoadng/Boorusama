// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../search/search/routes.dart';
import '../../../widgets/booru_visibility_detector.dart';
import '../../details/providers.dart';
import '../../details/types.dart';
import '../../listing/providers.dart';
import '../../post/types.dart';
import 'sliver_details_post_list.dart';

class UploaderPostsSection<T extends Post> extends ConsumerStatefulWidget {
  const UploaderPostsSection({
    super.key,
    this.limit,
    this.filterQuery,
    required this.query,
  });

  final PreviewLimit? limit;
  final UploaderQuery? query;
  final PostFilterQuery<T>? filterQuery;

  @override
  ConsumerState<UploaderPostsSection<T>> createState() =>
      _UploaderPostsSectionState<T>();
}

class _UploaderPostsSectionState<T extends Post>
    extends ConsumerState<UploaderPostsSection<T>> {
  late final VisibilityController _visController;

  @override
  void initState() {
    super.initState();
    _visController = VisibilityController();
  }

  @override
  void dispose() {
    _visController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watchConfigAuth;

    final thumbUrlBuilder = ref.watch(gridThumbnailUrlGeneratorProvider(auth));
    final thumbSettings = ref.watch(gridThumbnailSettingsProvider(auth));
    final effectiveLimit = widget.limit ?? const LimitedPreview.progressive();

    return MultiSliver(
      children: [
        if (widget.query case final q?)
          SliverToBoxAdapter(
            child: BooruVisibilityDetector(
              childKey: Key('uploader-posts-${q.resolveTag()}'),
              controller: _visController,
            ),
          ),
        if (widget.query case final q?)
          SliverDetailsPostList(
            onTap: () {
              _goToUploaderPage(q);
            },
            tag: q.resolveDisplayName(),
            subtitle: context.t.post.detail.uploader,
            child: ListenableBuilder(
              listenable: _visController,
              builder: (context, child) => _visController.isVisible
                  ? ref
                        .watch(
                          detailsPostsProvider(
                            (
                              ref.watchConfigFilter,
                              ref.watchConfigSearch,
                              q.resolveTag(),
                              widget.filterQuery ?? postFilterQueryNone,
                            ),
                          ),
                        )
                        .maybeWhen(
                          data: (data) => data.isNotEmpty
                              ? SliverPreviewPostGrid(
                                  posts: data,
                                  auth: auth,
                                  limit: effectiveLimit,
                                  imageUrl: (p) => thumbUrlBuilder.generateUrl(
                                    p,
                                    settings: thumbSettings,
                                  ),
                                  onShowAll: () => _goToUploaderPage(q),
                                )
                              : const SliverSizedBox(),
                          orElse: () => SliverPreviewPostGridPlaceholder(
                            limit: effectiveLimit,
                          ),
                        )
                  : SliverPreviewPostGridPlaceholder(
                      limit: effectiveLimit,
                    ),
            ),
          ),
      ],
    );
  }

  void _goToUploaderPage(UploaderQuery query) {
    goToSearchPage(ref, tag: query.resolveTag());
  }
}
