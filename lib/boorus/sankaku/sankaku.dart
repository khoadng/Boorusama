// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/blacklists/providers.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/foundation/caching.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/details.dart';
import '../../core/posts/details/routes.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/scaffolds/artist_page_scaffold.dart';
import '../../core/search/queries/providers.dart';
import '../../core/search/search/routes.dart';
import '../../core/settings/providers.dart';
import '../../core/tags/categories/tag_category.dart';
import '../../core/tags/tag/tag.dart';
import '../danbooru/danbooru.dart';
import 'create_sankaku_config_page.dart';
import 'sankaku_home_page.dart';
import 'sankaku_post.dart';

part 'sankaku_provider.dart';

class SankakuBuilder
    with
        CommentNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultHomeMixin,
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
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          dislclaimer: payload.dislclaimer,
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

class SankakuRepository extends BooruRepositoryDefault {
  const SankakuRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(sankakuPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(sankakuAutocompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => SankakuClient(
          baseUrl: config.url,
          dio: dio,
          username: config.login,
          password: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return SankakuPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<SankakuPost>(
      defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat:
          kBoorusamaBulkDownloadCustomFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        TokenHandler('artist', (post, config) => post.artistTags.join(' ')),
        TokenHandler(
          'character',
          (post, config) => post.characterTags.join(' '),
        ),
        TokenHandler(
          'copyright',
          (post, config) => post.copyrightTags.join(' '),
        ),
        TokenHandler('general', (post, config) => post.generalTags.join(' ')),
        TokenHandler('meta', (post, config) => post.metaTags.join(' ')),
        MPixelsTokenHandler(),
        TokenHandler(
          'source',
          (post, config) => sanitizedUrl(config.downloadUrl),
        ),
      ],
    );
  }
}

class SankakuPostLinkGenerator implements PostLinkGenerator<SankakuPost> {
  SankakuPostLinkGenerator({
    required this.baseUrl,
  });

  final String baseUrl;

  @override
  String getLink(SankakuPost post) {
    final url = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$url/posts/${post.sankakuId}';
  }
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
                          (
                            ref.watchConfigFilter,
                            ref.watchConfigSearch,
                            post.artistTags.firstOrNull
                          ),
                        ),
                      )
                      .maybeWhen(
                        data: (data) => SliverPreviewPostGrid(
                          posts: data,
                          onTap: (postIdx) => goToPostDetailsPageFromPosts(
                            context: context,
                            posts: data,
                            initialIndex: postIdx,
                            initialThumbnailUrl: data[postIdx].sampleImageUrl,
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
          ...post.generalDetailsTags,
          ...post.metaDetailsTags,
        ]),
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
      ),
    );
  }
}

class SankakuArtistPage extends ConsumerWidget {
  const SankakuArtistPage({
    required this.artistName,
    super.key,
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

BooruComponents createSankaku() => BooruComponents(
      parser: YamlBooruParser(
        type: BooruType.sankaku,
        mapper: (def) => Sankaku(
          name: def.name,
          protocol: def.getProtocol(),
          sites: def.getSites(),
          headers: def.getHeaders(),
        ),
      ),
      createBuilder: SankakuBuilder.new,
      createRepository: (ref) => SankakuRepository(ref: ref),
    );

class Sankaku extends Booru {
  const Sankaku({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.headers,
  });

  @override
  final List<String> sites;
  final Map<String, dynamic>? headers;

  @override
  BooruType get type => BooruType.sankaku;
}
