// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/comment.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/home/custom_home.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/scaffolds/scaffolds.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/tag/tag.dart';
import '../danbooru/danbooru.dart';
import '../gelbooru/gelbooru.dart';
import 'autocomplete/providers.dart';
import 'comments/providers.dart';
import 'configs/create_moebooru_config_page.dart';
import 'favorites/widgets.dart';
import 'moebooru_home_page.dart';
import 'posts/posts.dart';
import 'posts/providers.dart';
import 'posts/widgets.dart';
import 'tags/providers.dart';

class MoebooruBuilder
    with
        FavoriteNotSupportedMixin,
        CommentNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultBooruUIMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin
    implements BooruBuilder {
  MoebooruBuilder();

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
                  kGelbooruCustomDownloadFileNameFormat,
            ),
            child: CreateMoebooruConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder => (context) => const MoebooruHomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateMoebooruConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => MoebooruArtistPage(
            artistName: artistName,
          );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => MoebooruArtistPage(
            artistName: characterName,
          );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const MoebooruFavoritesPage();

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as MoebooruPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          dislclaimer: payload.dislclaimer,
          child: const MoebooruPostDetailsPage(),
        );
      };

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      kMoebooruAltHomeView;

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) => const MoebooruInformationSection(),
      DetailsPart.toolbar: (context) =>
          const MoebooruPostDetailsActionToolbar(),
    },
    full: {
      DetailsPart.info: (context) => const MoebooruInformationSection(),
      DetailsPart.toolbar: (context) =>
          const MoebooruPostDetailsActionToolbar(),
      DetailsPart.tags: (context) =>
          const DefaultInheritedTagsTile<MoebooruPost>(),
      DetailsPart.fileDetails: (context) => const MoebooruFileDetailsSection(),
      DetailsPart.artistPosts: (context) =>
          const DefaultInheritedArtistPostsSection<MoebooruPost>(),
      DetailsPart.relatedPosts: (context) =>
          const MoebooruRelatedPostsSection(),
      DetailsPart.comments: (context) => const MoebooruCommentSection(),
      DetailsPart.characterList: (context) =>
          const DefaultInheritedCharacterPostsSection<MoebooruPost>(),
    },
  );
}

class MoebooruRepository extends BooruRepositoryDefault {
  const MoebooruRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(moebooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(moebooruAutocompleteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(moebooruTagRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => MoebooruClient(
          baseUrl: config.url,
          dio: dio,
          login: config.login,
          passwordHashed: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return LegacyTagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return ShowPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    final tagRepo = ref.watch(moebooruTagRepoProvider(config));

    return DownloadFileNameBuilder<MoebooruPost>(
      defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        MPixelsTokenHandler(),
      ],
      asyncTokenHandlers: [
        AsyncTokenHandler(
          ClassicTagsTokenResolver(
            tagFetcher: (post) async {
              final tags = await tagRepo.getTagsByName(post.tags.toSet(), 1);
              return tags
                  .map((tag) => (name: tag.name, type: tag.category.name))
                  .toList();
            },
          ),
        ),
      ],
    );
  }

  @override
  TagGroupRepository<Post> tagGroup(BooruConfigAuth config) {
    return ref.watch(moebooruTagGroupRepoProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(moebooruCommentRepoProvider(config));
  }
}

final kMoebooruAltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: 'profile.favorites',
    builder: (context, _) => const MoebooruFavoritesPage(),
  ),
  const CustomHomeViewKey('popular'): CustomHomeDataBuilder(
    displayName: 'Popular',
    builder: (context, _) => const MoebooruPopularPage(),
  ),
  const CustomHomeViewKey('hot'): CustomHomeDataBuilder(
    displayName: 'Hot',
    builder: (context, _) => const MoebooruPopularRecentPage(),
  ),
};

class MoebooruArtistPage extends ConsumerWidget {
  const MoebooruArtistPage({
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
          ref.read(moebooruPostRepoProvider(config)).getPosts(
                queryFromTagFilterCategory(
                  category: selectedCategory,
                  tag: artistName,
                  builder: (category) => category == TagFilterCategory.popular
                      ? some('order:score')
                      : none(),
                ),
                page,
              ),
    );
  }
}

BooruComponents createMoebooru() => BooruComponents(
      parser: MoebooruParser(),
      createBuilder: MoebooruBuilder.new,
      createRepository: (ref) => MoebooruRepository(ref: ref),
    );

typedef MoebooruSite = ({
  String url,
  String salt,
  bool? favoriteSupport,
  NetworkProtocol? overrideProtocol,
});

final class Moebooru extends Booru {
  const Moebooru({
    required super.name,
    required super.protocol,
    required List<MoebooruSite> sites,
  }) : _sites = sites;

  final List<MoebooruSite> _sites;

  @override
  Iterable<String> get sites => _sites.map((e) => e.url);

  @override
  BooruType get type => BooruType.moebooru;

  String? getSalt(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.salt;

  bool supportsFavorite(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.favoriteSupport ??
      false;

  @override
  NetworkProtocol? getSiteProtocol(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.overrideProtocol ??
      protocol;
}

class MoebooruParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.moebooru;

  @override
  Booru parse(String name, dynamic data) {
    final sites = <MoebooruSite>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final salt = item['salt'] as String;
      final favoriteSupport = item['favorite-support'] as bool?;
      final overrideProtocol = item['protocol'];

      sites.add(
        (
          url: url,
          salt: salt,
          favoriteSupport: favoriteSupport,
          overrideProtocol:
              overrideProtocol != null ? parseProtocol(overrideProtocol) : null,
        ),
      );
    }

    return Moebooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: sites,
    );
  }
}
