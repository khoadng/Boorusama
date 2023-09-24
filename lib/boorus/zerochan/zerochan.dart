// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/home_page_scaffold.dart';
import 'package:boorusama/boorus/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/clients/zerochan/types/types.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/path.dart' as path;
import 'package:boorusama/functional.dart';

final zerochanClientProvider = Provider<ZerochanClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return ZerochanClient(dio: dio);
});

class ZerochanBuilder
    with
        SettingsRepositoryMixin,
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin
    implements BooruBuilder {
  const ZerochanBuilder({
    required this.client,
    required this.settingsRepository,
  });

  final ZerochanClient client;
  @override
  final SettingsRepository settingsRepository;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          ZerochanCreateConfigPage(
            url: url,
            booruType: booruType,
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder => (context, config) => HomePageScaffold(
        onPostTap:
            (context, posts, post, scrollController, settings, initialIndex) =>
                goToPostDetailsPage(
          context: context,
          posts: posts,
          initialIndex: initialIndex,
        ),
        onSearchTap: () => goToSearchPage(context),
      );

  //FIXME: this is a hack, we should have a proper update page
  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          createConfigPageBuilder(
            context,
            config.url,
            config.booruType,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => TaskEither.Do(($) async {
        final limit = await getPostsPerPage();
        final posts = await client.getPosts(
          tags: tags.split(' ').toList(),
          page: page,
          limit: limit,
        );

        return posts
            .map((e) => SimplePost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.thumbnail ?? '',
                  sampleImageUrl: e.thumbnail ?? '',
                  originalImageUrl: e.fileUrl() ?? '',
                  tags: e.tags ?? [],
                  rating: Rating.general,
                  hasComment: false,
                  isTranslated: false,
                  hasParentOrChildren: false,
                  source: PostSource.from(e.source),
                  score: 0,
                  duration: 0,
                  fileSize: 0,
                  format: path.extension(e.thumbnail ?? ''),
                  hasSound: null,
                  height: e.height?.toDouble() ?? 0,
                  md5: '',
                  videoThumbnailUrl: '',
                  videoUrl: '',
                  width: e.width?.toDouble() ?? 0,
                  getLink: (baseUrl) => baseUrl.endsWith('/')
                      ? '$baseUrl${e.id}'
                      : '$baseUrl/${e.id}',
                ))
            .toList();
      });

  @override
  AutocompleteFetcher get autocompleteFetcher => (query) async {
        final tags = await client.getAutocomplete(query: query);

        return tags
            .map((e) => AutocompleteData(
                  label: e.value?.toLowerCase() ?? '',
                  value: e.value?.toLowerCase() ?? '',
                  postCount: e.total,
                  category: e.type?.toLowerCase() ?? '',
                ))
            .toList();
      };

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => ZerochanSearchPage(
            initialQuery: initialQuery,
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => ZerochanPostDetailsPage(
            posts: payload.posts,
            initialIndex: payload.initialIndex,
            scrollController: payload.scrollController,
          );
}

class ZerochanPostDetailsPage extends ConsumerWidget {
  const ZerochanPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.scrollController,
  });

  final List<Post> posts;
  final int initialIndex;
  final AutoScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: initialIndex,
      onExit: (page) => scrollController?.scrollToIndex(page),
      onTagTap: (tag) => goToSearchPage(context),
    );
  }
}

class ZerochanSearchPage extends ConsumerWidget {
  const ZerochanSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilders = ref.watch(booruBuildersProvider);
    final fetcher = booruBuilders[BooruType.zerochan]?.postFetcher;

    return SearchPageScaffold(
      fetcher: (page, tags) =>
          fetcher?.call(page, tags) ?? TaskEither.of(<Post>[]),
    );
  }
}

class ZerochanCreateConfigPage extends ConsumerStatefulWidget {
  const ZerochanCreateConfigPage({
    super.key,
    required this.url,
    required this.booruType,
    this.backgroundColor,
  });

  final String url;
  final BooruType booruType;
  final Color? backgroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ZerochanCreateConfigPageState();
}

class _ZerochanCreateConfigPageState
    extends ConsumerState<ZerochanCreateConfigPage> {
  var configName = '';

  @override
  Widget build(BuildContext context) {
    return CreateAnonConfigPage(
      backgroundColor: widget.backgroundColor,
      onConfigNameChanged: (value) => setState(() => configName = value),
      onSubmit: allowSubmit() ? submit : null,
      booruType: widget.booruType,
      url: widget.url,
    );
  }

  bool allowSubmit() {
    return configName.isNotEmpty;
  }

  void submit() {
    ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
          newConfig: AddNewBooruConfig(
            login: '',
            apiKey: '',
            booru: widget.booruType,
            booruHint: widget.booruType,
            configName: configName,
            hideDeleted: false,
            ratingFilter: BooruConfigRatingFilter.none,
            url: widget.url,
          ),
        );
    context.navigator.pop();
  }
}
