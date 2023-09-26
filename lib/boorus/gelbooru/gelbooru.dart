// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/scaffolds/comment_page_scaffold.dart';
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/gelbooru/create_gelbooru_config_page.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_artist_page.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_scope.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'gelbooru_post_details_desktop_page.dart';
import 'gelbooru_post_details_page.dart';
import 'widgets/gelbooru_infinite_post_list.dart';

final gelbooruClientProvider = Provider<GelbooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return GelbooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});

final gelbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    final client = ref.watch(gelbooruClientProvider);

    return TagRepositoryBuilder(
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTags(
          page: page,
          tags: tags,
        );

        return data
            .map((e) => Tag(
                  name: e.name ?? '',
                  category: intToTagCategory(e.type ?? 0),
                  postCount: e.count ?? 0,
                ))
            .toList();
      },
    );
  },
);

class GelbooruBuilder with FavoriteNotSupportedMixin implements BooruBuilder {
  GelbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.client,
  });

  final GelbooruPostRepositoryApi postRepo;
  final AutocompleteRepository autocompleteRepo;
  final GelbooruClient client;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateGelbooruConfigPage(
            config: BooruConfig.defaultConfig(booruType: booruType, url: url),
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => GelbooruScope(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateGelbooruConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPostsFromTags(
        tags,
        page,
      );

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  PostCountFetcher? get postCountFetcher =>
      (tags) => client.countPosts(tags: tags);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, booruConfig, payload) => payload.isDesktop
          ? GelbooruPostDetailsDesktopPage(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              hasDetailsTagList: booruConfig.booruType.supportTagDetails,
            )
          : GelbooruPostDetailsPage(
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              hasDetailsTagList: booruConfig.booruType.supportTagDetails,
            );

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruArtistPage(artistName: artistName);
}

class GelbooruSearchPage extends ConsumerWidget {
  const GelbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      initialQuery: initialQuery,
      gridBuilder: (context, controller, slivers) => GelbooruInfinitePostList(
        controller: controller,
        sliverHeaderBuilder: (context) => slivers,
      ),
      fetcher: (page, tags) =>
          ref.watch(gelbooruPostRepoProvider).getPostsFromTags(tags, page),
    );
  }
}

class GelbooruCommentPage extends ConsumerWidget {
  const GelbooruCommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommentPageScaffold(
      postId: postId,
      fetcher: (postId) =>
          ref.watch(gelbooruCommentRepoProvider).getComments(postId),
    );
  }
}
