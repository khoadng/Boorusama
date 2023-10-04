// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/dart.dart';

class SavedSearchesNotifier
    extends FamilyAsyncNotifier<List<SavedSearch>, BooruConfig> {
  @override
  Future<List<SavedSearch>> build(BooruConfig arg) async {
    final savedSearches = await repo.getSavedSearches(page: 1);

    final searches = _sort(savedSearches);

    return searches;
  }

  SavedSearchRepository get repo =>
      ref.read(danbooruSavedSearchRepoProvider(arg));

  Future<void> create({
    required String query,
    String? label,
    void Function(SavedSearch data)? onCreated,
    void Function()? onFailure,
  }) async {
    final savedSearch = await repo.createSavedSearch(
      query: query,
      label: label,
    );

    if (savedSearch == null) {
      onFailure?.call();
    } else {
      state = AsyncData(_sort([
        ...state.value ?? [],
        savedSearch,
      ]));

      onCreated?.call(savedSearch);
    }
  }

  Future<void> delete({
    required SavedSearch savedSearch,
    void Function(SavedSearch data)? onDeleted,
    void Function()? onFailure,
  }) async {
    final currentState = state.value;

    if (currentState == null) return;
    if (!savedSearch.canDelete) return;

    final success = await repo.deleteSavedSearch(savedSearch.id);

    if (success) {
      state =
          AsyncData(currentState.where((d) => d.id != savedSearch.id).toList());
      onDeleted?.call(savedSearch);
    } else {
      onFailure?.call();
    }
  }

  Future<void> edit({
    required int id,
    String? query,
    String? label,
    void Function(SavedSearch data)? onUpdated,
    void Function()? onFailure,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;
    final success = await repo.updateSavedSearch(
      id,
      query: query,
      label: label,
    );

    if (success) {
      final index = currentState.indexWhere((e) => e.id == id);
      final newSearch = currentState[index];
      final newData = [...currentState].replaceAt(
        index,
        newSearch.copyWith(
          query: query,
          labels: label != null ? [label] : null,
        ),
      );

      state = AsyncData(_sort(newData));

      onUpdated?.call(newSearch);
    } else {
      onFailure?.call();
    }
  }
}

List<SavedSearch> _sort(List<SavedSearch> items) {
  final group = items.groupBy((d) => d.labels.isEmpty);
  final hasLabelItems = group[false] ?? [];
  final noLabelItems = group[true] ?? [];

  return [
    ...noLabelItems,
    ...hasLabelItems..sort((a, b) => a.labels.first.compareTo(b.labels.first)),
  ];
}
