// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

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
import '../../core/foundation/html.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/tags.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/search/search/widgets.dart';
import '../../core/settings/providers.dart';
import '../../core/tags/tag/providers.dart';
import '../../core/tags/tag/tag.dart';
import '../../core/widgets/info_container.dart';
import '../danbooru/danbooru.dart';
import '../gelbooru/gelbooru.dart';
import 'create_gelbooru_v1_config_page.dart';

part 'providers.dart';

class GelbooruV1Builder
    with
        FavoriteNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        CommentNotSupportedMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultThumbnailUrlMixin,
        DefaultTagColorMixin,
        DefaultTagColorsMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  GelbooruV1Builder();

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
            child: CreateGelbooruV1ConfigPage(
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
            child: CreateGelbooruV1ConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruV1SearchPage(
            initialQuery: initialQuery,
          );

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder(
    defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'source': (post, config) => config.downloadUrl,
    },
  );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder =
      kFallbackPostDetailsUIBuilder;
}

class GelbooruV1Repository implements BooruRepository {
  const GelbooruV1Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return null;
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruV1PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruV1AutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(emptyNoteRepoProvider);
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(emptyTagRepoProvider);
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return EmptyFavoriteRepository();
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return EmptyBooruSpecificBlacklistTagRefRepository(ref);
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruV1Client(baseUrl: config.url, dio: dio)
        .getPosts()
        .then((value) => value.isNotEmpty);
  }
}

class GelbooruV1SearchPage extends ConsumerWidget {
  const GelbooruV1SearchPage({
    required this.initialQuery,
    super.key,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return SearchPageScaffold(
      noticeBuilder: (context) => InfoContainer(
        contentBuilder: (context) => const AppHtml(
          data: 'The app will use <b>Gelbooru</b> for tag completion.',
        ),
      ),
      initialQuery: initialQuery,
      fetcher: (page, controller) => postRepo.getPostsFromController(
        controller,
        page,
      ),
    );
  }
}
