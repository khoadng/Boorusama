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
import '../../details/providers.dart';
import '../../details/types.dart';
import '../../listing/providers.dart';
import 'sliver_details_post_list.dart';

class UploaderPostsSection extends ConsumerWidget {
  const UploaderPostsSection({
    super.key,
    this.limit,
    required this.query,
  });

  final PreviewLimit? limit;
  final UploaderQuery? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watchConfigAuth;

    final thumbUrlBuilder = ref.watch(gridThumbnailUrlGeneratorProvider(auth));
    final thumbSettings = ref.watch(gridThumbnailSettingsProvider(auth));
    final effectiveLimit = limit ?? const LimitedPreview.defaults();

    return MultiSliver(
      children: [
        if (query case final q?)
          SliverDetailsPostList(
            onTap: () {
              goToSearchPage(ref, tag: q.resolveTag());
            },
            tag: q.resolveDisplayName(),
            subtitle: context.t.post.detail.uploader,
            child: ref
                .watch(
                  detailsUploadersPostsProvider(
                    (
                      ref.watchConfigFilter,
                      ref.watchConfigSearch,
                      q.resolveTag(),
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
                        )
                      : const SliverSizedBox(),
                  orElse: () => SliverPreviewPostGridPlaceholder(
                    limit: effectiveLimit,
                  ),
                ),
          ),
      ],
    );
  }
}
