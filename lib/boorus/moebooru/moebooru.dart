// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/functional.dart';
import '../../core/configs/create/create.dart';
import 'configs/create_moebooru_config_page.dart';
import 'feats/posts/posts.dart';
import 'pages/moebooru_home_page.dart';
import 'pages/moebooru_post_details_desktop_page.dart';
import 'pages/moebooru_post_details_page.dart';

final moebooruClientProvider =
    Provider.family<MoebooruClient, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return MoebooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});

class MoebooruBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        CommentNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultBooruUIMixin,
        DefaultThumbnailUrlMixin,
        DefaultTagColorMixin,
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
  HomePageBuilder get homePageBuilder =>
      (context, config) => MoebooruHomePage(config: config);

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
      (context, config) => config.hasLoginDetails()
          ? MoebooruFavoritesPage(username: config.login!)
          : const Scaffold(
              body: Center(
                child: Text(
                    'You need to provide login details to use this feature.'),
              ),
            );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PostDetailsLayoutSwitcher(
            initialIndex: payload.initialIndex,
            posts: payload.posts,
            scrollController: payload.scrollController,
            desktop: (controller) => MoebooruPostDetailsDesktopPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as MoebooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
            mobile: (controller) => MoebooruPostDetailsPage(
              initialPage: controller.currentPage.value,
              controller: controller,
              posts: payload.posts.map((e) => e as MoebooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
          );

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
}

class MoebooruFavoritesPage extends ConsumerWidget {
  const MoebooruFavoritesPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'vote:3:$username order:vote';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(moebooruPostRepoProvider(config)).getPosts(query, page),
    );
  }
}

class MoebooruArtistPage extends ConsumerWidget {
  const MoebooruArtistPage({
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
