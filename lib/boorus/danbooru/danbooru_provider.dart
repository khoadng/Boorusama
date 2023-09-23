// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/autocomplete/autocomplete.dart';
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
      overrides: [],
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
