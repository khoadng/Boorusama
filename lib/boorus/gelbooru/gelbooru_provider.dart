// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru/application/downloads/download_provider.dart';
import 'package:boorusama/boorus/gelbooru/application/posts.dart';
import 'package:boorusama/boorus/gelbooru/application/tags/tags_provider.dart';
import 'package:boorusama/boorus/gelbooru/infra/autocompletes/gelbooru_autocomplete_repository_api.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/provider.dart';

class GelbooruProvider extends StatelessWidget {
  const GelbooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        bulkDownloadFileNameProvider
            .overrideWithValue(Md5OnlyFileNameGenerator()),
        postRepoProvider
            .overrideWith((ref) => ref.watch(gelbooruPostRepoProvider)),
        autocompleteRepoProvider
            .overrideWith((ref) => ref.watch(gelbooruAutocompleteRepoProvider)),
        tagRepoProvider
            .overrideWith((ref) => ref.watch(gelbooruTagRepoProvider)),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(gelbooruDownloadFileNameGeneratorProvider)),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final gelbooruApiProvider = Provider<GelbooruApi>((ref) {
  final booruConfig = ref.read(currentBooruConfigProvider);
  final dio = ref.read(dioProvider(booruConfig.url));

  return GelbooruApi(dio);
});

final gelbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final api = ref.watch(gelbooruApiProvider);

  return GelbooruAutocompleteRepositoryApi(api);
});
