// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
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
    required AccountRepository accountRepository,
    required DanbooruApi api,
  })  : _accountRepository = accountRepository,
        _api = api;

  final AccountRepository _accountRepository;
  final DanbooruApi _api;

  @override
  Future<List<Search>> getSearchByDate(DateTime date) async {
    try {
      return _accountRepository
          .get()
          .then(
            (account) => _api.getPopularSearchByDate(
              account.username,
              account.apiKey,
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
