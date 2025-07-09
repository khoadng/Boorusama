// Package imports:
import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';

extension DioResponseX<T> on Response<T> {
  bool get isFailure => statusCode.toOption().fold(
    () => true,
    (code) => code >= 400,
  );

  int get statusCodeOrZero => statusCode != null ? statusCode! : 0;
}
