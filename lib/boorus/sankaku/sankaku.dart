// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/boorus/sankaku/create_sankaku_config_page.dart';
import 'package:boorusama/boorus/sankaku/sankaku_home_page.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/create.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/downloads/filename.dart';
import 'package:boorusama/core/downloads/urls.dart';
import 'package:boorusama/core/http/providers.dart';
import 'package:boorusama/core/posts/details/details.dart';
import 'package:boorusama/core/posts/details/parts.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/posts/rating/rating.dart';
import 'package:boorusama/core/posts/sources/source.dart';
import 'package:boorusama/core/scaffolds/artist_page_scaffold.dart';
import 'package:boorusama/core/search/query_composer_providers.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import 'package:boorusama/core/tags/categories/tag_category.dart';
import 'package:boorusama/core/tags/groups/item.dart';
import 'package:boorusama/core/tags/tag/display.dart';
import 'package:boorusama/core/tags/tag/filter_category.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/foundation/caching.dart';
import 'package:boorusama/router.dart';
import '../booru_builder_default.dart';
import '../booru_builder_types.dart';
import 'sankaku_post.dart';

part 'sankaku_provider.dart';

class SankakuBuilder
    with
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultHomeMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  SankakuBuilder();

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
              customDownloadFileNameFormat:
                  kBoorusamaCustomDownloadFileNameFormat,
            ),
            child: CreateSankakuConfigPage(
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
            child: CreateSankakuConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder => (context) => const SankakuHomePage();

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as SankakuPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<SankakuPost>(),
        );
      };

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => SankakuArtistPage(
            artistName: artistName,
          );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const SankakuFavoritesPage();

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder<SankakuPost>(
    defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat:
        kBoorusamaBulkDownloadCustomFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'artist': (post, config) => post.artistTags.join(' '),
      'character': (post, config) => post.characterTags.join(' '),
      'copyright': (post, config) => post.copyrightTags.join(' '),
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'mpixels': (post, config) => post.mpixels.toString(),
      'aspect_ratio': (post, config) => post.aspectRatio.toString(),
      'source': (post, config) => sanitizedUrl(config.downloadUrl),
    },
  );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<SankakuPost>(
            showSource: true,
          ),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<SankakuPost>(),
    },
    full: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<SankakuPost>(
            showSource: true,
          ),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<SankakuPost>(),
      DetailsPart.tags: (context) => const SankakuTagsTile(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<SankakuPost>(),
      DetailsPart.artistPosts: (context) => const SankakuArtistPostsSection(),
    },
  );
}

class SankakuArtistPostsSection extends ConsumerWidget {
  const SankakuArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SankakuPost>(context);

    return MultiSliver(
      children: post.artistTags.isNotEmpty
          ? post.artistTags
              .map((tag) => SliverArtistPostList(
                    tag: tag,
                    child: ref
                        .watch(sankakuArtistPostsProvider(
                            post.artistTags.firstOrNull))
                        .maybeWhen(
                          data: (data) => SliverPreviewPostGrid(
                            posts: data,
                            onTap: (postIdx) => goToPostDetailsPageFromPosts(
                              context: context,
                              posts: data,
                              initialIndex: postIdx,
                            ),
                            imageUrl: (item) => item.sampleImageUrl,
                          ),
                          orElse: () =>
                              const SliverPreviewPostGridPlaceholder(),
                        ),
                  ))
              .toList()
          : [],
    );
  }
}

class SankakuTagsTile extends StatelessWidget {
  const SankakuTagsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<SankakuPost>(context);

    return SliverToBoxAdapter(
      child: TagsTile(
        post: post,
        initialExpanded: true,
        tags: createTagGroupItems([
          ...post.artistDetailsTags,
          ...post.characterDetailsTags,
          ...post.copyrightDetailsTags,
        ]),
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
      ),
    );
  }
}

class SankakuArtistPage extends ConsumerWidget {
  const SankakuArtistPage({
    super.key,
    required this.artistName,
  });

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return ArtistPageScaffold(
      artistName: artistName,
      fetcher: (page, selectedCategory) =>
          ref.read(sankakuArtistPostRepo(config)).getPosts(
                [
                  artistName,
                  if (selectedCategory == TagFilterCategory.popular)
                    'order:score',
                ].join(' '),
                page,
              ),
    );
  }
}
