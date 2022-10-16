// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';

class PoolDescriptionRepositoryApi implements PoolDescriptionRepository {
  const PoolDescriptionRepositoryApi({
    required Dio dio,
    required String endpoint,
  })  : _dio = dio,
        _endpoint = endpoint;

  final Dio _dio;
  final String _endpoint;

  @override
  Future<String> getDescription(int poolId) async =>
      _dio.get('${_endpoint}pools/$poolId').then((value) => value.data);
}
