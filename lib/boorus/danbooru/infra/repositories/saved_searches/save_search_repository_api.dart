// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/infra.dart';

List<SavedSearch> parseSavedSearch(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => SavedSearchDto.fromJson(item),
    ).map(savedSearchDtoToSaveSearch).toList();

class SavedSearchRepositoryApi implements SavedSearchRepository {
  const SavedSearchRepositoryApi(
    this.api,
    this.accountRepository,
  );

  final Api api;
  final AccountRepository accountRepository;

  @override
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  }) =>
      accountRepository
          .get()
          .then((account) => api.getSavedSearches(
                account.username,
                account.apiKey,
                page,
                //TODO: shouldn't hardcode it
                1000,
              ))
          .then(parseSavedSearch);

  @override
  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  }) =>
      accountRepository
          .get()
          .then((account) => api.postSavedSearch(
                account.username,
                account.apiKey,
                {
                  'saved_search[query]': query,
                  'saved_search[label_string]': label ?? '',
                },
              ))
          .then((value) => value.response.statusCode == 201
              ? _parseSingleSavedSearch(value)
              : null);

  @override
  Future<bool> updateSavedSearch(
    int id, {
    String? query,
    String? label,
  }) {
    if ([query, label].every((e) => e == null)) return Future.value(false);
    final map = <String, dynamic>{};

    if (query != null) {
      map['saved_search[query]'] = query;
    }

    if (label != null) {
      map['saved_search[label_string]'] = label;
    }

    return accountRepository
        .get()
        .then((account) => api.patchSavedSearch(
              account.username,
              account.apiKey,
              id,
              map,
            ))
        .then((value) => value.response.statusCode == 204);
  }

  @override
  Future<bool> deleteSavedSearch(int id) => accountRepository
      .get()
      .then((account) => api.deleteSavedSearch(
            account.username,
            account.apiKey,
            id,
          ))
      .then((value) => value.response.statusCode == 204);
}

SavedSearch savedSearchDtoToSaveSearch(SavedSearchDto dto) => SavedSearch(
      id: dto.id!,
      query: dto.query ?? '',
      labels: dto.labels ?? [],
      createdAt: dto.createdAt ?? DateTime(1),
      updatedAt: dto.updatedAt ?? DateTime(1),
      canDelete: dto.id! > 0,
    );

SavedSearch _parseSingleSavedSearch(HttpResponse<dynamic> value) =>
    savedSearchDtoToSaveSearch(
      SavedSearchDto.fromJson(value.response.data),
    );
