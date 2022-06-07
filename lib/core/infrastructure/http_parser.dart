// Package imports:
import 'package:retrofit/dio.dart';

List<T> parse<T>({
  required HttpResponse<dynamic> value,
  required T converter(dynamic item),
}) {
  final dtos = <T>[];

  for (var item in value.response.data) {
    try {
      dtos.add(converter(item));
    } catch (e) {
      print("Cant parse item");
    }
  }

  return dtos;
}
