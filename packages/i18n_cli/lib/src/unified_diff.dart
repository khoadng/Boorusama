final class FileDiff {
  const FileDiff({required this.file, required this.diff});

  final String file;
  final String diff;

  Map<String, Object?> toJson() => {
    'file': file,
    'diff': diff,
  };
}

String createUnifiedDiff({
  required String file,
  required String before,
  required String after,
  int context = 3,
}) {
  if (before == after) return '';

  final beforeLines = _splitLines(before);
  final afterLines = _splitLines(after);
  final edits = _diffLines(beforeLines, afterLines);
  final hunks = _buildHunks(edits, context);
  final buffer = StringBuffer()
    ..writeln('--- $file')
    ..writeln('+++ $file');

  for (final hunk in hunks) {
    buffer.writeln(
      '@@ -${hunk.oldStart},${hunk.oldCount} +'
      '${hunk.newStart},${hunk.newCount} @@',
    );

    for (final edit in hunk.edits) {
      buffer.writeln('${edit.kind.prefix}${edit.line}');
    }
  }

  return buffer.toString();
}

List<String> _splitLines(String source) {
  final lines = source.split('\n');
  if (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }

  return lines;
}

List<_LineEdit> _diffLines(List<String> before, List<String> after) {
  final table = List.generate(
    before.length + 1,
    (_) => List.filled(after.length + 1, 0),
  );

  for (var i = before.length - 1; i >= 0; i--) {
    for (var j = after.length - 1; j >= 0; j--) {
      if (before[i] == after[j]) {
        table[i][j] = table[i + 1][j + 1] + 1;
      } else {
        table[i][j] = table[i + 1][j] >= table[i][j + 1]
            ? table[i + 1][j]
            : table[i][j + 1];
      }
    }
  }

  final edits = <_LineEdit>[];
  var i = 0;
  var j = 0;

  while (i < before.length && j < after.length) {
    if (before[i] == after[j]) {
      edits.add(_LineEdit.context(before[i]));
      i += 1;
      j += 1;
    } else if (table[i + 1][j] >= table[i][j + 1]) {
      edits.add(_LineEdit.delete(before[i]));
      i += 1;
    } else {
      edits.add(_LineEdit.add(after[j]));
      j += 1;
    }
  }

  while (i < before.length) {
    edits.add(_LineEdit.delete(before[i]));
    i += 1;
  }

  while (j < after.length) {
    edits.add(_LineEdit.add(after[j]));
    j += 1;
  }

  return edits;
}

List<_Hunk> _buildHunks(List<_LineEdit> edits, int context) {
  final changedIndexes = <int>[];
  for (var i = 0; i < edits.length; i++) {
    if (edits[i].kind != _LineEditKind.context) {
      changedIndexes.add(i);
    }
  }

  if (changedIndexes.isEmpty) return const [];

  final ranges = <_IndexRange>[];
  for (final index in changedIndexes) {
    final start = (index - context).clamp(0, edits.length - 1);
    final end = (index + context).clamp(0, edits.length - 1);

    if (ranges.isNotEmpty && start <= ranges.last.end + 1) {
      ranges[ranges.length - 1] = _IndexRange(
        start: ranges.last.start,
        end: end,
      );
    } else {
      ranges.add(_IndexRange(start: start, end: end));
    }
  }

  final hunks = <_Hunk>[];
  var oldLine = 1;
  var newLine = 1;
  var rangeIndex = 0;

  for (var i = 0; i < edits.length; i++) {
    while (rangeIndex < ranges.length && i > ranges[rangeIndex].end) {
      rangeIndex += 1;
    }

    final inRange =
        rangeIndex < ranges.length &&
        i >= ranges[rangeIndex].start &&
        i <= ranges[rangeIndex].end;

    if (inRange && (i == ranges[rangeIndex].start)) {
      final hunkEdits = edits.sublist(
        ranges[rangeIndex].start,
        ranges[rangeIndex].end + 1,
      );
      hunks.add(
        _Hunk(
          oldStart: oldLine,
          oldCount: hunkEdits
              .where((edit) => edit.kind != _LineEditKind.add)
              .length,
          newStart: newLine,
          newCount: hunkEdits
              .where((edit) => edit.kind != _LineEditKind.delete)
              .length,
          edits: hunkEdits,
        ),
      );
    }

    switch (edits[i].kind) {
      case _LineEditKind.context:
        oldLine += 1;
        newLine += 1;
      case _LineEditKind.add:
        newLine += 1;
      case _LineEditKind.delete:
        oldLine += 1;
    }
  }

  return hunks;
}

final class _LineEdit {
  const _LineEdit._(this.kind, this.line);

  factory _LineEdit.context(String line) =>
      _LineEdit._(_LineEditKind.context, line);

  factory _LineEdit.add(String line) => _LineEdit._(_LineEditKind.add, line);

  factory _LineEdit.delete(String line) =>
      _LineEdit._(_LineEditKind.delete, line);

  final _LineEditKind kind;
  final String line;
}

enum _LineEditKind {
  context(' '),
  add('+'),
  delete('-')
  ;

  const _LineEditKind(this.prefix);

  final String prefix;
}

final class _Hunk {
  const _Hunk({
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.edits,
  });

  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final List<_LineEdit> edits;
}

final class _IndexRange {
  const _IndexRange({required this.start, required this.end});

  final int start;
  final int end;
}
