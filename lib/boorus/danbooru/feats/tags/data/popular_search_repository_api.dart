// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/http/http.dart';

List<Search> parseSearch(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => Search(
        keyword: item[0],
        hitCount: item[1].toInt(),
      ),
    );

class PopularSearchRepositoryApi implements PopularSearchRepository {
  PopularSearchRepositoryApi({
    required this.booruConfig,
    required DanbooruApi api,
  }) : _api = api;

  final BooruConfig booruConfig;
  final DanbooruApi _api;
  final _cache = <String, List<Search>>{};

  String _getKeyFromDateTime(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  @override
  Future<List<Search>> getSearchByDate(DateTime date) async {
    final key = _getKeyFromDateTime(date);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    try {
      final result = await _api
          .getPopularSearchByDate(
            booruConfig.login,
            booruConfig.apiKey,
            '${date.year}-${date.month}-${date.day}',
          )
          .then(parseSearch);
      _cache[key] = result;
      return result;
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get search stats for $date'),
          stackTrace,
        );
      }
    }
  }
}
