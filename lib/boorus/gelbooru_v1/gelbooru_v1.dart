// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/foundation/html.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/tags.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/search/search/src/pages/search_page.dart';
import '../../core/search/search/widgets.dart';
import '../../core/settings/providers.dart';
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
      (context, params) => GelbooruV1SearchPage(
            params: params,
          );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder =
      kFallbackPostDetailsUIBuilder;
}

class GelbooruV1Repository extends BooruRepositoryDefault {
  const GelbooruV1Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruV1PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruV1AutocompleteRepoProvider(config));
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder(
      defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: const [],
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruV1Client(baseUrl: config.url, dio: dio)
        .getPosts()
        .then((value) => value.isNotEmpty);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return IndexPhpPostLinkGenerator(baseUrl: config.url);
  }
}

class GelbooruV1SearchPage extends ConsumerWidget {
  const GelbooruV1SearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return SearchPageScaffold(
      noticeBuilder: (context) => InfoContainer(
        contentBuilder: (context) => const AppHtml(
          data: 'The app will use <b>Gelbooru</b> for tag completion.',
        ),
      ),
      params: params,
      fetcher: (page, controller) => postRepo.getPostsFromController(
        controller.tagSet,
        page,
      ),
    );
  }
}

BooruComponents createGelbooruV1() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.gelbooruV1,
        constructor: (siteDef) => GelbooruV1(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
        ),
      ),
      createBuilder: GelbooruV1Builder.new,
      createRepository: (ref) => GelbooruV1Repository(ref: ref),
    );

final class GelbooruV1 extends Booru {
  const GelbooruV1({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.gelbooruV1;
}
