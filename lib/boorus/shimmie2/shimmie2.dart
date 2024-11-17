// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/shimmie2/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/router.dart';

class Shimmie2Builder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultTagColorMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  Shimmie2Builder();

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
      (context, config, payload) {
        final posts = payload.posts.map((e) => e as Shimmie2Post).toList();

        return PostDetailsLayoutSwitcher(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          desktop: () => const Shimmie2PostDetailsDesktopPage(),
          mobile: () => const Shimmie2PostDetailsPage(),
        );
      };

  @override
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasRating: false,
    extensionHandler: (post, config) =>
        post.format.startsWith('.') ? post.format.substring(1) : post.format,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
  );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder();
}

class Shimmie2PostDetailsDesktopPage extends ConsumerWidget {
  const Shimmie2PostDetailsDesktopPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<Shimmie2Post>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageDesktopScaffold(
      controller: controller,
      debounceDuration: Duration.zero,
      posts: posts,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      tagListBuilder: (context, post) => BasicTagList(
        tags: post.tags.toList(),
        unknownCategoryColor: ref.watch(tagColorProvider('general')),
        onTap: (tag) => goToSearchPage(context, tag: tag),
      ),
      fileDetailsBuilder: (context, post) => DefaultFileDetailsSection(
        post: post,
        uploaderName: castOrNull<SimplePost>(post)?.uploaderName,
      ),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
    );
  }
}

class Shimmie2PostDetailsPage extends ConsumerWidget {
  const Shimmie2PostDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<Shimmie2Post>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      tagListBuilder: (context, post) => BasicTagList(
        tags: post.tags.toList(),
        unknownCategoryColor: ref.watch(tagColorProvider('general')),
        onTap: (tag) => goToSearchPage(context, tag: tag),
      ),
      fileDetailsBuilder: (context, post) => DefaultFileDetailsSection(
        post: post,
        uploaderName: castOrNull<SimplePost>(post)?.uploaderName,
      ),
    );
  }
}
