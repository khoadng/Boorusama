import 'dart:convert';

import 'cli_exception.dart';
import 'key_path.dart';

sealed class JsonNode {
  const JsonNode({required this.start, required this.end});

  final int start;
  final int end;
}

final class JsonObjectNode extends JsonNode {
  const JsonObjectNode({
    required super.start,
    required super.end,
    required this.entries,
  });

  final List<JsonEntryNode> entries;

  JsonEntryNode? entry(String key) {
    for (final entry in entries) {
      if (entry.key == key) return entry;
    }

    return null;
  }
}

final class JsonArrayNode extends JsonNode {
  const JsonArrayNode({
    required super.start,
    required super.end,
    required this.values,
  });

  final List<JsonNode> values;
}

final class JsonStringNode extends JsonNode {
  const JsonStringNode({
    required super.start,
    required super.end,
    required this.value,
  });

  final String value;
}

final class JsonLiteralNode extends JsonNode {
  const JsonLiteralNode({
    required super.start,
    required super.end,
    required this.value,
  });

  final Object? value;
}

final class JsonEntryNode {
  const JsonEntryNode({
    required this.key,
    required this.keyStart,
    required this.keyEnd,
    required this.value,
  });

  final String key;
  final int keyStart;
  final int keyEnd;
  final JsonNode value;
}

final class JsonDocument {
  JsonDocument._({
    required this.source,
    required this.root,
    required this.indent,
    required this.newlineAtEof,
  });

  factory JsonDocument.parse(
    String source, {
    int indent = 2,
    bool newlineAtEof = true,
  }) {
    final parser = _JsonSourceParser(source);
    final root = parser.parse();

    if (root is! JsonObjectNode) {
      throw const FormatException(
        'Translation file root must be a JSON object.',
      );
    }

    return JsonDocument._(
      source: source,
      root: root,
      indent: indent,
      newlineAtEof: newlineAtEof,
    );
  }

  final String source;
  final JsonObjectNode root;
  final int indent;
  final bool newlineAtEof;

  Object? valueAt(KeyPath path) {
    final node = _nodeAt(path);
    if (node == null) return null;

    return jsonDecode(source.substring(node.start, node.end));
  }

  bool contains(KeyPath path) => _nodeAt(path) != null;

  String add(KeyPath path, Object? value) {
    final existing = _nodeAt(path);
    if (existing != null) {
      throw CliException('Key already exists: $path');
    }

    final target = _nearestExistingObject(path);
    final missingSegments = path.segments.skip(target.depth).toList();
    final key = missingSegments.first;
    final nestedValue = _nestedValue(missingSegments.skip(1).toList(), value);

    return _insertIntoObject(target.node, key, nestedValue);
  }

  String set(KeyPath path, Object? value, {required bool create}) {
    final node = _nodeAt(path);
    if (node == null) {
      if (!create) {
        throw CliException('Key not found: $path');
      }

      return add(path, value);
    }

    return _replaceRange(
      source,
      node.start,
      node.end,
      _renderValue(value, _indentLevelForOffset(node.start)),
    );
  }

  String remove(KeyPath path) {
    final parent = _objectAt(path.parent);
    if (parent == null) {
      throw CliException('Key not found: $path');
    }

    final index = parent.entries.indexWhere((entry) => entry.key == path.leaf);
    if (index < 0) {
      throw CliException('Key not found: $path');
    }

    final entry = parent.entries[index];
    if (parent.entries.length == 1) {
      return _replaceRange(source, parent.start, parent.end, '{}');
    }

    if (index == 0) {
      final next = parent.entries[index + 1];
      return _replaceRange(
        source,
        _lineStart(entry.keyStart),
        _lineStart(next.keyStart),
        '',
      );
    }

    final previous = parent.entries[index - 1];

    return _replaceRange(source, previous.value.end, entry.value.end, '');
  }

  String rename(KeyPath from, KeyPath to) {
    if (from.parent?.toString() != to.parent?.toString()) {
      final value = valueAt(from);
      if (value == null && !contains(from)) {
        throw CliException('Key not found: $from');
      }

      final added = JsonDocument.parse(
        source,
        indent: indent,
        newlineAtEof: newlineAtEof,
      ).add(to, value);

      return JsonDocument.parse(
        added,
        indent: indent,
        newlineAtEof: newlineAtEof,
      ).remove(from);
    }

    final parent = _objectAt(from.parent);
    final entry = parent?.entry(from.leaf);
    if (entry == null) {
      throw CliException('Key not found: $from');
    }

    if (parent!.entry(to.leaf) != null) {
      throw CliException('Key already exists: $to');
    }

    return _replaceRange(
      source,
      entry.keyStart,
      entry.keyEnd,
      jsonEncode(to.leaf),
    );
  }

