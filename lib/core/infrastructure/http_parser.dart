// Package imports:
import 'package:retrofit/dio.dart';

List<T> parse<T>({
  required HttpResponse<dynamic> value,
  required T Function(dynamic item) converter,
  Function(dynamic item)? onError,
}) {
  final dtos = <T>[];

  for (final item in value.response.data) {
    try {
      dtos.add(converter(item));
    } catch (e) {
      // ignore: avoid_print
      print('Cant parse item');
      onError?.call(item);
    }
  }

  return dtos;
}
