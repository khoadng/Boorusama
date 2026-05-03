import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'cli_exception.dart';
import 'config.dart';
import 'json_document.dart';
import 'key_path.dart';
import 'operation_result.dart';
import 'placeholder_validator.dart';
import 'unified_diff.dart';

final class TranslationStore {
  TranslationStore(this.config);

  final I18nCliConfig config;
  final _placeholderValidator = const PlaceholderValidator();

  List<String> discoverLocales() {
    final directory = Directory(config.translationsDirectory);
    if (!directory.existsSync()) {
      throw CliException(
        'Translations directory not found: ${config.translationsDirectory}',
      );
    }

    final locales =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => p.extension(file.path) == '.json')
            .map((file) => p.basenameWithoutExtension(file.path))
            .toList()
          ..sort();

    return locales;
  }

  Object? getValue(String locale, KeyPath key) {
    final document = _readDocument(locale);

    return document.valueAt(key);
  }

  Map<String, Object?> getValues(KeyPath key, {String? locale}) {
    final locales = locale == null ? discoverLocales() : [locale];

    return {
      for (final locale in locales) locale: _readDocument(locale).valueAt(key),
    };
  }

  List<SearchMatch> search(String query, {String? locale, int limit = 50}) {
    final matches = <SearchMatch>[];
    final locales = locale == null ? discoverLocales() : [locale];
    final lowerQuery = query.toLowerCase();

    for (final locale in locales) {
      final json = _readJson(locale);
      for (final entry in _flatten(json).entries) {
        if (matches.length >= limit) return matches;

        final value = entry.value;
        final valueText = value is String ? value : jsonEncode(value);
        if (entry.key.toLowerCase().contains(lowerQuery) ||
            valueText.toLowerCase().contains(lowerQuery)) {
          matches.add(
            SearchMatch(locale: locale, key: entry.key, value: valueText),
          );
        }
      }
    }

    return matches;
  }

  List<MissingTranslation> missing({
    String? locale,
    KeyPath? prefix,
  }) {
    final baseJson = _readJson(config.baseLocale);
    final baseKeys = _flatten(baseJson).keys.map(KeyPath.parse).toList();
    final locales = locale == null
        ? discoverLocales().where((locale) => locale != config.baseLocale)
        : [locale];
    final missing = <MissingTranslation>[];

    for (final locale in locales) {
      final json = _readJson(locale);
      final flattened = _flatten(json);

      for (final key in baseKeys) {
        if (prefix != null && !key.startsWith(prefix)) continue;
        if (!flattened.containsKey(key.toString())) {
          missing.add(MissingTranslation(locale: locale, key: key.toString()));
        }
      }
    }

    return missing;
  }

  String tree({
    KeyPath? prefix,
    required int maxDepth,
  }) {
    final json = _readJson(config.baseLocale);
    final root = prefix == null ? json : _valueAt(json, prefix);

    if (root == null) {
      throw CliException('Key not found: $prefix');
    }

    if (root is! Map) {
      throw CliException('Key is not an object: $prefix');
    }

    final buffer = StringBuffer();
    final rootPath = prefix?.toString();

    if (rootPath != null) {
      buffer.writeln(rootPath);
    }

    _writeTree(
      value: root,
      depth: 0,
      maxDepth: maxDepth,
      indent: rootPath == null ? 0 : 1,
      buffer: buffer,
    );

    return buffer.toString();
  }

  OperationResult add({
    required KeyPath key,
    required Map<String, Object?> translations,
    required bool dryRun,
    required bool includeDiff,
  }) {
    final changedFiles = <String>[];
    final diffs = <FileDiff>[];
    final warnings = <String>[];
    final locales = discoverLocales();
    final baseValue =
        translations[config.baseLocale] ??
        _readDocument(config.baseLocale).valueAt(key);

    for (final entry in translations.entries) {
      _ensureLocaleExists(entry.key, locales);
      final document = _readDocument(entry.key);
      if (document.contains(key)) {
        throw CliException('Key already exists in ${entry.key}: $key');
      }

      warnings.addAll(
        _placeholderValidator.validate(
          key: key.toString(),
          baseValue: baseValue,
          locale: entry.key,
          localeValue: entry.value,
        ),
      );

      final file = _localeFile(entry.key);
      final before = file.readAsStringSync();
      final updated = document.add(key, entry.value);
      final relativePath = _relative(file.path);
      changedFiles.add(relativePath);

      if (includeDiff) {
        diffs.add(
          FileDiff(
            file: relativePath,
            diff: createUnifiedDiff(
              file: relativePath,
              before: before,
              after: updated,
            ),
          ),
        );
      }

      if (!dryRun) {
        file.writeAsStringSync(updated);
      }
    }

    final missingLocales = locales
        .where((locale) => !translations.containsKey(locale))
        .toList();

    return OperationResult(
      ok: true,
      operation: 'add',
      key: key.toString(),
      changedFiles: changedFiles,
      missingLocales: missingLocales,
      warnings: warnings,
      diffs: diffs,
    );
  }

  OperationResult addBatch({
    required KeyPath parent,
    required String locale,
    required Map<KeyPath, Object?> values,
    required bool dryRun,
    required bool includeDiff,
  }) {
    return _addKeys(
      locale: locale,
      values: {
        for (final entry in values.entries)
          parent.child(entry.key): entry.value,
      },
      operation: 'add-batch',
      key: parent.toString(),
      dryRun: dryRun,
      includeDiff: includeDiff,
    );
  }

  OperationResult addKeys({
    required String locale,
    required Map<KeyPath, Object?> values,
    required bool dryRun,
    required bool includeDiff,
  }) {
    return _addKeys(
      locale: locale,
      values: values,
      operation: 'add-keys',
      dryRun: dryRun,
      includeDiff: includeDiff,
    );
  }

  OperationResult _addKeys({
    required String locale,
    required Map<KeyPath, Object?> values,
    required String operation,
    String? key,
    required bool dryRun,
    required bool includeDiff,
  }) {
    _ensureLocaleExists(locale, discoverLocales());

    final file = _localeFile(locale);
    final before = file.readAsStringSync();
    final document = JsonDocument.parse(
      before,
      indent: config.indent,
      newlineAtEof: config.newlineAtEof,
    );
    final flattened = _flatten(_readJson(locale));
    final existingKeys = <ExistingKey>[];
    final sameValueMatches = <SameValueMatch>[];
    final pending = <MapEntry<KeyPath, Object?>>[];

    for (final entry in values.entries) {
      final keyText = entry.key.toString();
      final existingValue = document.valueAt(entry.key);

      if (document.contains(entry.key)) {
        existingKeys.add(ExistingKey(key: keyText, value: existingValue));
      } else {
        pending.add(MapEntry(entry.key, entry.value));
      }

      for (final flattenedEntry in flattened.entries) {
        if (flattenedEntry.key == keyText) continue;
        if (flattenedEntry.value != entry.value) continue;

        sameValueMatches.add(
          SameValueMatch(
            proposedKey: keyText,
            existingKey: flattenedEntry.key,
            value: entry.value,
          ),
        );
      }
    }

    var updated = before;
    for (final entry in pending) {
      updated = JsonDocument.parse(
        updated,
        indent: config.indent,
        newlineAtEof: config.newlineAtEof,
      ).add(entry.key, entry.value);
    }

    final relativePath = _relative(file.path);
    final changedFiles = pending.isEmpty ? <String>[] : [relativePath];
    final diffs = includeDiff && pending.isNotEmpty
        ? [
            FileDiff(
              file: relativePath,
              diff: createUnifiedDiff(
                file: relativePath,
                before: before,
                after: updated,
              ),
            ),
          ]
        : const <FileDiff>[];

    if (!dryRun && pending.isNotEmpty) {
      file.writeAsStringSync(updated);
    }

    return OperationResult(
      ok: true,
      operation: operation,
      key: key,
      changedFiles: changedFiles,
      diffs: diffs,
      addedKeys: pending.map((entry) => entry.key.toString()).toList(),
      existingKeys: existingKeys,
      sameValueMatches: sameValueMatches,
    );
  }

  OperationResult set({
    required String locale,
    required KeyPath key,
    required Object? value,
    required bool create,
    required bool dryRun,
    required bool includeDiff,
  }) {
    _ensureLocaleExists(locale, discoverLocales());

    final baseValue = locale == config.baseLocale
        ? value
        : _readDocument(config.baseLocale).valueAt(key);
    final warnings = _placeholderValidator.validate(
      key: key.toString(),
      baseValue: baseValue,
      locale: locale,
      localeValue: value,
    );
    final document = _readDocument(locale);
    final file = _localeFile(locale);
    final before = file.readAsStringSync();
    final updated = document.set(key, value, create: create);
    final relativePath = _relative(file.path);

    if (!dryRun) {
      file.writeAsStringSync(updated);
    }

    return OperationResult(
      ok: true,
      operation: 'set',
      key: key.toString(),
      changedFiles: [relativePath],
      warnings: warnings,
      diffs: includeDiff
          ? [
              FileDiff(
                file: relativePath,
                diff: createUnifiedDiff(
                  file: relativePath,
                  before: before,
                  after: updated,
                ),
              ),
            ]
          : const [],
    );
  }

  OperationResult remove({
    required KeyPath key,
    required List<String> locales,
    required bool dryRun,
    required bool includeDiff,
  }) {
    final knownLocales = discoverLocales();
    final changedFiles = <String>[];
    final diffs = <FileDiff>[];

    for (final locale in locales) {
      _ensureLocaleExists(locale, knownLocales);
      final document = _readDocument(locale);
      final file = _localeFile(locale);
      final before = file.readAsStringSync();
      final updated = document.remove(key);
      final relativePath = _relative(file.path);
      changedFiles.add(relativePath);

      if (includeDiff) {
        diffs.add(
          FileDiff(
            file: relativePath,
            diff: createUnifiedDiff(
              file: relativePath,
              before: before,
              after: updated,
            ),
          ),
        );
      }

      if (!dryRun) {
        file.writeAsStringSync(updated);
      }
    }

    return OperationResult(
      ok: true,
      operation: 'remove',
      key: key.toString(),
      changedFiles: changedFiles,
      diffs: diffs,
    );
  }

  OperationResult rename({
    required KeyPath from,
    required KeyPath to,
    required List<String> locales,
    required bool dryRun,
    required bool includeDiff,
  }) {
    final knownLocales = discoverLocales();
    final changedFiles = <String>[];
    final diffs = <FileDiff>[];

    for (final locale in locales) {
      _ensureLocaleExists(locale, knownLocales);
      final document = _readDocument(locale);
      final file = _localeFile(locale);
      final before = file.readAsStringSync();
      final updated = document.rename(from, to);
      final relativePath = _relative(file.path);
      changedFiles.add(relativePath);

      if (includeDiff) {
        diffs.add(
          FileDiff(
            file: relativePath,
            diff: createUnifiedDiff(
              file: relativePath,
              before: before,
              after: updated,
            ),
          ),
        );
      }

      if (!dryRun) {
        file.writeAsStringSync(updated);
      }
    }

    return OperationResult(
      ok: true,
      operation: 'rename',
      key: from.toString(),
      changedFiles: changedFiles,
      diffs: diffs,
    );
  }

  OperationResult format({
    required List<String> locales,
    required bool dryRun,
    required bool includeDiff,
  }) {
    final knownLocales = discoverLocales();
    final changedFiles = <String>[];
    final diffs = <FileDiff>[];
    final encoder = JsonEncoder.withIndent(' ' * config.indent);

    for (final locale in locales) {
      _ensureLocaleExists(locale, knownLocales);
      final file = _localeFile(locale);
      final json = _readJson(locale);
      final formatted = '${encoder.convert(json)}\n';
      final before = file.readAsStringSync();

      if (formatted != before) {
        final relativePath = _relative(file.path);
        changedFiles.add(relativePath);
        if (includeDiff) {
          diffs.add(
            FileDiff(
              file: relativePath,
              diff: createUnifiedDiff(
                file: relativePath,
                before: before,
                after: formatted,
              ),
            ),
          );
        }
        if (!dryRun) {
          file.writeAsStringSync(formatted);
        }
      }
    }

    return OperationResult(
      ok: true,
      operation: 'format',
      changedFiles: changedFiles,
      diffs: diffs,
    );
  }

  List<String> validate() {
    final warnings = <String>[];
    final locales = discoverLocales();
    final baseJson = _readJson(config.baseLocale);
    final baseFlattened = _flatten(baseJson);

    for (final locale in locales) {
      final json = _readJson(locale);
      final flattened = _flatten(json);

      for (final entry in flattened.entries) {
        final baseValue = baseFlattened[entry.key];
        if (baseValue == null) continue;

        warnings.addAll(
          _placeholderValidator.validate(
            key: entry.key,
            baseValue: baseValue,
            locale: locale,
            localeValue: entry.value,
          ),
        );
      }

      for (final entry in baseFlattened.entries) {
        final localeValue = flattened[entry.key];
        if (localeValue == null) continue;
        if (!_compatibleShape(entry.value, localeValue)) {
          warnings.add(
            '$locale:${entry.key} has incompatible value shape with base locale',
          );
        }
      }
    }

    return warnings;
  }

  Map<String, Object?> _flatten(Object? value, [String prefix = '']) {
    if (value is Map) {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final path = prefix.isEmpty ? key : '$prefix.$key';
        final child = entry.value;

        if (child is Map) {
          result.addAll(_flatten(child, path));
        } else {
          result[path] = child;
        }
      }

      return result;
    }

    return {prefix: value};
  }

  Object? _valueAt(Object? value, KeyPath path) {
    var current = value;

    for (final segment in path.segments) {
      if (current is! Map) return null;
      if (!current.containsKey(segment)) return null;

      current = current[segment];
    }

    return current;
  }

  void _writeTree({
    required Map<dynamic, dynamic> value,
    required int depth,
    required int maxDepth,
    required int indent,
    required StringBuffer buffer,
  }) {
    for (final entry in value.entries) {
      final key = entry.key.toString();
      buffer
        ..write('  ' * indent)
        ..writeln(key);

      if (entry.value is Map) {
        if (depth >= maxDepth) continue;

        _writeTree(
          value: entry.value,
          depth: depth + 1,
          maxDepth: maxDepth,
          indent: indent + 1,
          buffer: buffer,
        );
      }
    }
  }

  bool _compatibleShape(Object? baseValue, Object? localeValue) {
    if (baseValue is Map || localeValue is Map) {
      if (baseValue is! Map || localeValue is! Map) return false;

      return true;
    }

    return true;
  }

  JsonDocument _readDocument(String locale) {
    final file = _localeFile(locale);
    if (!file.existsSync()) {
      throw CliException('Locale file not found: ${file.path}');
    }

    return JsonDocument.parse(
      file.readAsStringSync(),
      indent: config.indent,
      newlineAtEof: config.newlineAtEof,
    );
  }

  Object? _readJson(String locale) {
    final file = _localeFile(locale);
    if (!file.existsSync()) {
      throw CliException('Locale file not found: ${file.path}');
    }

    return jsonDecode(file.readAsStringSync());
  }

  File _localeFile(String locale) => File(
    p.join(config.translationsDirectory, '$locale.json'),
  );

  String _relative(String path) =>
      p.relative(path, from: Directory.current.path);

  void _ensureLocaleExists(String locale, List<String> knownLocales) {
    if (!knownLocales.contains(locale)) {
      throw CliException('Unknown locale: $locale');
    }
  }
}

final class SearchMatch {
  const SearchMatch({
    required this.locale,
    required this.key,
    required this.value,
  });

  final String locale;
  final String key;
  final String value;

  Map<String, Object?> toJson() => {
    'locale': locale,
    'key': key,
    'value': value,
  };
}

final class MissingTranslation {
  const MissingTranslation({required this.locale, required this.key});

  final String locale;
  final String key;

  Map<String, Object?> toJson() => {
    'locale': locale,
    'key': key,
  };
}
