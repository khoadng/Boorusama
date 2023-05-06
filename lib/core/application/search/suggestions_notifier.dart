import 'dart:async';

import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestionsProvider =
    AsyncNotifierProvider<SuggestionsNotifier, List<AutocompleteData>>(
  SuggestionsNotifier.new,
  dependencies: [autocompleteRepoProvider],
);

class SuggestionsNotifier extends AsyncNotifier<List<AutocompleteData>> {
  SuggestionsNotifier() : super();

  @override
  FutureOr<List<AutocompleteData>> build() {
    return [];
  }

  Future<void> getSuggestions(String query) async {
    final data =
        await ref.read(autocompleteRepoProvider).getAutocomplete(query);
    state = AsyncData(data);
  }
}

mixin SuggestionsNotifierMixin<T> on Notifier<T> {
  void loadSuggestions(String query) =>
      ref.read(suggestionsProvider.notifier).getSuggestions(query);
}