  JsonNode? _nodeAt(KeyPath path) {
    JsonNode node = root;

    for (final segment in path.segments) {
      if (node is! JsonObjectNode) return null;

      final entry = node.entry(segment);
      if (entry == null) return null;

      node = entry.value;
    }

    return node;
  }

  JsonObjectNode? _objectAt(KeyPath? path) {
    if (path == null) return root;

    final node = _nodeAt(path);
    if (node is JsonObjectNode) return node;

    return null;
  }

  _ObjectSearchResult _nearestExistingObject(KeyPath path) {
    var node = root;
    var depth = 0;

    for (final segment in path.segments.take(path.segments.length - 1)) {
      final entry = node.entry(segment);
      if (entry == null) break;
      if (entry.value is! JsonObjectNode) {
        throw CliException('Parent is not an object: $segment');
      }

      node = entry.value as JsonObjectNode;
      depth += 1;
    }

    return _ObjectSearchResult(node: node, depth: depth);
  }

  Object? _nestedValue(List<String> segments, Object? value) {
    var result = value;

    for (final segment in segments.reversed) {
      result = {segment: result};
    }

    return result;
  }

  String _insertIntoObject(JsonObjectNode object, String key, Object? value) {
    final objectIndent = _indentTextForOffset(object.start);
    final childIndent = objectIndent + ' ' * indent;
    final childLevel = childIndent.length ~/ indent;
    final renderedEntry =
        '$childIndent${jsonEncode(key)}: ${_renderValue(value, childLevel)}';

    if (object.entries.isEmpty) {
      return _replaceRange(
        source,
        object.start,
        object.end,
        '{\n$renderedEntry\n$objectIndent}',
      );
    }

    final lastEntry = object.entries.last;
    final insertion = ',\n$renderedEntry';

    return _replaceRange(
      source,
      lastEntry.value.end,
      lastEntry.value.end,
      insertion,
    );
  }

  String _renderValue(Object? value, int level) {
    if (value is Map) {
      if (value.isEmpty) return '{}';

      final currentIndent = ' ' * (level * indent);
      final childIndent = ' ' * ((level + 1) * indent);
      final entries = value.entries
          .map((entry) {
            final rendered = _renderValue(entry.value, level + 1);

            return '$childIndent${jsonEncode(entry.key.toString())}: $rendered';
          })
          .join(',\n');

      return '{\n$entries\n$currentIndent}';
    }

    if (value is List) {
      if (value.isEmpty) return '[]';

      final currentIndent = ' ' * (level * indent);
      final childIndent = ' ' * ((level + 1) * indent);
      final entries = value
          .map((entry) {
            final rendered = _renderValue(entry, level + 1);

            return '$childIndent$rendered';
          })
          .join(',\n');

      return '[\n$entries\n$currentIndent]';
    }

    return jsonEncode(value);
  }

  int _indentLevelForOffset(int offset) {
    final indentText = _indentTextForOffset(offset);

    return indentText.length ~/ indent;
  }

  String _indentTextForOffset(int offset) {
    final lineStart = _lineStart(offset);
    var index = lineStart;

    while (index < source.length && source.codeUnitAt(index) == 0x20) {
      index += 1;
    }

    return source.substring(lineStart, index);
  }

  int _lineStart(int offset) {
    var index = offset;
    while (index > 0 && source.codeUnitAt(index - 1) != 0x0a) {
      index -= 1;
    }

    return index;
  }

  String _replaceRange(String text, int start, int end, String replacement) {
    var result = text.replaceRange(start, end, replacement);

    if (newlineAtEof && !result.endsWith('\n')) {
      result = '$result\n';
    }

    return result;
  }
}

final class _ObjectSearchResult {
  const _ObjectSearchResult({required this.node, required this.depth});

  final JsonObjectNode node;
  final int depth;
}

final class _JsonSourceParser {
  _JsonSourceParser(this.source);

  final String source;
  var _index = 0;

  JsonNode parse() {
    _skipWhitespace();
    final value = _parseValue();
    _skipWhitespace();

    if (_index != source.length) {
      _fail('Unexpected trailing content.');
    }

    return value;
  }

