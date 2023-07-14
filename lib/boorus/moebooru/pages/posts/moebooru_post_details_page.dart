// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/tags/post_tag_list.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/moebooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/pages/comments/moebooru_comment_item.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'moebooru_information_section.dart';

class MoebooruPostDetailsPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialPage,
    required this.onExit,
  });

  final List<Post> posts;
  final int initialPage;
  final void Function(int page) onExit;

  static MaterialPageRoute routeOf(
    BuildContext context, {
    required List<Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
  }) {
    return MaterialPageRoute(
      builder: (_) {
        return MoebooruProvider(
          builder: (context) => MoebooruPostDetailsPage(
            posts: posts,
            onExit: (page) => scrollController?.scrollToIndex(page),
            initialPage: initialIndex,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<MoebooruPostDetailsPage> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState
    extends ConsumerState<MoebooruPostDetailsPage>
    with PostDetailsPageMixin<MoebooruPostDetailsPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialPage].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<Post> get posts => widget.posts;

  @override
  int get initialPage => widget.initialPage;

  @override
  void initState() {
    super.initState();
    ref.read(tagsProvider.notifier).load(posts[widget.initialPage].tags);
  }

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      controller: controller,
      intitialIndex: widget.initialPage,
      onExit: widget.onExit,
      onPageChanged: (page) {
        ref.read(tagsProvider.notifier).load(posts[page].tags);
        onSwiped(page);
      },
      bottomSheet: (page) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: context.theme.dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (posts[page].isVideo)
                ValueListenableBuilder<VideoProgress>(
                  valueListenable: videoProgress,
                  builder: (_, progress, __) =>
                      BooruVideoProgressBar(progress: progress),
                ),
              MoebooruInformationSection(
                post: posts[page],
              ),
              MoebooruPostActionToolbar(post: posts[page]),
            ],
          ),
        );
      },
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].thumbnailImageUrl,
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets =
            _buildWidgets(context, expanded, page, currentPage, ref);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomScrollView(
            physics: enableSwipe ? null : const NeverScrollableScrollPhysics(),
            controller: PageContentScrollController.of(context),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => widgets[index],
                  childCount: widgets.length,
                ),
              ),
            ],
          ),
        );
      },
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (currentPage, expanded) => [
        GeneralMoreActionButton(
          post: widget.posts[currentPage],
        ),
      ],
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
    WidgetRef ref,
  ) {
    final post = posts[page];
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = post.isVideo
        ? extension(post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.sampleImageUrl,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
                backgroundColor: context.colors.videoPlayerBackgroundColor,
              )
            : BooruVideo(
                url: post.sampleImageUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
        : InteractiveBooruImage(
            useHero: page == currentPage,
            heroTag: "${post.id}_hero",
            aspectRatio: post.aspectRatio,
            imageUrl: post.sampleImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: ref.watch(previewImageCacheManagerProvider),
            width: post.width,
            height: post.height,
            onZoomUpdated: onZoomUpdated,
          );

    return [
      if (!expandedOnCurrentPage)
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else if (post.isVideo)
        BooruImage(
          imageUrl: post.thumbnailImageUrl,
          fit: BoxFit.contain,
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        MoebooruInformationSection(post: post),
        const Divider(
          thickness: 1.5,
          height: 4,
        ),
        FileDetailsSection(
          post: post,
        ),
        const Divider(
          thickness: 1.5,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: PostTagList(
            tags: ref.watch(tagsProvider),
            onTap: (tag) => goToMoebooruSearchPage(
              ref,
              context,
              tag: tag.rawName,
            ),
          ),
        ),
        post.source.whenWeb(
          (source) => SourceSection(source: source),
          () => const SizedBox.shrink(),
        ),
        ref.watch(moebooruCommentsProvider(post.id)).when(
              data: (comments) => comments.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(
                            thickness: 1.5,
                          ),
                          Text(
                            'comment.comments'.tr(),
                            style: context.textTheme.titleLarge!.copyWith(
                              color: context.theme.hintColor,
                              fontSize: 16,
                            ),
                          ),
                          ...comments
                              .map((comment) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child:
                                        MoebooruCommentItem(comment: comment),
                                  ))
                              .toList()
                        ],
                      ),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (e, __) => const SizedBox.shrink(),
            ),
      ],
    ];
  }
}
