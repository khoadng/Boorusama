// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/tags.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/time.dart';

class PopularSearchRepositoryApi implements PopularSearchRepository {
  PopularSearchRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;
  final _cache = <String, List<Search>>{};

  String _getKeyFromDateTime(DateTime date) => date.yyyyMMddWithHyphen();

  @override
  Future<List<Search>> getSearchByDate(DateTime date) async {
    final key = _getKeyFromDateTime(date);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    try {
      final result =
          await client.getPopularSearchByDate(date: date).then((value) => value
              .map((e) => Search(
                    hitCount: e.hitCount,
                    keyword: e.keyword,
                  ))
              .toList());
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
