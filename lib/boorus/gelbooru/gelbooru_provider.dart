// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru/application/downloads/download_provider.dart';
import 'package:boorusama/boorus/gelbooru/application/tags/tags_provider.dart';
import 'package:boorusama/boorus/gelbooru/infra/autocompletes/gelbooru_autocomplete_repository_api.dart';
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'infra/posts/gelbooru_post_repository_api.dart';

class GelbooruProvider extends StatelessWidget {
  const GelbooruProvider({
    super.key,
    required this.postRepository,
    required this.builder,
    required this.autocompleteRepository,
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

    final autocompleteRepo = GelbooruAutocompleteRepositoryApi(api);

    final settingsRepo = ref.read(settingsRepoProvider);
    final globalBlacklistedTagRepo = ref.read(globalBlacklistedTagRepoProvider);
    final currentBooruConfigRepository =
        ref.read(currentBooruConfigRepoProvider);

    final postRepo = GelbooruPostRepositoryApi(
      currentBooruConfigRepository: currentBooruConfigRepository,
      api: api,
      blacklistedTagRepository: globalBlacklistedTagRepo,
      settingsRepository: settingsRepo,
    );

    return GelbooruProvider(
      key: key,
      postRepository: postRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
    );
  }

  factory GelbooruProvider.of(
    WidgetRef ref,
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
    Key? key,
  }) {
    final postRepo = ref.read(postRepoProvider);
    final autocompleteRepo = ref.read(autocompleteRepoProvider);

    return GelbooruProvider(
      key: key,
      postRepository: postRepo,
      builder: builder,
      autocompleteRepository: autocompleteRepo,
    );
  }

  final PostRepository postRepository;
  final AutocompleteRepository autocompleteRepository;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: autocompleteRepository),
      ],
      child: ProviderScope(
        overrides: [
          autocompleteRepoProvider.overrideWithValue(autocompleteRepository),
          postRepoProvider.overrideWithValue(postRepository),
          tagRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruTagRepoProvider)),
          downloadFileNameGeneratorProvider.overrideWith(
              (ref) => ref.watch(gelbooruDownloadFileNameGeneratorProvider)),
        ],
        child: Builder(
          builder: builder,
        ),
      ),
    );
  }
}

final gelbooruApiProvider = Provider<GelbooruApi>((ref) {
  final booruConfig = ref.read(currentBooruConfigProvider);
  final dio = ref.read(dioProvider(booruConfig.url));

  return GelbooruApi(dio);
});
