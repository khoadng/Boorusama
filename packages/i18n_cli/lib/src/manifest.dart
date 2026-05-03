import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'cli_exception.dart';
import 'key_path.dart';

final class I18nManifest {
  const I18nManifest({
    required this.locale,
    required this.add,
    required this.replace,
    this.warnings = const [],
  });

  factory I18nManifest.read(File file, {required String defaultLocale}) {
    if (!file.existsSync()) {
      throw CliException('Manifest file not found: ${file.path}');
    }

    final decoded = _decodeTolerant(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw const CliException('Manifest root must be a JSON object.');
    }

    final locale = decoded['locale']?.toString() ?? defaultLocale;
    final warnings = <String>[];
    final parent = decoded['parent']?.toString();
    final add = _readAdd(
      decoded['add'] ?? decoded['keys'] ?? decoded['translations'],
      parent: parent,
      warnings: warnings,
    );
    final replace = _readReplace(
      decoded['replace'] ?? decoded['replacements'],
      warnings: warnings,
    );
    _normalizePlaceholdersFromReplacements(add, replace, warnings);

    if (add.isEmpty && replace.isEmpty) {
      throw const CliException('Manifest must contain add or replace entries.');
    }

    return I18nManifest(
      locale: locale,
      add: add,
      replace: replace,
      warnings: warnings,
    );
  }

