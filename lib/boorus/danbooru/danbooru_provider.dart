// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/count/post_count_provider.dart';
import 'package:boorusama/boorus/core/feats/tags/tags_providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';

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
        tagRepoProvider
            .overrideWith((ref) => ref.watch(danbooruTagRepoProvider)),
        noteRepoProvider
            .overrideWith((ref) => ref.watch(danbooruNoteRepoProvider)),
        postCountRepoProvider
            .overrideWith((ref) => ref.watch(danbooruPostCountRepoProvider)),
      ],
      child: Builder(builder: builder),
    );
  }
}

final danbooruClientProvider = Provider<DanbooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return DanbooruClient(
    dio: dio,
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
  );
});

final danbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final client = ref.watch(danbooruClientProvider);

  return AutocompleteRepositoryApi(client: client);
});
