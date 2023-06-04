// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/core/feat/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feat/boorus/providers.dart';
import 'package:boorusama/boorus/core/feat/downloads/downloads.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/moebooru/features/downloads/download_provider.dart';
import 'package:boorusama/boorus/moebooru/features/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/features/tags/tags.dart';

class MoebooruProvider extends StatelessWidget {
  const MoebooruProvider({
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
            .overrideWith((ref) => ref.watch(moebooruPostRepoProvider)),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(moebooruDownloadFileNameGeneratorProvider)),
        autocompleteRepoProvider
            .overrideWith((ref) => ref.watch(moebooruAutocompleteRepoProvider))
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final moebooruApiProvider = Provider<MoebooruApi>((ref) {
  final booruConfig = ref.read(currentBooruConfigProvider);
  final dio = ref.read(dioProvider(booruConfig.url));

  return MoebooruApi(dio);
});

final moebooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final tagSummaryRepository = ref.watch(moebooruTagSummaryProvider);

  return MoebooruAutocompleteRepository(
      tagSummaryRepository: tagSummaryRepository);
});

final moebooruTagSummaryProvider = Provider<TagSummaryRepository>((ref) {
  final api = ref.watch(moebooruApiProvider);

  return MoebooruTagSummaryRepository(api);
});
