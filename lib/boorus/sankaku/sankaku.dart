// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/boorus/sankaku/create_sankaku_config_page.dart';
import 'package:boorusama/boorus/sankaku/sankaku_home_page.dart';
import 'package:boorusama/clients/sankaku/sankaku_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/artist_page_scaffold.dart';
import 'package:boorusama/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'sankaku_post.dart';

part 'sankaku_provider.dart';

class SankakuBuilder
    with
        PostCountNotSupportedMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  SankakuBuilder({
    required this.postRepository,
    required this.autocompleteRepo,
  });

  final PostRepository<SankakuPost> postRepository;
  final AutocompleteRepository autocompleteRepo;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateSankakuConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat:
                  kBoorusamaCustomDownloadFileNameFormat,
            ),
            backgroundColor: backgroundColor,
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateSankakuConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => const SankakuHomePage();

  @override
  PostFetcher get postFetcher =>
      (tags, page, {limit}) => postRepository.getPosts(page, tags);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) {
        final posts = payload.posts.map((e) => e as SankakuPost).toList();
        final initialIndex = payload.initialIndex;
        final scrollController = payload.scrollController;

        return BooruProvider(
          builder: (booruBuilder, ref) => PostDetailsPageScaffold(
            posts: posts,
            initialIndex: initialIndex,
            swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
            infoBuilder: (context, post) => SimpleInformationSection(
              post: post,
              showSource: true,
            ),
            sourceSectionBuilder: (context, post) => const SizedBox.shrink(),
            sliverArtistPostsBuilder: (context, post) =>
                post.artistTags.isNotEmpty
                    ? ArtistPostList(
                        artists: post.artistTags,
                        builder: (tag) => ref
                            .watch(sankakuArtistPostsProvider(
                                post.artistTags.firstOrNull))
                            .maybeWhen(
                              data: (data) => PreviewPostGrid(
                                posts: data,
                                onTap: (postIdx) => goToPostDetailsPage(
                                  context: context,
                                  posts: data,
                                  initialIndex: postIdx,
                                ),
                                imageUrl: (item) => item.sampleImageUrl,
                              ),
                              orElse: () => const PreviewPostGridPlaceholder(
                                imageCount: 30,
                              ),
                            ),
                      )
                    : const SliverSizedBox.shrink(),
            tagListBuilder: (context, post) => TagsTile(
              post: post,
              initialExpanded: true,
              tags: createTagGroupItems([
                ...post.artistDetailsTags,
                ...post.characterDetailsTags,
                ...post.copyrightDetailsTags,
              ]),
              onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
            ),
            onExit: (page) => scrollController?.scrollToIndex(page),
            onTagTap: (tag) => goToSearchPage(context, tag: tag),
          ),
        );
      };

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => SankakuArtistPage(
            artistName: artistName,
          );

  @override
  FavoriteAdder? get favoriteAdder => null;

  @override
  FavoriteChecker? get favoriteChecker => null;

  @override
  FavoriteRemover? get favoriteRemover => null;

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.hasLoginDetails()
          ? SankakuFavoritesPage(username: config.login!)
          : const Scaffold(
              body: Center(
                child: Text(
                    'You need to provide login details to use this feature.'),
              ),
            );

  @override
  DownloadFilenameGenerator get downloadFilenameBuilder =>
      DownloadFileNameBuilder<SankakuPost>(
        defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat:
            kBoorusamaBulkDownloadCustomFileNameFormat,
        sampleData: kDanbooruPostSamples,
        tokenHandlers: {
          'id': (post, config) => post.id.toString(),
          'artist': (post, config) => post.artistTags.join(' '),
          'character': (post, config) => post.characterTags.join(' '),
          'copyright': (post, config) => post.copyrightTags.join(' '),
          'tags': (post, config) => post.tags.join(' '),
          'extension': (post, config) =>
              sanitizedExtension(config.downloadUrl).substring(1),
          'width': (post, config) => post.width.toString(),
          'height': (post, config) => post.height.toString(),
          'mpixels': (post, config) => post.mpixels.toString(),
          'aspect_ratio': (post, config) => post.aspectRatio.toString(),
          'md5': (post, config) => post.md5,
          'source': (post, config) => sanitizedUrl(config.downloadUrl),
          'rating': (post, config) => post.rating.name,
          'index': (post, config) => config.index?.toString(),
        },
      );
}

class SankakuArtistPage extends ConsumerWidget {
  const SankakuArtistPage({
    super.key,
    required this.artistName,
  });

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ArtistPageScaffold(
      artistName: artistName,
      fetcher: (page, selectedCategory) =>
          ref.read(sankakuArtistPostRepo(config)).getPosts([
        artistName,
        if (selectedCategory == TagFilterCategory.popular) 'order:score',
      ], page),
    );
  }
}
