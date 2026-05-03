import 'unified_diff.dart';

final class OperationResult {
  const OperationResult({
    required this.ok,
    required this.operation,
    this.key,
    this.changedFiles = const [],
    this.missingLocales = const [],
    this.warnings = const [],
    this.diffs = const [],
    this.addedKeys = const [],
    this.existingKeys = const [],
    this.sameValueMatches = const [],
    this.replacements = const [],
    this.message,
  });

  final bool ok;
  final String operation;
  final String? key;
  final List<String> changedFiles;
  final List<String> missingLocales;
  final List<String> warnings;
  final List<FileDiff> diffs;
  final List<String> addedKeys;
  final List<ExistingKey> existingKeys;
  final List<SameValueMatch> sameValueMatches;
  final List<SourceReplacementResult> replacements;
  final String? message;

  Map<String, Object?> toJson() => {
    'ok': ok,
    'operation': operation,
    if (key != null) 'key': key,
    if (changedFiles.isNotEmpty) 'changedFiles': changedFiles,
    if (missingLocales.isNotEmpty) 'missingLocales': missingLocales,
    if (warnings.isNotEmpty) 'warnings': warnings,
    if (diffs.isNotEmpty) 'diffs': diffs.map((diff) => diff.toJson()).toList(),
    if (addedKeys.isNotEmpty) 'addedKeys': addedKeys,
    if (existingKeys.isNotEmpty)
      'existingKeys': existingKeys.map((key) => key.toJson()).toList(),
    if (sameValueMatches.isNotEmpty)
      'sameValueMatches': sameValueMatches
          .map((match) => match.toJson())
          .toList(),
    if (replacements.isNotEmpty)
      'replacements': replacements.map((entry) => entry.toJson()).toList(),
    if (message != null) 'message': message,
  };
}

final class ExistingKey {
  const ExistingKey({required this.key, required this.value});

  final String key;
  final Object? value;

  Map<String, Object?> toJson() => {
    'key': key,
    'value': value,
  };
}

final class SameValueMatch {
  const SameValueMatch({
    required this.proposedKey,
    required this.existingKey,
    required this.value,
  });

  final String proposedKey;
  final String existingKey;
  final Object? value;

  Map<String, Object?> toJson() => {
    'proposedKey': proposedKey,
    'existingKey': existingKey,
    'value': value,
  };
}

final class SourceReplacementResult {
  const SourceReplacementResult({
    required this.file,
    required this.from,
    required this.to,
    required this.count,
    required this.before,
    required this.after,
  });

  final String file;
  final String from;
  final String to;
  final int count;
  final String before;
  final String after;

  bool get changed => before != after;

  Map<String, Object?> toJson() => {
    'file': file,
    'from': from,
    'to': to,
    'count': count,
  };
}
