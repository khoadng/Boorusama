// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';

final zerochanClientProvider = Provider<ZerochanClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return ZerochanClient(dio: dio);
});

final zerochanAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final client = ref.watch(zerochanClientProvider);

  return AutocompleteRepositoryBuilder(autocomplete: (query) async {
    final tags = await client.getAutocomplete(query: query);

    return tags
        .map((e) => AutocompleteData(
              label: e.value?.toLowerCase() ?? '',
              value: e.value?.toLowerCase() ?? '',
              postCount: e.total,
              category: e.type?.toLowerCase() ?? '',
            ))
        .toList();
  });
});
