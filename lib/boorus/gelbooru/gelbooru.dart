// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/blacklists/blacklist.dart';
import '../../core/blacklists/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/favorites/providers.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/search/search_ui.dart';
import '../../core/tags/categories/tag_category.dart';
import '../../core/tags/tag/providers.dart';
import '../../core/tags/tag/tag.dart';
import '../danbooru/danbooru.dart';
import 'artists/gelbooru_artist_page.dart';
import 'comments/gelbooru_comment_page.dart';
import 'configs/create_gelbooru_config_page.dart';
import 'favorites/favorites.dart';
import 'home/home.dart';
import 'posts/gelbooru_post_details_page.dart';
import 'posts/posts.dart';

export 'posts/posts.dart';

const kGelbooruCustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

String getGelbooruProfileUrl(String url) => url.endsWith('/')
    ? '${url}index.php?page=account&s=options'
    : '$url/index.php?page=account&s=options';

final gelbooruClientProvider =
    Provider.family<GelbooruClient, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return GelbooruClient.custom(
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
    passHash: config.passHash,
    dio: dio,
  );
});

final gelbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTags(
          page: page,
          tags: tags,
        );

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
  },
);

final gelbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruClientProvider(config));

  return AutocompleteRepositoryBuilder(
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query, limit: 20);

      return dtos
          .map((e) {
            try {
              return AutocompleteData(
                type: e.type,
                label: e.label?.replaceAll('_', ' ') ?? '<empty>',
                value: _extractAutocompleteTag(e),
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

String _extractAutocompleteTag(AutocompleteDto dto) {
  final label = dto.label;
  final value = dto.value;

  // if label start with '{' use it as value, this is used for OR tags
  if (label != null && label.startsWith('{')) {
    return label.replaceAll(' ', '_');
  }

  return value ?? label ?? '';
}

final gelbooruNoteRepoProvider =
    Provider.family<NoteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruClientProvider(config));

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotesFromPostId(
          postId: postId,
        )
        .then((value) => value.map(gelbooruNoteToNote).toList()),
  );
});

Note gelbooruNoteToNote(NoteDto note) {
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

class GelbooruBuilder
    with
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultThumbnailUrlMixin,
        DefaultThumbnailUrlMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultTagColorMixin
    implements BooruBuilder {
  GelbooruBuilder();

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
            child: CreateGelbooruConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder => (context) => const GelbooruHomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateGelbooruConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as GelbooruPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<GelbooruPost>(),
        );
      };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const GelbooruFavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruArtistPage(
            artistName: artistName,
          );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruArtistPage(
            artistName: characterName,
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => GelbooruCommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
        Rating.general,
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
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<GelbooruPost>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<GelbooruPost>(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<GelbooruPost>(),
      DetailsPart.tags: (context) => const GelbooruTagListSection(),
      DetailsPart.fileDetails: (context) => const GelbooruFileDetailsSection(),
      DetailsPart.artistPosts: (context) => const GelbooruArtistPostsSection(),
      DetailsPart.characterList: (context) =>
          const GelbooruCharacterListSection(),
    },
  );
}

class GelbooruRepository implements BooruRepository {
  const GelbooruRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return null;
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruAutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(gelbooruNoteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(gelbooruTagRepoProvider(config));
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return GelbooruFavoriteRepository(ref, config);
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return GlobalBlacklistTagRefRepository(ref);
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruClient(
          baseUrl: config.url,
          dio: dio,
          userId: config.login,
          apiKey: config.apiKey,
        ).getPosts().then((value) => true);
  }
}

class GelbooruSearchPage extends ConsumerWidget {
  const GelbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(gelbooruPostRepoProvider(config));

    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller, page),
    );
  }
}
