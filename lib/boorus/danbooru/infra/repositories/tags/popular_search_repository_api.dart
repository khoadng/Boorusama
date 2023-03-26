// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Search> parseSearch(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => Search(
        keyword: item[0],
        hitCount: item[1].toInt(),
      ),
    );

class PopularSearchRepositoryApi implements PopularSearchRepository {
  PopularSearchRepositoryApi({
    required CurrentBooruConfigRepository currentBooruConfigRepository,
    required DanbooruApi api,
  })  : _currentUserBooruRepository = currentBooruConfigRepository,
        _api = api;

  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final DanbooruApi _api;

  @override
  Future<List<Search>> getSearchByDate(DateTime date) async {
    try {
      return _currentUserBooruRepository
          .get()
          .then(
            (booruConfig) => _api.getPopularSearchByDate(
              booruConfig?.login,
              booruConfig?.apiKey,
              '${date.year}-${date.month}-${date.day}',
            ),
          )
          .then(parseSearch);
    } on DioError catch (e, stackTrace) {
      if (e.type == DioErrorType.cancel) {
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
