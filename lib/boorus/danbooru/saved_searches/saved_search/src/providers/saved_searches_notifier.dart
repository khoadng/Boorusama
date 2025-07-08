// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../foundation/utils/collection_utils.dart';
import '../types/saved_search.dart';
import '../types/saved_search_repository.dart';
import 'local_providers.dart';

final danbooruSavedSearchesProvider =
    AsyncNotifierProvider.family<
      SavedSearchesNotifier,
      List<SavedSearch>,
      BooruConfigAuth
    >(
      SavedSearchesNotifier.new,
    );

class SavedSearchesNotifier
    extends FamilyAsyncNotifier<List<SavedSearch>, BooruConfigAuth> {
  @override
  Future<List<SavedSearch>> build(BooruConfigAuth arg) async {
    final savedSearches = await _repo.getSavedSearches(page: 1);

    final searches = _sort(savedSearches);

    return searches;
  }

  SavedSearchRepository get _repo =>
      ref.read(danbooruSavedSearchRepoProvider(arg));

  Future<void> create({
    required String query,
    String? label,
    void Function(SavedSearch data)? onCreated,
    void Function()? onFailure,
  }) async {
    final savedSearch = await _repo.createSavedSearch(
      query: query,
      label: label,
    );

    if (savedSearch == null) {
      onFailure?.call();
    } else {
      state = AsyncData(
        _sort([
          ...state.value ?? [],
          savedSearch,
        ]),
      );

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

    final success = await _repo.deleteSavedSearch(savedSearch.id);

    if (success) {
      state = AsyncData(
        currentState.where((d) => d.id != savedSearch.id).toList(),
      );
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
    final success = await _repo.updateSavedSearch(
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
