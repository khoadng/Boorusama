import 'dart:io';

import 'package:path/path.dart' as p;

import 'cli_exception.dart';
import 'manifest.dart';
import 'operation_result.dart';
import 'translation_store.dart';
import 'unified_diff.dart';

final class ManifestApplier {
  ManifestApplier({required this.store});

  final TranslationStore store;

  OperationResult apply(
    I18nManifest manifest, {
    required bool dryRun,
    required bool includeDiff,
  }) {
    final batchResult = manifest.add.isEmpty
        ? const OperationResult(ok: true, operation: 'add-keys')
        : store.addKeys(
            locale: manifest.locale,
            values: manifest.add,
            dryRun: true,
            includeDiff: includeDiff,
          );

    final replacementResults = <SourceReplacementResult>[];
    final sourceDiffs = <FileDiff>[];
    final warnings = [...manifest.warnings];
    final fileStates = <String, _SourceFileState>{};
    var inferredCount = 0;

    for (final replacement in manifest.replace) {
      final result = _applyReplacement(
        replacement,
        fileStates: fileStates,
      );
      if (replacement.count == null) inferredCount += 1;
      replacementResults.add(result);
    }

    if (inferredCount > 0) {
      warnings.add('inferred counts for $inferredCount replacement(s)');
    }

    for (final state in fileStates.values) {
      if (includeDiff && state.changed) {
        sourceDiffs.add(
          FileDiff(
            file: state.file,
            diff: createUnifiedDiff(
              file: state.file,
              before: state.before,
              after: state.after,
            ),
          ),
        );
      }

      if (!dryRun && state.changed) {
        File(p.join(Directory.current.path, state.file)).writeAsStringSync(
          state.after,
        );
      }
    }

    if (!dryRun && manifest.add.isNotEmpty) {
      store.addKeys(
        locale: manifest.locale,
        values: manifest.add,
        dryRun: false,
        includeDiff: false,
      );
    }

    final changedFiles = {
      ...batchResult.changedFiles,
      for (final result in replacementResults)
        if (result.changed) result.file,
    }.toList();

    return OperationResult(
      ok: true,
      operation: 'apply',
      changedFiles: changedFiles,
      diffs: [
        if (includeDiff) ...batchResult.diffs,
        ...sourceDiffs,
      ],
      addedKeys: batchResult.addedKeys,
      existingKeys: batchResult.existingKeys,
      sameValueMatches: batchResult.sameValueMatches,
      replacements: replacementResults,
      warnings: warnings,
    );
  }

  SourceReplacementResult _applyReplacement(
    SourceReplacement replacement, {
    required Map<String, _SourceFileState> fileStates,
  }) {
    final state = fileStates.putIfAbsent(replacement.file, () {
      final file = File(p.join(Directory.current.path, replacement.file));
      if (!file.existsSync()) {
        throw CliException('Replacement file not found: ${replacement.file}');
      }

      return _SourceFileState(
        file: replacement.file,
        before: file.readAsStringSync(),
      );
    });

    final actualCount = _countOccurrences(state.after, replacement.from);
    if (replacement.count != null && actualCount != replacement.count) {
      throw CliException(
        'Replacement count mismatch for ${replacement.file}: '
        'expected ${replacement.count}, found $actualCount for ${replacement.from}',
      );
    }
    if (replacement.count == null) {
      if (actualCount == 0) {
        throw CliException(
          'Replacement text not found in ${replacement.file}: ${replacement.from}',
        );
      }
    }

    state.after = state.after.replaceAll(replacement.from, replacement.to);

    return SourceReplacementResult(
      file: replacement.file,
      from: replacement.from,
      to: replacement.to,
      count: replacement.count ?? actualCount,
      before: state.before,
      after: state.after,
    );
  }

  int _countOccurrences(String source, String pattern) {
    var count = 0;
    var index = 0;

    while (true) {
      index = source.indexOf(pattern, index);
      if (index < 0) return count;

      count += 1;
      index += pattern.length;
    }
  }
}

final class _SourceFileState {
  _SourceFileState({required this.file, required this.before}) : after = before;

  final String file;
  final String before;
  String after;

  bool get changed => before != after;
}
