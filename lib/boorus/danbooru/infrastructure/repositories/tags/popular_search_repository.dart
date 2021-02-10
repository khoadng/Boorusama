// Package imports:
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';

final popularSearchProvider = Provider<IPopularSearchRepository>((ref) {
  return PopularSearchRepository(
      accountRepository: ref.watch(accountProvider),
      api: ref.watch(apiProvider));
});

class PopularSearchRepository implements IPopularSearchRepository {
  final IAccountRepository _accountRepository;
  final IApi _api;

  PopularSearchRepository(
      {@required IAccountRepository accountRepository, @required IApi api})
      : _accountRepository = accountRepository,
        _api = api;

  @override
  Future<List<Search>> getSearchByDate(DateTime date) async {
    final account = await _accountRepository.get();
    try {
      final value = await _api.getPopularSearchByDate(
        account.username,
        account.apiKey,
        "${date.year}-${date.month}-${date.day}",
      );

      final stats = value.response.data
          .map((e) => Search(keyword: e[0], hitCount: e[1].toInt()))
          .toList();

      return List<Search>.from(stats);
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception("Failed to get search stats for $date");
      }
    }
  }
}
