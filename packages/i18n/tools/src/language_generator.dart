import 'package:codegen/codegen.dart';

import 'language_data.dart';

class LanguageGenerator extends TemplateGenerator<List<LanguageData>> {
  @override
  String get templateName => 'languages.mustache';

  @override
  Map<String, dynamic> buildContext(List<LanguageData> languages) {
    final languageEntries = languages.asMap().entries.map((entry) {
      final index = entry.key;
      final language = entry.value;

      return {
        'locale': language.locale,
        'name': _escapeString(language.name),
        'isLast': index == languages.length - 1,
      };
    }).toList();

    return {
      'languages': languageEntries,
      'count': languages.length,
    };
  }

  String _escapeString(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
