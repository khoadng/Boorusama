import 'dart:io';
import 'package:codegen/codegen.dart';
import 'package:path/path.dart' show join;

const _kParsersPath = 'lib/src/gelbooru_v2/parsers';

class ParserRegistryGenerator extends TemplateGenerator<Set<String>> {
  @override
  String get templateName => 'parser_registry.mustache';

  @override
  String generate(Set<String> parserNames) {
    final availableParsers = _scanBarrelFile();
    _validateParsers(parserNames, availableParsers);

    return super.generate(parserNames);
  }

  @override
  Map<String, dynamic> buildContext(Set<String> parserNames) {
    final sortedParsers = parserNames.toList()..sort();

    return {
      'parsers': sortedParsers
          .asMap()
          .entries
          .map(
            (entry) => {
              'name': entry.value,
              'isLast': entry.key == sortedParsers.length - 1,
            },
          )
          .toList(),
      'hasImport': parserNames.isNotEmpty,
    };
  }

  Set<String> _scanBarrelFile() {
    final barrelFile = File(join(_kParsersPath, 'parsers.dart'));

    if (!barrelFile.existsSync()) {
      throw Exception('Parser barrel file not found: ${barrelFile.path}');
    }

    final content = barrelFile.readAsStringSync();
    final functions = <String>{};

    // Extract function names from exports
    final exportRegex = RegExp(r"export\s+'([^']+)';");

    for (final match in exportRegex.allMatches(content)) {
      final filePath = match.group(1)!;
      final file = File(join(_kParsersPath, filePath));

      if (file.existsSync()) {
        functions.addAll(_extractFunctions(file.readAsStringSync()));
      }
    }

    return functions;
  }

  Set<String> _extractFunctions(String content) {
    final functions = <String>{};

    // Match function signatures with more flexible pattern
    // Handles: ReturnType? functionName(, ReturnType<T> functionName(, etc.
    final functionRegex = RegExp(
      r'^\s*[A-Za-z_][A-Za-z0-9_<>,\s?]*\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(',
      multiLine: true,
    );

    for (final match in functionRegex.allMatches(content)) {
      final functionName = match.group(1)!;

      // Only include functions that start with 'parse'
      if (functionName.startsWith('parse')) {
        functions.add(functionName);
      }
    }

    return functions;
  }

  void _validateParsers(Set<String> required, Set<String> available) {
    final missing = required.difference(available);

    if (missing.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln('Parser validation failed:');
      buffer.writeln();

      for (final missingParser in missing) {
        buffer.writeln('  ❌ "$missingParser" not found');

        // Suggest similar parsers
        final suggestions = available
            .where((p) => _isSimilar(missingParser, p))
            .take(2)
            .toList();

        if (suggestions.isNotEmpty) {
          buffer.writeln(
            '     Did you mean: ${suggestions.map((s) => '"$s"').join(' or ')}?',
          );
        }
        buffer.writeln();
      }

      buffer.writeln('Available parsers:');
      for (final parser in available.toList()..sort()) {
        buffer.writeln('  ✓ $parser');
      }

      throw Exception(buffer.toString());
    }
  }

  bool _isSimilar(String a, String b) {
    // Simple similarity check - could be improved with Levenshtein distance
    if (a.length == b.length) {
      int differences = 0;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) differences++;
        if (differences > 2) return false;
      }
      return differences <= 2;
    }
    return false;
  }
}
