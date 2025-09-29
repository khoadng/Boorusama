// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/create/widgets.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/auth/widgets.dart';
import '../../core/configs/config.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/ref.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/search/search/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/widgets.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class HydrusBuilder
    with
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        CommentNotSupportedMixin,
        DefaultViewTagListBuilderMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  HydrusBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
      }) => CreateBooruConfigScope(
        id: id,
        config: BooruConfig.defaultConfig(
          booruType: id.booruType,
          url: id.url,
          customDownloadFileNameFormat: null,
        ),
        child: CreateHydrusConfigPage(
          backgroundColor: backgroundColor,
        ),
      );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateHydrusConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as HydrusPost).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<HydrusPost>(),
    );
  };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const HydrusFavoritesPage();

  @override
  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const HydrusHomePage();

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => HydrusSearchPage(
        params: params,
      );

  @override
  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder =>
      (context, post) => HydrusQuickFavoriteButton(
        post: post,
      );

  @override
  final postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) => const HydrusPostActionToolbar(),
    },
    full: {
      DetailsPart.toolbar: (context) => const HydrusPostActionToolbar(),
      DetailsPart.tags: (context) =>
          const DefaultInheritedBasicTagsTile<HydrusPost>(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<HydrusPost>(
            initialExpanded: true,
          ),
    },
  );

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const UnknownBooruWidgetsBuilder(
        apiKeyField: DefaultBooruApiKeyField(),
        credentialsNeeded: true,
        submitButton: HydrusUnknownBooruSubmitButton(),
      );
}

class HydrusSearchPage extends ConsumerWidget {
  const HydrusSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    return SearchPageScaffold(
      params: params,
      fetcher: (page, controller) => ref
          .read(hydrusPostRepoProvider(config))
          .getPostsFromController(controller.tagSet, page),
    );
  }
}
