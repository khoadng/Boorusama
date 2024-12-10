// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus.dart';
import '../../core/boorus/providers.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/details.dart';
import '../../core/posts/details/parts.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/scaffolds/artist_page_scaffold.dart';
import '../../core/search/query_composer_providers.dart';
import '../../core/settings/data/listing_provider.dart';
import '../../core/tags/categories/tag_category.dart';
import '../../core/tags/tag/tag.dart';
import '../../foundation/caching.dart';
import '../../router.dart';
import '../booru_builder.dart';
import '../booru_builder_default.dart';
import '../booru_builder_types.dart';
import '../danbooru/danbooru.dart';
import '../providers.dart';
import 'create_sankaku_config_page.dart';
import 'sankaku_home_page.dart';
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
              .map(
                (tag) => SliverArtistPostList(
                  tag: tag,
                  child: ref
                      .watch(
                        sankakuArtistPostsProvider(
                          post.artistTags.firstOrNull,
                        ),
                      )
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
                        orElse: () => const SliverPreviewPostGridPlaceholder(),
                      ),
                ),
              )
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
