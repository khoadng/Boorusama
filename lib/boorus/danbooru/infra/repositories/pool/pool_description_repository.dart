// Package imports:
import 'package:dio/dio.dart';

class PoolDescriptionRepository {
  const PoolDescriptionRepository({
    required Dio dio,
    required String endpoint,
  })  : _dio = dio,
        _endpoint = endpoint;

  final Dio _dio;
  final String _endpoint;

  Future<String> getDescription(int poolId) async =>
      _dio.get('${_endpoint}pools/$poolId').then((value) => value.data);
}