  JsonNode _parseValue() {
    _skipWhitespace();
    if (_index >= source.length) {
      _fail('Unexpected end of file.');
    }

    return switch (source.codeUnitAt(_index)) {
      0x7b => _parseObject(),
      0x5b => _parseArray(),
      0x22 => _parseString(),
      0x74 => _parseLiteral('true', true),
      0x66 => _parseLiteral('false', false),
      0x6e => _parseLiteral('null', null),
      _ => _parseNumber(),
    };
  }

  JsonObjectNode _parseObject() {
    final start = _index;
    _expect('{');
    _skipWhitespace();

    final entries = <JsonEntryNode>[];
    if (_tryConsume('}')) {
      return JsonObjectNode(start: start, end: _index, entries: entries);
    }

    while (true) {
      _skipWhitespace();
      final key = _parseString();
      _skipWhitespace();
      _expect(':');
      final value = _parseValue();

      entries.add(
        JsonEntryNode(
          key: key.value,
          keyStart: key.start,
          keyEnd: key.end,
          value: value,
        ),
      );

      _skipWhitespace();
      if (_tryConsume('}')) {
        return JsonObjectNode(start: start, end: _index, entries: entries);
      }

      _expect(',');
    }
  }

  JsonArrayNode _parseArray() {
    final start = _index;
    _expect('[');
    _skipWhitespace();

    final values = <JsonNode>[];
    if (_tryConsume(']')) {
      return JsonArrayNode(start: start, end: _index, values: values);
    }

    while (true) {
      values.add(_parseValue());
      _skipWhitespace();
      if (_tryConsume(']')) {
        return JsonArrayNode(start: start, end: _index, values: values);
      }

      _expect(',');
    }
  }

  JsonStringNode _parseString() {
    final start = _index;
    _expect('"');
    var escaping = false;

    while (_index < source.length) {
      final codeUnit = source.codeUnitAt(_index);
      _index += 1;

      if (escaping) {
        escaping = false;
        continue;
      }

      if (codeUnit == 0x5c) {
        escaping = true;
        continue;
      }

      if (codeUnit == 0x22) {
        final raw = source.substring(start, _index);
        final decoded = jsonDecode(raw);

        if (decoded is! String) {
          _fail('Expected a string.');
        }

        return JsonStringNode(start: start, end: _index, value: decoded);
      }
    }

    _fail('Unterminated string.');
  }

  JsonLiteralNode _parseLiteral(String literal, Object? value) {
    final start = _index;

    if (!source.startsWith(literal, _index)) {
      _fail('Expected $literal.');
    }

    _index += literal.length;

    return JsonLiteralNode(start: start, end: _index, value: value);
  }

  JsonLiteralNode _parseNumber() {
    final start = _index;

    while (_index < source.length) {
      final codeUnit = source.codeUnitAt(_index);
      final isNumberChar =
          (codeUnit >= 0x30 && codeUnit <= 0x39) ||
          codeUnit == 0x2d ||
          codeUnit == 0x2b ||
          codeUnit == 0x2e ||
          codeUnit == 0x65 ||
          codeUnit == 0x45;

      if (!isNumberChar) break;

      _index += 1;
    }

    if (start == _index) {
      _fail('Expected JSON value.');
    }

    final raw = source.substring(start, _index);
    final decoded = jsonDecode(raw);

    return JsonLiteralNode(start: start, end: _index, value: decoded);
  }

  void _skipWhitespace() {
    while (_index < source.length) {
      final codeUnit = source.codeUnitAt(_index);
      if (codeUnit != 0x20 &&
          codeUnit != 0x0a &&
          codeUnit != 0x0d &&
          codeUnit != 0x09) {
        return;
      }

      _index += 1;
    }
  }

  void _expect(String char) {
    if (!_tryConsume(char)) {
      _fail('Expected "$char".');
    }
  }

  bool _tryConsume(String char) {
    if (_index >= source.length) return false;
    if (source.codeUnitAt(_index) != char.codeUnitAt(0)) return false;

    _index += 1;

    return true;
  }

  Never _fail(String message) {
    final location = _locationFor(_index);

    throw FormatException('$message (${location.line}:${location.column})');
  }

  _SourceLocation _locationFor(int offset) {
    var line = 1;
    var column = 1;

    for (var i = 0; i < offset && i < source.length; i++) {
      if (source.codeUnitAt(i) == 0x0a) {
        line += 1;
        column = 1;
      } else {
        column += 1;
      }
    }

    return _SourceLocation(line: line, column: column);
  }
}

final class _SourceLocation {
  const _SourceLocation({required this.line, required this.column});

  final int line;
  final int column;
}
