// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/gelbooru/infra/gelbooru_autocomplete_repository_api.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/posts/post_repository.dart';
import 'package:boorusama/core/domain/searches/searches.dart';
import 'package:boorusama/core/domain/tags/tags.dart';
import 'package:boorusama/main.dart';
import 'infra/gelbooru_post_repository_api.dart';
import 'infra/gelbooru_tag_repository_api.dart';

class GelbooruProvider extends StatelessWidget {
  const GelbooruProvider({
    super.key,
    required this.postRepository,
    required this.tagRepository,
    required this.builder,
    required this.autocompleteRepository,
    required this.userMetatagRepository,
    required this.searchHistoryRepository,
    required this.favoriteTagRepository,
  });

  factory GelbooruProvider.create(
    BuildContext context, {
    required Booru booru,
    required Widget Function(BuildContext context) builder,
  }) {
    final dio = context.read<DioProvider>().getDio(booru.url);
    final api = GelbooruApi(dio);

    final postRepo = GelbooruPostRepositoryApi(api: api);
    final tagRepo = GelbooruTagRepositoryApi(api);
    final autocompleteRepo = GelbooruAutocompleteRepositoryApi(api);

    final userMetatagsRepo = context.read<UserMetatagRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    return GelbooruProvider(
      postRepository: postRepo,
      tagRepository: tagRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
      userMetatagRepository: userMetatagsRepo,
      searchHistoryRepository: searchHistoryRepo,
      favoriteTagRepository: favoriteTagRepo,
    );
  }

  factory GelbooruProvider.of(
    BuildContext context, {
    // ignore: avoid_unused_constructor_parameters
    required Booru booru,
    required Widget Function(BuildContext context) builder,
  }) {
    final postRepo = context.read<PostRepository>();
    final tagRepo = context.read<TagRepository>();
    final autocompleteRepo = context.read<AutocompleteRepository>();
    final userMetatagsRepo = context.read<UserMetatagRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    return GelbooruProvider(
      postRepository: postRepo,
      tagRepository: tagRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
      userMetatagRepository: userMetatagsRepo,
      searchHistoryRepository: searchHistoryRepo,
      favoriteTagRepository: favoriteTagRepo,
    );
  }

  final PostRepository postRepository;
  final TagRepository tagRepository;
  final AutocompleteRepository autocompleteRepository;
  final UserMetatagRepository userMetatagRepository;
  final SearchHistoryRepository searchHistoryRepository;
  final FavoriteTagRepository favoriteTagRepository;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: tagRepository),
        RepositoryProvider.value(value: autocompleteRepository),
        RepositoryProvider.value(value: userMetatagRepository),
        RepositoryProvider.value(value: searchHistoryRepository),
        RepositoryProvider.value(value: favoriteTagRepository),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}
