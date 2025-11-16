// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../posts/details/providers.dart';
import '../../../posts/post/types.dart';
import '../../_shared/tag_list_notifier.dart';
import 'providers/providers.dart';
import 'providers/tag_edit_notifier.dart';
import 'tag_edit_content.dart';
import 'tag_edit_page_scaffold.dart';
import 'widgets/tag_edit_rating_selector_section.dart';
import 'widgets/tag_edit_submit_button.dart';

class DanbooruTagEditPage extends ConsumerStatefulWidget {
  const DanbooruTagEditPage({
    required this.post,
    super.key,
  });

  final DanbooruPost post;

  @override
  ConsumerState<DanbooruTagEditPage> createState() =>
      _DanbooruTagEditPageState();
}

class _DanbooruTagEditPageState extends ConsumerState<DanbooruTagEditPage> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final viewer = ref.watchConfigViewer;
    final tags = ref.watch(danbooruTagListProvider(config));
    final initialRating = tags.containsKey(widget.post.id)
        ? tags[widget.post.id]!.rating
        : widget.post.rating;
    final effectiveTags = tags.containsKey(widget.post.id)
        ? tags[widget.post.id]!.allTags
        : widget.post.tags.toSet();
    final mediaResolver = ref.watch(danbooruMediaUrlResolverProvider(config));
    final gridThumbnailSettings = ref.watch(
      gridThumbnailSettingsProvider(config),
    );
    final gridThumbnailUrlGenerator = ref.watch(
      gridThumbnailUrlGeneratorProvider(config),
    );
    final placeholderUrl = gridThumbnailUrlGenerator.generateUrl(
      widget.post,
      settings: gridThumbnailSettings,
    );

    return TagEditParamsProvider(
      params: TagEditParams(
        initialTags: effectiveTags,
        postId: widget.post.id,
        imageAspectRatio: widget.post.aspectRatio ?? 1,
        imageUrl: mediaResolver.resolveMediaUrl(widget.post, viewer),
        placeholderUrl: placeholderUrl,
        initialRating: initialRating,
        post: widget.post,
      ),
      child: TagEditPageScaffold(
        scrollController: scrollController,
        content: TagEditContent(
          ratingSelector: TagEditRatingSelectorSection(
            rating: initialRating,
            onChanged: (value) {
              ref
                      .read(
                        selectedTagEditRatingProvider(initialRating).notifier,
                      )
                      .state =
                  value;
            },
          ),
          scrollController: scrollController,
        ),
        submitButton: const TagEditSubmitButton(),
      ),
    );
  }
}
