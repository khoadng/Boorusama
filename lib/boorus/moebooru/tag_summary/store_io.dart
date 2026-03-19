// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../foundation/filesystem.dart';
import 'types.dart';

final tagSummaryStoreProvider =
    Provider.family<TagSummaryStore, BooruConfigAuth>((ref, config) {
      final path = '${Uri.encodeComponent(config.url)}_tag_summary';
      return FileTagSummaryStore(
        path,
        ref.watch(appFileSystemProvider),
      );
    });

class FileTagSummaryStore implements TagSummaryStore {
  FileTagSummaryStore(this.path, this._fs);

  final String path;
  final AppFileSystem _fs;
  TagSummaryDto? _cache;

  @override
  Future<TagSummaryDto?> get() async {
    if (_cache != null) return _cache;

    try {
      final tempPath = await _fs.getTemporaryPath();

      if (tempPath == null) {
        _cache = null;
        return null;
      }

      final filePath = '$tempPath/$path';

      if (_fs.fileExistsSync(filePath)) {
        final lastModified = _fs.lastModifiedSync(filePath);
        final now = DateTime.now();
        if (now.difference(lastModified).inDays < 1) {
          final content = await _fs.readString(filePath);
          final dto = TagSummaryDto.fromJson(json.decode(content));
          _cache = dto;
          return dto;
        }
      }

      _cache = null;
      return null;
    } catch (e) {
      _cache = null;
      return null;
    }
  }

  @override
  Future<void> save(TagSummaryDto dto) async {
    try {
      final tempPath = await _fs.getTemporaryPath();

      if (tempPath == null) {
        _cache = null;
        return;
      }

      final filePath = '$tempPath/$path';
      await _fs.writeString(filePath, json.encode(dto.toJson()));
      _cache = null;
    } catch (e) {
      _cache = null;
      throw Exception('Error writing to file: $e');
    }
  }

  @override
  Future<void> clear() async {
    _cache = null;
    try {
      final tempPath = await _fs.getTemporaryPath();

      if (tempPath == null) {
        return;
      }

      final filePath = '$tempPath/$path';
      if (_fs.fileExistsSync(filePath)) {
        await _fs.deleteFile(filePath);
      }
    } catch (e) {
      // Ignore errors when clearing
    }
  }
}
