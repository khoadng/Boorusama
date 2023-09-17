// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientSavedSearches {
  Dio get dio;

  Future<List<SavedSearchDto>> getSavedSearches({
    int? page,
    int? limit,
  }) async {
    final response = await dio.get(
      '/saved_searches.json',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => SavedSearchDto.fromJson(item))
        .toList();
  }

  Future<SavedSearchDto> postSavedSearch({
    required String query,
    String? label,
  }) async {
    final formData = {
      'saved_search[label_string]': label ?? '',
      'saved_search[query]': query,
    };

    final response = await dio.post(
      '/saved_searches.json',
      data: formData,
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return SavedSearchDto.fromJson(response.data);
  }

  Future<void> patchSavedSearch({
    required int id,
    String? label,
    String? query,
  }) async {
    final formData = {
      if (query != null) 'saved_search[query]': query,
      if (label != null) 'saved_search[label_string]': label,
    };

    if (formData.isEmpty) {
      throw ArgumentError('At least one parameter must be provided');
    }

    final _ = await dio.patch(
      '/saved_searches/$id.json',
      data: formData,
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  Future<void> deleteSavedSearch({
    required int id,
  }) async {
    final _ = await dio.delete(
      '/saved_searches/$id.json',
    );
  }
}
