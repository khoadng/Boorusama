// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/gelbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/gelbooru/infra/autocompletes/gelbooru_autocomplete_repository_api.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/tags.dart';
import 'package:boorusama/core/provider.dart';
import 'infra/posts/gelbooru_post_repository_api.dart';
import 'infra/tags/gelbooru_tag_repository_api.dart';

class GelbooruProvider extends StatelessWidget {
  const GelbooruProvider({
    super.key,
    required this.postRepository,
    required this.tagRepository,
    required this.builder,
    required this.autocompleteRepository,
    required this.favoriteTagRepository,
    required this.fileNameGenerator,
    required this.tagBloc,
  });

  factory GelbooruProvider.create(
    BuildContext context, {
    required WidgetRef ref,
    required Widget Function(BuildContext context) builder,
    Key? key,
  }) {
    final booruConfig = ref.read(currentBooruConfigProvider);
    final dio = ref.read(dioProvider(booruConfig.url));

    final api = GelbooruApi(dio);

    final tagRepo = GelbooruTagRepositoryApi(api);
    final autocompleteRepo = GelbooruAutocompleteRepositoryApi(api);

    final settingsRepo = context.read<SettingsRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final globalBlacklistedTagRepo =
        context.read<GlobalBlacklistedTagRepository>();
    final currentBooruConfigRepository =
        context.read<CurrentBooruConfigRepository>();

    final postRepo = GelbooruPostRepositoryApi(
      currentBooruConfigRepository: currentBooruConfigRepository,
      api: api,
      blacklistedTagRepository: globalBlacklistedTagRepo,
      settingsRepository: settingsRepo,
    );
    final fileNameGenerator = DownloadUrlBaseNameFileNameGenerator();
    final tagBloc = TagBloc(
      tagRepository: TagCacher(
        cache: LruCacher(capacity: 1000),
        repo: tagRepo,
      ),
    );

    return GelbooruProvider(
      key: key,
      postRepository: postRepo,
      tagRepository: tagRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
      favoriteTagRepository: favoriteTagRepo,
      fileNameGenerator: fileNameGenerator,
      tagBloc: tagBloc,
    );
  }

  factory GelbooruProvider.of(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
    Key? key,
  }) {
    final postRepo = context.read<PostRepository>();
    final tagRepo = context.read<TagRepository>();
    final autocompleteRepo = context.read<AutocompleteRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final fileNameGenerator = context.read<FileNameGenerator>();

    final tagBloc = context.read<TagBloc>();

    return GelbooruProvider(
      key: key,
      postRepository: postRepo,
      tagRepository: tagRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
      favoriteTagRepository: favoriteTagRepo,
      fileNameGenerator: fileNameGenerator,
      tagBloc: tagBloc,
    );
  }

  final PostRepository postRepository;
  final TagRepository tagRepository;
  final AutocompleteRepository autocompleteRepository;
  final FavoriteTagRepository favoriteTagRepository;
  final FileNameGenerator fileNameGenerator;
  final Widget Function(BuildContext context) builder;

  final TagBloc tagBloc;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: tagRepository),
        RepositoryProvider.value(value: autocompleteRepository),
        RepositoryProvider.value(value: favoriteTagRepository),
        RepositoryProvider.value(value: fileNameGenerator),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: tagBloc),
        ],
        child: ProviderScope(
          overrides: [
            autocompleteRepoProvider.overrideWithValue(autocompleteRepository),
            postRepoProvider.overrideWithValue(postRepository),
          ],
          child: Builder(
            builder: builder,
          ),
        ),
      ),
    );
  }
}
