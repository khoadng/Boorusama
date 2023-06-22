// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/foundation/http/http.dart';

List<SavedSearch> parseSavedSearch(HttpResponse<dynamic> value) =>
    parseResponse(
      value: value,
      converter: (item) => SavedSearchDto.fromJson(item),
    ).map(savedSearchDtoToSaveSearch).toList();

class SavedSearchRepositoryApi implements SavedSearchRepository {
  const SavedSearchRepositoryApi(
    this.api,
  );

  final DanbooruApi api;

  @override
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  }) =>
      api
          .getSavedSearches(
            page,
            //TODO: shouldn't hardcode it
            1000,
          )
          .then(parseSavedSearch);

  @override
  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  }) =>
      api.postSavedSearch(
        {
          'saved_search[query]': query,
          'saved_search[label_string]': label ?? '',
        },
      ).then((value) => value.response.statusCode == 201
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

    return api
        .patchSavedSearch(
          id,
          map,
        )
        .then((value) => value.response.statusCode == 204);
  }

  @override
  Future<bool> deleteSavedSearch(int id) => api
      .deleteSavedSearch(
        id,
      )
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
