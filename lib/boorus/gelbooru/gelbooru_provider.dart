// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/gelbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/tags.dart';

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
        postArtistCharacterRepoProvider.overrideWith(
            (ref) => ref.watch(gelbooruArtistCharacterPostRepoProvider)),
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
