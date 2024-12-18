// Package imports:

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'creator.dart';

abstract interface class CreatorRepository {
  Future<List<Creator>> getCreatorsByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  });
}
