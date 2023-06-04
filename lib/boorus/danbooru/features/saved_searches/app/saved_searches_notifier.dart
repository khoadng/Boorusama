// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/saved_searches/saved_searches.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/utils/collection_utils.dart';

class SavedSearchesNotifier extends Notifier<List<SavedSearch>?> {
  @override
  List<SavedSearch>? build() {
    ref.watch(currentBooruConfigProvider);
    fetch();

    return null;
  }

  SavedSearchRepository get repo => ref.read(danbooruSavedSearchRepoProvider);

  Future<List<SavedSearch>> fetch() async {
    final savedSearches = await repo.getSavedSearches(page: 1);

    final searches = _sort(savedSearches);

    state = searches;

    return searches;
  }

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
      state = _sort([
        ...state ?? [],
        savedSearch,
      ]);

      onCreated?.call(savedSearch);
    }
  }

  Future<void> delete({
    required SavedSearch savedSearch,
    void Function(SavedSearch data)? onDeleted,
    void Function()? onFailure,
  }) async {
    if (state == null) return;
    if (!savedSearch.canDelete) return;

    final success = await repo.deleteSavedSearch(savedSearch.id);

    if (success) {
      state = state!.where((d) => d.id != savedSearch.id).toList();
      onDeleted?.call(savedSearch);
    } else {
      onFailure?.call();
    }
  }

  Future<void> update({
    required int id,
    String? query,
    String? label,
    void Function(SavedSearch data)? onUpdated,
    void Function()? onFailure,
  }) async {
    if (state == null) return;
    final success = await repo.updateSavedSearch(
      id,
      query: query,
      label: label,
    );

    if (success) {
      final index = state!.indexWhere((e) => e.id == id);
      final newSearch = state![index];
      final newData = [...state!].replaceAt(
        index,
        newSearch.copyWith(
          query: query,
          labels: label != null ? [label] : null,
        ),
      );

      state = _sort(newData);

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
