// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<Search> parseSearch(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => Search(
        keyword: item[0],
        hitCount: item[1].toInt(),
      ),
    );

class PopularSearchRepository implements IPopularSearchRepository {
  PopularSearchRepository({
    required IAccountRepository accountRepository,
    required Api api,
  })  : _accountRepository = accountRepository,
        _api = api;

  final IAccountRepository _accountRepository;
  final Api _api;

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
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception('Failed to get search stats for $date');
      }
    }
  }
}
