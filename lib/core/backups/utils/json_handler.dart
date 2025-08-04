// Project imports:
import '../types/types.dart';

abstract class JsonHandler<T> {
  T parse(ExportDataPayload metadata);
  List<dynamic> encode(T data);
}

class SingleHandler<T> extends JsonHandler<T> {
  SingleHandler({
    required this.parser,
    required this.encoder,
  });

  final T Function(Map<String, dynamic>) parser;
  final Map<String, dynamic> Function(T) encoder;

  @override
  T parse(ExportDataPayload metadata) {
    return parser(metadata.data.first as Map<String, dynamic>);
  }

  @override
  List<dynamic> encode(T data) {
    return [encoder(data)];
  }
}

class ListHandler<T> extends JsonHandler<List<T>> {
  ListHandler({
    required this.parser,
    required this.encoder,
  });

  final T Function(Map<String, dynamic>) parser;
  final Map<String, dynamic> Function(T) encoder;

  @override
  List<T> parse(ExportDataPayload metadata) {
    return metadata.data.map((e) => parser(e as Map<String, dynamic>)).toList();
  }

  @override
  List<dynamic> encode(List<T> data) {
    return data.map(encoder).toList();
  }
}
