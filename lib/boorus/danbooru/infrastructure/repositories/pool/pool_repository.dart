// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool_dto.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<Pool> parsePool(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PoolDto.fromJson(item),
    ).map(poolDtoToPool).toList();

class PoolRepository {
  PoolRepository(
    this._api,
    this._accountRepository,
  );

  final IApi _api;
  final IAccountRepository _accountRepository;
  final _limit = 50;

  Future<List<Pool>> getPools() =>
      _accountRepository.get().then((account) => _api
          .getPools(
            account.username,
            account.apiKey,
            _limit,
          )
          .then(parsePool));

  Future<List<Pool>> getPoolsByPostId(int postId) =>
      _accountRepository.get().then((account) => _api
          .getPoolsFromPostId(
            account.username,
            account.apiKey,
            postId,
            _limit,
          )
          .then(parsePool));
}
