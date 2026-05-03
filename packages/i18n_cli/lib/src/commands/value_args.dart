import 'dart:convert';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../key_path.dart';

Map<String, Object?> parseTranslations(ArgResults results, String usage) {
  final translations = <String, Object?>{};

  for (final raw in results.multiOption('translation')) {
    final parsed = _parseLocaleValue(raw);
    translations[parsed.locale] = parsed.value;
  }

  for (final raw in results.multiOption('translation-json')) {
    final parsed = _parseLocaleValue(raw);
    translations[parsed.locale] = jsonDecode(parsed.value);
  }

  if (translations.isEmpty) {
    throw UsageException(
      'Provide at least one --translation or --translation-json value.',
      usage,
    );
  }

  return translations;
}

Object? parseSingleValue(ArgResults results, String usage) {
  final value = results.option('value');
  final valueJson = results.option('value-json');

  if (value != null && valueJson != null) {
    throw UsageException(
      'Use either --value or --value-json, not both.',
      usage,
    );
  }

  if (value != null) return value;
  if (valueJson != null) return jsonDecode(valueJson);

  throw UsageException('Provide --value or --value-json.', usage);
}

Map<KeyPath, Object?> parseKeyValues(List<String> rawValues, String usage) {
  if (rawValues.isEmpty) {
    throw UsageException('Provide at least one key=value pair.', usage);
  }

  final values = <KeyPath, Object?>{};
  final seen = <String>{};

  for (final raw in rawValues) {
    final separator = raw.indexOf('=');
    if (separator <= 0) {
      throw UsageException('Expected key=value, got "$raw".', usage);
    }

    final key = KeyPath.parse(raw.substring(0, separator));
    final keyText = key.toString();
    if (!seen.add(keyText)) {
      throw UsageException('Duplicate key in batch: $keyText.', usage);
    }

    values[key] = raw.substring(separator + 1);
  }

  return values;
}

_LocaleValue _parseLocaleValue(String raw) {
  final separator = raw.indexOf('=');
  if (separator <= 0) {
    throw FormatException('Expected locale=value, got "$raw".');
  }

  return _LocaleValue(
    locale: raw.substring(0, separator),
    value: raw.substring(separator + 1),
  );
}

final class _LocaleValue {
  const _LocaleValue({required this.locale, required this.value});

  final String locale;
  final String value;
}
