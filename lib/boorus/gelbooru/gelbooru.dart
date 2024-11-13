// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/gelbooru/home/home.dart';
import 'package:boorusama/boorus/gelbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/types/types.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/toast.dart';
import 'artists/gelbooru_artist_page.dart';
import 'comments/gelbooru_comment_page.dart';
import 'configs/create_gelbooru_config_page.dart';
import 'posts/gelbooru_post_details_desktop_page.dart';
import 'posts/gelbooru_post_details_page.dart';

export 'posts/posts.dart';

const kGelbooruCustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

String getGelbooruProfileUrl(String url) => url.endsWith('/')
    ? '${url}index.php?page=account&s=options'
    : '$url/index.php?page=account&s=options';

final gelbooruClientProvider =
    Provider.family<GelbooruClient, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return GelbooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    passHash: booruConfig.passHash,
    dio: dio,
  );
});

final gelbooruTagRepoProvider = Provider.family<TagRepository, BooruConfig>(
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
            .map((e) => Tag(
                  name: e.name ?? '',
                  category: TagCategory.fromLegacyId(e.type),
                  postCount: e.count ?? 0,
                ))
            .toList();
      },
    );
  },
);

final gelbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
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
    Provider.family<NoteRepository, BooruConfig>((ref, config) {
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
        PostCountNotSupportedMixin,
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
  GelbooruBuilder({
    required this.client,
  });

  final GelbooruClient Function() client;

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
  HomePageBuilder get homePageBuilder =>
      (context, config) => GelbooruHomePage(config: config);

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
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PostDetailsLayoutSwitcher(
            initialIndex: payload.initialIndex,
            posts: payload.posts,
            scrollController: payload.scrollController,
            desktop: (controller) => GelbooruPostDetailsDesktopPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
            mobile: (controller) => GelbooruPostDetailsPage(
              initialIndex: controller.currentPage.value,
              controller: controller,
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
          );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => const GelbooruFavoritesPage();

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
  FavoriteAdder? get favoriteAdder => client().canFavorite
      ? (postId, ref) async {
          final status = await ref
              .read(gelbooruFavoritesProvider(ref.readConfig).notifier)
              .add(postId);

          final context = ref.context;

          if (context.mounted) {
            if (status == AddFavoriteStatus.alreadyExists) {
              showErrorToast(context, 'Already favorited');
            } else if (status == AddFavoriteStatus.failure) {
              showErrorToast(context, 'Failed to favorite');
            } else {
              showSuccessToast(context, 'Favorited');
            }
          }

          return status == AddFavoriteStatus.success;
        }
      : null;

  @override
  FavoriteRemover? get favoriteRemover => client().canFavorite
      ? (postId, ref) async {
          await ref
              .read(gelbooruFavoritesProvider(ref.readConfig).notifier)
              .remove(postId);

          final context = ref.context;

          if (context.mounted) {
            showSuccessToast(context, 'Favorite removed');
          }

          return true;
        }
      : null;
}

class GelbooruSearchPage extends ConsumerWidget {
  const GelbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, controller) => ref
          .watch(gelbooruPostRepoProvider(config))
          .getPosts(controller.rawTagsString, page),
    );
  }
}
