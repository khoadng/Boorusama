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
        'localeVar': _sanitizeIdentifier(language.locale),
        'name': _escapeString(language.name),
        'isLast': index == languages.length - 1,
      };
    }).toList();

    final localeEntries = languages.asMap().entries.map((entry) {
      final index = entry.key;
      final language = entry.value;
      final localeParts = _parseLocale(language.locale);

      return {
        'languageCode': localeParts['languageCode'],
        'countryCode': localeParts['countryCode'],
        'comment': _escapeString(language.name),
        'isLast': index == languages.length - 1,
      };
    }).toList();

    return {
      'languages': languageEntries,
      'locales': localeEntries,
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

  String _sanitizeIdentifier(String value) {
    return value
        .replaceAll('-', '_')
        .replaceAll('\\', '_')
        .replaceAll('/', '_');
  }

  Map<String, String> _parseLocale(String locale) {
    final normalizedLocale = locale.replaceAll('\\', '/');
    final parts = normalizedLocale.split('-');
    return {
      'languageCode': parts.isNotEmpty ? parts[0] : '',
      'countryCode': parts.length > 1 ? parts[1] : '',
    };
  }
}
