// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/foundation/path.dart';

class TagSummaryRepositoryFile {
  TagSummaryRepositoryFile(this.path);

  final String path;
  TagSummaryDto? _cache;

  Future<TagSummaryDto?> getTagSummaries() async {
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

      // No file, or file is expired
      _cache = null;
      return null;
    } catch (e) {
      _cache = null;
      return null;
    }
  }

  Future<void> saveTagSummaries(TagSummaryDto tagSummaryDto) async {
    try {
      final directory = await getAppTemporaryDirectory();
      final file = File('${directory.path}/$path');
      await file.writeAsString(json.encode(tagSummaryDto.toJson()));
      _cache = null;
    } catch (e) {
      _cache = null;
      throw Exception('Error writing to file: $e');
    }
  }
}
