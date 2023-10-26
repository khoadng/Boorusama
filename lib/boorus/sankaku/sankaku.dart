// Flutter imports:
import 'package:boorusama/core/feats/downloads/download_file_name_generator.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
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
              customDownloadFileNameFormat: null,
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
          builder: (booruBuilder) => PostDetailsPageScaffold(
            posts: posts,
            initialIndex: initialIndex,
            infoBuilder: (context, post) => SimpleInformationSection(
              post: post,
              showSource: true,
            ),
            showSourceTile: false,
            sliverArtistPostsBuilder: (context, post) =>
                SankakuRecommendArtists(post: post),
            tagListBuilder: (context, post) => PostTagList(
              tags: createTagGroupItems([
                ...post.artistDetailsTags,
                ...post.characterDetailsTags,
                ...post.copyrightDetailsTags,
              ]),
              itemBuilder: (context, tag) => GestureDetector(
                onTap: () => goToSearchPage(context, tag: tag.rawName),
                child: PostTagListChip(
                  tag: tag,
                ),
              ),
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
  DownloadFilenameGenerator<Post> get downloadFilenameBuilder =>
      LegacyFilenameBuilder(
        generateFileName: (post, downloadUrl) =>
            Md5OnlyFileNameGenerator().generateFor(post, downloadUrl),
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

class SankakuRecommendArtists extends ConsumerWidget {
  const SankakuRecommendArtists({
    super.key,
    required this.post,
  });

  final SankakuPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistName = post.artistTags.firstOrNull;

    return ref
        .watch(sankakuArtistPostsProvider(post.artistTags.firstOrNull))
        .maybeWhen(
          data: (posts) => RecommendArtistList(
            onTap: (recommendIndex, postIndex) => goToPostDetailsPage(
              context: context,
              posts: posts,
              initialIndex: postIndex,
            ),
            onHeaderTap: (index) => goToArtistPage(context, artistName),
            recommends: [
              Recommend(
                title: artistName?.replaceAll('_', ' ') ?? '????',
                posts: posts,
                type: RecommendType.artist,
                tag: artistName ?? '????',
              ),
            ],
            imageUrl: (item) => item.sampleImageUrl,
          ),
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}
