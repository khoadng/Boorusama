/// Template utility functions for code generation
class TemplateUtils {
  /// Build a Dart map string from key-value pairs
  static String buildParamMapping(Map<String, String> params) {
    if (params.isEmpty) return '{}';

    final entries = params.entries
        .map((e) => "'${e.key}': '${e.value}'")
        .join(', ');

    return '{$entries}';
  }

  /// Build a Dart list string from values
  static String buildList(List<String> values) {
    if (values.isEmpty) return '[]';

    final items = values.map((value) => "'$value'").join(', ');
    return '[$items]';
  }

  /// Build a typed Dart map string
  static String buildTypedMap(
    Map<String, dynamic> params,
    String keyType,
    String valueType,
  ) {
    if (params.isEmpty) return '<$keyType, $valueType>{}';

    final entries = params.entries
        .map((e) => "'${e.key}': ${_formatValue(e.value)}")
        .join(', ');

    return '<$keyType, $valueType>{$entries}';
  }

  static String _formatValue(dynamic value) {
    return switch (value.runtimeType) {
      const (String) => "'$value'",
      const (bool) || const (int) || const (double) => value.toString(),
      _ => "'$value'",
    };
  }
}
