// Package imports:
import 'package:retrofit/dio.dart';

List<T> parseResponse<T>({
  required HttpResponse<dynamic> value,
  required T Function(dynamic item) converter,
}) {
  final dtos = <T>[];

  for (final item in value.response.data) {
    dtos.add(converter(item));
  }

  return dtos;
}

Map<String, dynamic> extractData(HttpResponse<dynamic> value) => value.data;
