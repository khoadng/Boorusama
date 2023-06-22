// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/bulk_download_provider.dart';
import 'package:boorusama/boorus/core/feats/downloads/download_provider.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/tags/tags_providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

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
            .overrideWith((ref) => ref.watch(danbooruAutocompleteRepoProvider)),
        noteRepoProvider
            .overrideWith((ref) => ref.watch(danbooruNoteRepoProvider)),
      ],
      child: Builder(builder: builder),
    );
  }
}

String encodeDanbooruAuthHeader(String login, String apiKey) =>
    base64Encode('$login:$apiKey'.codeUnits);

final danbooruApiProvider = Provider<DanbooruApi>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  if (booruConfig.hasLoginDetails()) {
    dio.options.headers['Authorization'] =
        'Basic ${encodeDanbooruAuthHeader(booruConfig.login!, booruConfig.apiKey!)}';
  } else {
    dio.options.headers.remove('Authorization');
  }

  return DanbooruApi(dio);
});

final danbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return AutocompleteRepositoryApi(api: api);
});
