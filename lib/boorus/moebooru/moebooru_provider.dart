// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_popular_repository.dart';
import 'package:boorusama/boorus/moebooru/infra/autocompletes/moebooru_autocomplete_repository.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/boorus/moebooru/infra/posts/moebooru_post_repository_api.dart';
import 'package:boorusama/boorus/moebooru/infra/tags.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/main.dart';

class MoebooruProvider extends StatelessWidget {
  const MoebooruProvider({
    super.key,
    required this.postRepository,
    // required this.tagRepository,
    required this.builder,
    required this.autocompleteRepository,
    required this.userMetatagRepository,
    required this.searchHistoryRepository,
    required this.favoriteTagRepository,
    required this.authenticationCubit,
    required this.fileNameGenerator,
    required this.moebooruPopularRepository,
  });

  factory MoebooruProvider.create(
    BuildContext context, {
    required Booru booru,
    required Widget Function(BuildContext context) builder,
    Key? key,
  }) {
    final dio = context.read<DioProvider>().getDio(booru.url);
    final api = MoebooruApi(dio);

    final userMetatagsRepo = context.read<UserMetatagRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final globalBlacklistedTagRepo = context.read<BlacklistedTagRepository>();
    final currentBooruConfigRepository =
        context.read<CurrentBooruConfigRepository>();
    final authenticationCubit = AuthenticationCubit(
      currentBooruConfigRepository: currentBooruConfigRepository,
      booru: booru,
    );
    final tagSummaryRepository = MoebooruTagSummaryRepository(api);
    final autocompleteRepo = MoebooruAutocompleteRepository(
        tagSummaryRepository: tagSummaryRepository);

    final postRepo = MoebooruPostRepositoryApi(
      api,
      globalBlacklistedTagRepo,
      currentBooruConfigRepository,
    );
    final fileNameGenerator = DownloadUrlBaseNameFileNameGenerator();
    final popularRepository = MoebooruPopularRepositoryApi(
      api,
      globalBlacklistedTagRepo,
      currentBooruConfigRepository,
    );

    return MoebooruProvider(
      key: key,
      postRepository: postRepo,
      // tagRepository: tagRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
      userMetatagRepository: userMetatagsRepo,
      searchHistoryRepository: searchHistoryRepo,
      favoriteTagRepository: favoriteTagRepo,
      authenticationCubit: authenticationCubit,
      fileNameGenerator: fileNameGenerator,
      moebooruPopularRepository: popularRepository,
    );
  }

  factory MoebooruProvider.of(
    BuildContext context, {
    // ignore: avoid_unused_constructor_parameters
    required Booru booru,
    required Widget Function(BuildContext context) builder,
    Key? key,
  }) {
    final postRepo = context.read<PostRepository>();
    // final tagRepo = context.read<TagRepository>();
    final autocompleteRepo = context.read<AutocompleteRepository>();
    final userMetatagsRepo = context.read<UserMetatagRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final fileNameGenerator = context.read<FileNameGenerator>();
    final popularRepository = context.read<MoebooruPopularRepository>();

    final authenticationCubit = context.read<AuthenticationCubit>();

    return MoebooruProvider(
      key: key,
      postRepository: postRepo,
      moebooruPopularRepository: popularRepository,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
      userMetatagRepository: userMetatagsRepo,
      searchHistoryRepository: searchHistoryRepo,
      favoriteTagRepository: favoriteTagRepo,
      authenticationCubit: authenticationCubit,
      fileNameGenerator: fileNameGenerator,
    );
  }

  final PostRepository postRepository;
  // final TagRepository tagRepository;
  final AutocompleteRepository autocompleteRepository;
  final UserMetatagRepository userMetatagRepository;
  final SearchHistoryRepository searchHistoryRepository;
  final FavoriteTagRepository favoriteTagRepository;
  final FileNameGenerator fileNameGenerator;
  final MoebooruPopularRepository moebooruPopularRepository;
  final Widget Function(BuildContext context) builder;

  final AuthenticationCubit authenticationCubit;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: moebooruPopularRepository),
        RepositoryProvider.value(value: autocompleteRepository),
        RepositoryProvider.value(value: userMetatagRepository),
        RepositoryProvider.value(value: searchHistoryRepository),
        RepositoryProvider.value(value: favoriteTagRepository),
        RepositoryProvider.value(value: fileNameGenerator),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authenticationCubit),
        ],
        child: Builder(
          builder: builder,
        ),
      ),
    );
  }
}
