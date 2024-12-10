// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/scaffolds/scaffolds.dart';
import '../../core/tags/tag/tag.dart';
import '../booru_builder.dart';
import '../booru_builder_default.dart';
import '../booru_builder_types.dart';
import '../danbooru/danbooru.dart';
import '../gelbooru/gelbooru.dart';
import 'configs/create_moebooru_config_page.dart';
import 'feats/posts/posts.dart';
import 'pages/moebooru_favorites_page.dart';
import 'pages/moebooru_home_page.dart';
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

class MoebooruBuilder
    with
        FavoriteNotSupportedMixin,
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

class MoebooruArtistPage extends ConsumerWidget {
  const MoebooruArtistPage({
    super.key,
    required this.artistName,
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
