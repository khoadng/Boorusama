class TemplateUtils {
  static String buildParamMapping(Map<String, String> params) {
    if (params.isEmpty) return '{}';

    final entries = params.entries
        .map((e) => "'${e.key}': '${e.value}'")
        .join(', ');

    return '{$entries}';
  }
}
