// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'providers.dart';
import 'zerochan_post.dart';

const kZerochanCustomDownloadFileNameFormat =
    '{id}_{width}x{height}.{extension}';

class ZerochanBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        UnknownMetatagsMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  ZerochanBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat: null,
            ),
            child: CreateAnonConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateAnonConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PostDetailsLayoutSwitcher(
            initialIndex: payload.initialIndex,
            posts: payload.posts,
            scrollController: payload.scrollController,
            desktop: (controller) => ZerochanPostDetailsDesktopPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as ZerochanPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
            mobile: (controller) => ZerochanPostDetailsPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as ZerochanPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
          );

  @override
  TagColorBuilder get tagColorBuilder => (brightness, tagType) {
        final colors =
            brightness.isLight ? TagColors.dark() : TagColors.light();

        return switch (tagType) {
          'mangaka' ||
          'studio' ||
          // This is from a fallback in case the tag is already searched in other boorus
          'artist' =>
            colors.artist,
          'source' ||
          'game' ||
          'visual_novel' ||
          'series' ||
          // This is from a fallback in case the tag is already searched in other boorus
          'copyright' =>
            colors.copyright,
          'character' => colors.character,
          'meta' => colors.meta,
          _ => colors.general,
        };
      };

  @override
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kZerochanCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kZerochanCustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasMd5: false,
    hasRating: false,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
  );
}

class ZerochanPostDetailsPage extends ConsumerWidget {
  const ZerochanPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onPageChanged,
    required this.onExit,
  });

  final List<ZerochanPost> posts;
  final int initialIndex;
  final void Function(int page) onPageChanged;
  final void Function(int page) onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: initialIndex,
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      tagListBuilder: (context, post) => ZerochanTagsTile(post: post),
      onExit: onExit,
      onPageChangeIndexed: onPageChanged,
    );
  }
}

class ZerochanPostDetailsDesktopPage extends ConsumerWidget {
  const ZerochanPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<ZerochanPost> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageDesktopScaffold(
      initialIndex: initialIndex,
      posts: posts,
      onExit: onExit,
      onPageChanged: onPageChanged,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      tagListBuilder: (context, post) => ZerochanTagsTile(post: post),
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
    );
  }
}

class ZerochanTagsTile extends ConsumerStatefulWidget {
  const ZerochanTagsTile({
    super.key,
    required this.post,
    this.onTagsLoaded,
  });

  final Post post;
  final void Function(List<TagGroupItem> tags)? onTagsLoaded;

  @override
  ConsumerState<ZerochanTagsTile> createState() => _ZerochanTagsTileState();
}

class _ZerochanTagsTileState extends ConsumerState<ZerochanTagsTile> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      ref.listen(zerochanTagsFromIdProvider(widget.post.id), (previous, next) {
        next.when(
          data: (data) {
            if (!mounted) return;

            if (data.isNotEmpty) {
              if (widget.onTagsLoaded != null) {
                widget.onTagsLoaded!(createTagGroupItems(data));
              }
            }

            if (data.isEmpty && widget.post.tags.isNotEmpty) {
              // Just a dummy data so the check below will branch into the else block
              setState(() => error = 'No tags found');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            if (!mounted) return;
            setState(() => this.error = error);
          },
        );
      });
    }

    return error == null
        ? TagsTile(
            tags: expanded
                ? ref
                    .watch(zerochanTagsFromIdProvider(widget.post.id))
                    .maybeWhen(
                      data: (data) => createTagGroupItems(data),
                      orElse: () => null,
                    )
                : null,
            post: widget.post,
            onExpand: () => setState(() => expanded = true),
            onCollapse: () {
              // Don't set expanded to false to prevent rebuilding the tags list
              setState(() => error = null);
            },
            onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
          )
        : BasicTagList(
            tags: widget.post.tags.toList(),
            onTap: (tag) => goToSearchPage(context, tag: tag),
          );
  }
}
