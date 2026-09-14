// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../types/sidecar_result.dart';
import '../types/sidecar_snapshot.dart';
import 'sidecar_writer.dart';

/// Durable intent, separate from the transfer queue. Waiting records never
/// infer transfer completion just because a file exists at the destination.
class SidecarStore {
  const SidecarStore({required this.directory, required this.fs});

  final String directory;
  final AppFileSystem fs;

  SidecarWriter get writer => SidecarWriter(fs: fs);

  String get _readyDirectory => p.join(directory, 'ready');

  String _file(String id) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
      throw const FormatException('Invalid sidecar identifier');
    }
    return p.join(directory, '$id.json');
  }

  String _readyFile(String id) =>
      p.join(_readyDirectory, p.basename(_file(id)));

  Future<Map<String, dynamic>?> _read(String path) async =>
      switch (await fs.readStringIfExists(path)) {
        null => null,
        final content => jsonDecode(content) as Map<String, dynamic>,
      };

  Future<void> _save(String id, Map<String, dynamic> record) async {
    final destination = record['state'] == 'waiting'
        ? _file(id)
        : _readyFile(id);
    await fs.createDirectory(p.dirname(destination), recursive: true);
    final temporary = '$destination.${const Uuid().v4()}.tmp';
    try {
      await fs.writeString(temporary, jsonEncode(record), flush: true);
      await fs.renameFile(temporary, destination);
    } finally {
      await fs.deleteFileIfExists(temporary);
    }
  }

  Future<void> prepare(String id, String path, SidecarSnapshot snapshot) async {
    await writer.checkDestination(path, snapshot);
    await _save(id, {
      'path': path,
      'snapshot': snapshot.toJson(),
      'state': 'waiting',
    });
  }

  Future<void> discard(String id) async {
    await fs.deleteFileIfExists(_file(id));
    await fs.deleteFileIfExists(_readyFile(id));
  }

  Future<void> complete(String id, String path) async {
    final record = await _read(_file(id)) ?? await _read(_readyFile(id));
    if (record == null) return; // A repeated completion after finalization.
    record['path'] = path;
    record['state'] = 'ready';
    await _save(id, record);
    await fs.deleteFileIfExists(_file(id));
    await retry(id);
  }

  Future<void> retry(String id) async {
    final record = await _read(_readyFile(id));
    if (record == null) {
      if (await _read(_file(id)) != null) {
        throw StateError('Transfer completion has not been confirmed');
      }
      return;
    }
    try {
      await writer.write(
        record['path'] as String,
        SidecarSnapshot.fromJson(record['snapshot'] as Map<String, dynamic>),
      );
      await discard(id);
    } catch (error) {
      record['state'] = 'failed';
      record['error'] = error.toString();
      await _save(id, record);
      rethrow;
    }
  }

  Future<List<SidecarFailure>> failures() async {
    // Only confirmed transfers can have metadata failures.
    if (!await fs.directoryExists(_readyDirectory)) return [];
    final failures = <SidecarFailure>[];
    await for (final entry in fs.listDirectoryStream(_readyDirectory)) {
      if (!entry.isFile || !entry.path.endsWith('.json')) continue;
      final record = await _read(entry.path);
      if (record == null || record['state'] == 'waiting') continue;
      failures.add(
        SidecarFailure(
          id: p.basenameWithoutExtension(entry.path),
          path: record['path'] as String,
          error:
              record['error'] as String? ?? 'Metadata finalization interrupted',
        ),
      );
    }
    return failures;
  }

  Future<void> recover() async {
    for (final failure in await failures()) {
      try {
        await retry(failure.id);
      } catch (_) {
        // retry persisted the failure for a later recovery attempt.
      }
    }
  }
}