  final String locale;
  final Map<KeyPath, Object?> add;
  final List<SourceReplacement> replace;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'locale': locale,
    'add': {
      for (final entry in add.entries) entry.key.toString(): entry.value,
    },
    'replace': replace.map((entry) => entry.toJson()).toList(),
  };

  static Map<KeyPath, Object?> _readAdd(
    Object? value, {
    required String? parent,
    required List<String> warnings,
  }) {
    if (value == null) return const {};
    if (value is List) {
      return _readAddList(value, parent: parent, warnings: warnings);
    }
    if (value is! Map<String, dynamic>) {
      throw const CliException('Manifest add must be an object or array.');
    }

    return {
      for (final entry in value.entries)
        _normalizeAddKey(entry.key, parent, warnings): entry.value,
    };
  }

  static Map<KeyPath, Object?> _readAddList(
    List<Object?> value, {
    required String? parent,
    required List<String> warnings,
  }) {
    final result = <KeyPath, Object?>{};
    var relativeKeyCount = 0;

    for (final item in value) {
      if (item is! Map<String, dynamic>) {
        throw const CliException('Manifest keys entries must be objects.');
      }

      final key = item['key'] ?? item['path'] ?? item['name'];
      if (key is! String || key.isEmpty) {
        throw const CliException('Manifest key entry needs key/path/name.');
      }

      if (!item.containsKey('value') &&
          !item.containsKey('text') &&
          !item.containsKey('translation')) {
        throw CliException(
          'Manifest key entry needs value/text/translation: $key',
        );
      }

      final normalizedKey = _normalizeAddKey(key, parent, null);
      if (parent != null && parent.isNotEmpty && !key.startsWith('$parent.')) {
        relativeKeyCount += 1;
      }

      result[normalizedKey] =
          item['value'] ?? item['text'] ?? item['translation'];
    }

    if (relativeKeyCount > 0) {
      warnings.add(
        'normalized $relativeKeyCount relative key(s) under $parent',
      );
    }

    return result;
  }

  static KeyPath _normalizeAddKey(
    String key,
    String? parent,
    List<String>? warnings,
  ) {
    if (parent == null || parent.isEmpty || key.startsWith('$parent.')) {
      return KeyPath.parse(key);
    }

    warnings?.add('normalized relative key $key -> $parent.$key');

    return KeyPath.parse('$parent.$key');
  }

  static List<SourceReplacement> _readReplace(
    Object? value, {
    required List<String> warnings,
  }) {
    if (value == null) return const [];
    if (value is! List) {
      throw const CliException('Manifest replace must be an array.');
    }

    var pathAliasCount = 0;
    var fromAliasCount = 0;
    var toAliasCount = 0;
    final replacements = <SourceReplacement>[];

    for (final entry in value) {
      final replacement = SourceReplacement.fromJson(entry);
      replacements.add(replacement);

      if (entry is Map<String, dynamic>) {
        if (entry['file'] == null && entry['path'] != null) pathAliasCount += 1;
        if (entry['from'] == null &&
            (entry['old'] != null || entry['source'] != null)) {
          fromAliasCount += 1;
        }
        if (entry['to'] == null &&
            (entry['new'] != null || entry['replacement'] != null)) {
          toAliasCount += 1;
        }
      }
    }

    if (pathAliasCount > 0) {
      warnings.add('normalized path -> file in $pathAliasCount replacement(s)');
    }
    if (fromAliasCount > 0) {
      warnings.add(
        'normalized old/source -> from in $fromAliasCount replacement(s)',
      );
    }
    if (toAliasCount > 0) {
      warnings.add(
        'normalized new/replacement -> to in $toAliasCount replacement(s)',
      );
    }

    return replacements;
  }

  static Object? _decodeTolerant(String source) {
    final extracted = _extractJsonObject(source);
    try {
      return jsonDecode(extracted);
    } on FormatException {
      return jsonDecode(_stripTrailingCommas(extracted));
    }
  }

  static String _extractJsonObject(String source) {
    final fenceMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      multiLine: true,
    ).firstMatch(source);
    final text = fenceMatch?.group(1) ?? source;
    final start = text.indexOf('{');
    if (start < 0) {
      throw const CliException('Manifest does not contain a JSON object.');
    }

    var depth = 0;
    var inString = false;
    var escaping = false;

    for (var i = start; i < text.length; i++) {
      final char = text[i];

      if (escaping) {
        escaping = false;
        continue;
      }
      if (char == r'\') {
        escaping = inString;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (char == '{') depth += 1;
      if (char == '}') depth -= 1;
      if (depth == 0) {
        return text.substring(start, i + 1);
      }
    }

    throw const CliException('Manifest JSON object is incomplete.');
  }

  static String _stripTrailingCommas(String source) {
    return source.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1)!,
    );
  }

  static void _normalizePlaceholdersFromReplacements(
    Map<KeyPath, Object?> add,
    List<SourceReplacement> replace,
    List<String> warnings,
  ) {
    final keysWithCalls = <String, Set<String>>{};

    for (final replacement in replace) {
      final match = RegExp(
        r'context\.t\.([A-Za-z0-9_\.]+)\(([^)]*)\)',
      ).firstMatch(replacement.to);
      if (match == null) continue;

      final key = match.group(1)!;
      final arguments = match.group(2)!;
      final names = RegExp(
        r'([A-Za-z_][A-Za-z0-9_]*)\s*:',
      ).allMatches(arguments);
      keysWithCalls[key] = {
        for (final name in names) name.group(1)!,
      };
    }

    for (final entry in add.entries.toList()) {
      final key = entry.key.toString();
      final names = keysWithCalls[key];
      final value = entry.value;
      if (names == null || names.isEmpty || value is! String) continue;

      var normalized = value;
      for (final name in names) {
        normalized = normalized.replaceAll('{$name}', '\$$name');
      }

      if (normalized != value) {
        add[entry.key] = normalized;
        warnings.add('normalized placeholder in $key');
      }
    }
  }
}

final class SourceReplacement {
  const SourceReplacement({
    required this.file,
    required this.from,
    required this.to,
    this.count,
  });

  factory SourceReplacement.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const CliException('Replacement entry must be an object.');
    }

    final file = value['file'] ?? value['path'];
    final from = value['from'] ?? value['old'] ?? value['source'];
    final to = value['to'] ?? value['new'] ?? value['replacement'];
    final count = value['count'];

    if (file is! String || file.isEmpty) {
      throw const CliException('Replacement file must be a non-empty string.');
    }
    if (p.isAbsolute(file) || p.split(file).contains('..')) {
      throw CliException('Replacement file must be repo-relative: $file');
    }
    if (from is! String || from.isEmpty) {
      throw const CliException('Replacement from must be a non-empty string.');
    }
    if (to is! String) {
      throw const CliException('Replacement to must be a string.');
    }
    if (count != null && (count is! int || count < 1)) {
      throw const CliException('Replacement count must be a positive integer.');
    }
    return SourceReplacement(file: file, from: from, to: to, count: count);
  }

  final String file;
  final String from;
  final String to;
  final int? count;

  Map<String, Object?> toJson() => {
    'file': file,
    'from': from,
    'to': to,
    if (count != null) 'count': count,
  };
}
