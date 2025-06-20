// Dart imports:
import 'dart:convert';

List<String> queryAsList(String? query) {
  if (query == null) return [];
  final json = jsonDecode(query);

  if (json is! List) return [];

  try {
    return [for (final tag in json) tag as String];
  } catch (e) {
    return [];
  }
}
