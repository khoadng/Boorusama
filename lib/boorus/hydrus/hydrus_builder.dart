// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/create/widgets.dart';
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/configs/auth/widgets.dart';
import '../../core/configs/config/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/network/widgets.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/search/search/routes.dart';
import '../../core/search/search/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/widgets.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class HydrusBuilder extends BaseBooruBuilder {
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
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder =>
      (context, post) => HydrusQuickFavoriteButton(
        post: post,
      );

  @override
  final postDetailsUIBuilder = kHydrusPostDetailsUIBuilder;

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const UnknownBooruWidgetsBuilder(
        httpProtocolField: HttpProtocolOptionTile(),
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
