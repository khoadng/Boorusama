// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/failsafe.dart';
import '../../core/configs/manage.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/home/custom_home.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/scaffolds/scaffolds.dart';
import '../../core/search/queries/query.dart';
import '../../core/search/search/src/pages/search_page.dart';
import '../../core/search/search/widgets.dart';
import '../../core/tags/categories/tag_category.dart';
import '../../core/tags/tag/tag.dart';
import '../danbooru/danbooru.dart';
import 'artists/artists.dart';
import 'comments/comments.dart';
import 'create_gelbooru_v2_config_page.dart';
import 'home/gelbooru_v2_home_page.dart';
import 'posts/gelbooru_v2_post_details_page.dart';
import 'posts/posts_v2.dart';

const kGelbooruV2CustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

final gelbooruV2ClientProvider =
    Provider.family<GelbooruV2Client, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return GelbooruV2Client.custom(
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
    dio: dio,
  );
});

final gelbooruV2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruV2ClientProvider(config));

  return AutocompleteRepositoryBuilder(
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query.text, limit: 20);

      return dtos
          .map((e) {
            try {
              return AutocompleteData(
                type: e.type,
                label: e.label?.replaceAll('_', ' ') ?? '<empty>',
                value: e.value!,
                category: e.category?.toString(),
                postCount: e.postCount,
              );
            } catch (err) {
              return AutocompleteData.empty;
            }
          })
          .where((e) => e != AutocompleteData.empty)
          .toList();
    },
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
  );
});

final gelbooruV2TagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfigAuth;
    final client = ref.watch(gelbooruV2ClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data
        .map(
          (e) => Tag(
            name: e.name ?? '',
            category: TagCategory.fromLegacyId(e.type),
            postCount: e.count ?? 0,
          ),
        )
        .toList();
  },
);

final gelbooruV2NoteRepoProvider =
    Provider.family<NoteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruV2ClientProvider(config));

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotesFromPostId(
          postId: postId,
        )
        .then((value) => value.map(gelbooruV2NoteToNote).toList()),
  );
});

Note gelbooruV2NoteToNote(NoteDto note) {
  return Note(
    coordinate: NoteCoordinate(
      x: note.x?.toDouble() ?? 0,
      y: note.y?.toDouble() ?? 0,
      height: note.height?.toDouble() ?? 0,
      width: note.width?.toDouble() ?? 0,
    ),
    content: note.body ?? '',
  );
}

class GelbooruV2Builder
    with
        FavoriteNotSupportedMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin
    implements BooruBuilder {
  GelbooruV2Builder();

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
                  kGelbooruV2CustomDownloadFileNameFormat,
            ),
            child: CreateGelbooruV2ConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const GelbooruV2HomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateGelbooruV2ConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => GelbooruV2SearchPage(
            params: params,
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as GelbooruV2Post).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          dislclaimer: payload.dislclaimer,
          child: const DefaultPostDetailsPage<GelbooruV2Post>(),
        );
      };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const GelbooruV2FavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruV2ArtistPage(
            artistName: artistName,
          );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruV2ArtistPage(
            artistName: characterName,
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => GelbooruV2CommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
      };

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      kGelbooruV2AltHomeView;

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<GelbooruV2Post>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<GelbooruV2Post>(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<GelbooruV2Post>(),
      DetailsPart.tags: (context) => const GelbooruV2TagsTile(),
      DetailsPart.fileDetails: (context) =>
          const GelbooruV2FileDetailsSection(),
      DetailsPart.artistPosts: (context) =>
          const GelbooruV2ArtistPostsSection(),
      DetailsPart.relatedPosts: (context) =>
          const GelbooruV2RelatedPostsSection(),
      DetailsPart.characterList: (context) =>
          const GelbooruV2CharacterPostsSection(),
    },
  );
}

class GelbooruV2Repository extends BooruRepositoryDefault {
  const GelbooruV2Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruV2PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruV2AutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(gelbooruV2NoteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruV2Client(
          baseUrl: config.url,
          dio: dio,
          userId: config.login,
          apiKey: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return GelbooruV2TagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return IndexPhpPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder(
      defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat:
          kGelbooruV2CustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        MPixelsTokenHandler(),
      ],
    );
  }
}

final kGelbooruV2AltHomeView = {
  ...kDefaultAltHomeView,
  // ignore: prefer_const_constructors
  CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: 'profile.favorites',
    builder: (context, _) => const GelbooruV2FavoritesPage(),
  ),
};

class GelbooruV2SearchPage extends ConsumerWidget {
  const GelbooruV2SearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(gelbooruV2PostRepoProvider(config));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
    );
  }
}

class GelbooruV2FavoritesPage extends ConsumerWidget {
  const GelbooruV2FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => GelbooruV2FavoritesPageInternal(
        uid: config.login!,
      ),
    );
  }
}

class GelbooruV2FavoritesPageInternal extends ConsumerWidget {
  const GelbooruV2FavoritesPageInternal({
    required this.uid,
    super.key,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:$uid';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(gelbooruV2PostRepoProvider(config)).getPosts(query, page),
    );
  }
}

BooruComponents createGelbooruV2() => BooruComponents(
      parser: GelbooruV2Parser(),
      createBuilder: GelbooruV2Builder.new,
      createRepository: (ref) => GelbooruV2Repository(ref: ref),
    );

typedef GelbooruV2Site = ({
  String url,
  String? apiUrl,
});

class GelbooruV2 extends Booru {
  const GelbooruV2({
    required super.name,
    required super.protocol,
    required List<GelbooruV2Site> sites,
  }) : _sites = sites;

  final List<GelbooruV2Site> _sites;

  @override
  Iterable<String> get sites => _sites.map((e) => e.url);

  @override
  BooruType get type => BooruType.gelbooruV2;

  @override
  String getApiUrl(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.apiUrl ?? url;
}

class GelbooruV2Parser extends BooruParser {
  @override
  BooruType get booruType => BooruType.gelbooruV2;

  @override
  Booru parse(String name, dynamic data) {
    final sites = <GelbooruV2Site>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final apiUrl = item['api-url'];

      sites.add(
        (
          url: url,
          apiUrl: apiUrl,
        ),
      );
    }

    return GelbooruV2(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: sites,
    );
  }
}
