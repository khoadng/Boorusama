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
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/home/custom_home.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/scaffolds/scaffolds.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/tag/tag.dart';
import '../danbooru/danbooru.dart';
import '../gelbooru/gelbooru.dart';
import 'configs/create_moebooru_config_page.dart';
import 'feats/autocomplete/autocomplete.dart';
import 'feats/posts/posts.dart';
import 'feats/tags/tags.dart';
import 'pages/moebooru_favorites_page.dart';
import 'pages/moebooru_home_page.dart';
import 'pages/moebooru_popular_page.dart';
import 'pages/moebooru_popular_recent_page.dart';
import 'pages/moebooru_post_details_page.dart';
import 'pages/widgets/moebooru_comment_section.dart';
import 'pages/widgets/moebooru_information_section.dart';
import 'pages/widgets/moebooru_related_post_section.dart';

final moebooruClientProvider =
    Provider.family<MoebooruClient, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return MoebooruClient.custom(
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
    dio: dio,
  );
});

final moebooruProvider = Provider<Moebooru>((ref) {
  final booruDb = ref.watch(booruDbProvider);
  final booru = booruDb.getBooru<Moebooru>();

  if (booru == null) {
    throw Exception('Booru not found for type: ${BooruType.moebooru}');
  }

  return booru;
});

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
          child: const MoebooruPostDetailsPage(),
        );
      };

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder(
    defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'mpixels': (post, config) => post.mpixels.toString(),
      'aspect_ratio': (post, config) => post.aspectRatio.toString(),
      'source': (post, config) => config.downloadUrl,
    },
  );

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
      DetailsPart.tags: (context) => const MoebooruTagListSection(),
      DetailsPart.fileDetails: (context) => const MoebooruFileDetailsSection(),
      DetailsPart.artistPosts: (context) => const MoebooruArtistPostsSection(),
      DetailsPart.relatedPosts: (context) =>
          const MoebooruRelatedPostsSection(),
      DetailsPart.comments: (context) => const MoebooruCommentSection(),
      DetailsPart.characterList: (context) =>
          const MoebooruCharacterListSection(),
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
          ref.read(moebooruArtistCharacterPostRepoProvider(config)).getPosts(
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
