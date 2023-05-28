// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/downloads/download_provider.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/danbooru_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/provider.dart';

class DanbooruProvider extends ConsumerWidget {
  const DanbooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        postRepoProvider
            .overrideWith((ref) => ref.watch(danbooruPostRepoProvider)),
        bulkDownloadFileNameProvider
            .overrideWithValue(BoorusamaStyledFileNameGenerator()),
        tagRepoProvider
            .overrideWith((ref) => ref.watch(danbooruTagRepoProvider)),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(danbooruDownloadFileNameGeneratorProvider)),
        autocompleteRepoProvider
            .overrideWith((ref) => ref.watch(danbooruAutocompleteRepoProvider))
      ],
      child: Builder(builder: builder),
    );
  }
}

final danbooruApiProvider = Provider<DanbooruApi>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return DanbooruApi(dio);
});

final danbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return AutocompleteRepositoryApi(
    api: api,
    booruConfig: booruConfig,
  );
});
