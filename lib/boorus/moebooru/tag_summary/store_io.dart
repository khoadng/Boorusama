// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../foundation/path.dart';
import 'types.dart';

final tagSummaryStoreProvider =
    Provider.family<TagSummaryStore, BooruConfigAuth>((ref, config) {
      final path = '${Uri.encodeComponent(config.url)}_tag_summary';
      return FileTagSummaryStore(path);
    });

class FileTagSummaryStore implements TagSummaryStore {
  FileTagSummaryStore(this.path);

  final String path;
  TagSummaryDto? _cache;

  @override
  Future<TagSummaryDto?> get() async {
    if (_cache != null) return _cache;

    try {
      final directory = await getAppTemporaryDirectory();
      final file = File('${directory.path}/$path');

      if (file.existsSync()) {
        final lastModified = file.lastModifiedSync();
        final now = DateTime.now();
        if (now.difference(lastModified).inDays < 1) {
          final content = await file.readAsString();
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
      final directory = await getAppTemporaryDirectory();
      final file = File('${directory.path}/$path');
      await file.writeAsString(json.encode(dto.toJson()));
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
      final directory = await getAppTemporaryDirectory();
      final file = File('${directory.path}/$path');
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when clearing
    }
  }
}
