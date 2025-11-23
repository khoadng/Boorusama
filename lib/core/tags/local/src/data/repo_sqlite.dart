// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_sqlite3_migration/flutter_sqlite3_migration.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../../../../../foundation/database/utils.dart';
import '../types/cached_tag.dart';
import '../types/tag_alias.dart';
import '../types/tag_cache_repository.dart';
import '../types/tag_info.dart';

const _kTagRepositoryVersion = 0;
const kTagsTable = 'tags';
const kTagAliasesTable = 'tag_aliases';

// Tags table columns
const _kTagsIdColumn = 'id';
const _kTagsSiteHostColumn = 'site_host';
const _kTagsTagNameColumn = 'tag_name';
const _kTagsCategoryColumn = 'category';
const _kTagsPostCountColumn = 'post_count';
const _kTagsMetadataColumn = 'metadata';
const _kTagsCreatedAtColumn = 'created_at';
const _kTagsUpdatedAtColumn = 'updated_at';
const _kTagsVersionColumn = 'version';

// Tag aliases table columns
const _kAliasesIdColumn = 'id';
const _kAliasesSourceSiteColumn = 'source_site';
const _kAliasesSourceTagColumn = 'source_tag';
const _kAliasesTargetSiteColumn = 'target_site';
const _kAliasesTargetTagColumn = 'target_tag';
const _kAliasesCreatedAtColumn = 'created_at';

class TagCacheRepositorySqlite
    with DatabaseUtilsMixin
    implements TagCacheRepository {
  TagCacheRepositorySqlite({required this.db});

  @override
  final Database db;
  var _disposed = false;

  void initialize() {
    db.execute('PRAGMA foreign_keys = ON');

    _createTablesIfNotExists();
    DbMigrationManager.create(
      db: db,
      targetVersion: _kTagRepositoryVersion,
      migrations: [],
    ).runMigrations();
  }

  void _createTablesIfNotExists() {
    db
      ..execute('''
        CREATE TABLE IF NOT EXISTS $kTagsTable (
          $_kTagsIdColumn INTEGER PRIMARY KEY,
          $_kTagsSiteHostColumn TEXT NOT NULL,
          $_kTagsTagNameColumn TEXT NOT NULL,
          $_kTagsCategoryColumn TEXT NOT NULL,
          $_kTagsPostCountColumn INTEGER,
          $_kTagsMetadataColumn TEXT,
          $_kTagsCreatedAtColumn INTEGER NOT NULL,
          $_kTagsUpdatedAtColumn INTEGER NOT NULL,
          $_kTagsVersionColumn INTEGER DEFAULT 1,
          UNIQUE($_kTagsSiteHostColumn, $_kTagsTagNameColumn)
        );
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_site_category 
        ON $kTagsTable ($_kTagsSiteHostColumn, $_kTagsCategoryColumn);
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_updated 
        ON $kTagsTable ($_kTagsUpdatedAtColumn);
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_tags_site_name_search 
        ON $kTagsTable ($_kTagsSiteHostColumn, $_kTagsTagNameColumn COLLATE NOCASE);
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS $kTagAliasesTable (
          $_kAliasesIdColumn INTEGER PRIMARY KEY,
          $_kAliasesSourceSiteColumn TEXT NOT NULL,
          $_kAliasesSourceTagColumn TEXT NOT NULL,
          $_kAliasesTargetSiteColumn TEXT NOT NULL,
          $_kAliasesTargetTagColumn TEXT NOT NULL,
          $_kAliasesCreatedAtColumn INTEGER NOT NULL,
          UNIQUE($_kAliasesSourceSiteColumn, $_kAliasesSourceTagColumn, $_kAliasesTargetSiteColumn)
        );
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_aliases_source 
        ON $kTagAliasesTable ($_kAliasesSourceSiteColumn, $_kAliasesSourceTagColumn);
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_aliases_target 
        ON $kTagAliasesTable ($_kAliasesTargetSiteColumn, $_kAliasesTargetTagColumn);
      ''');
  }

  @override
  Future<void> saveTag({
    required String siteHost,
    required String tagName,
    required String category,
    int? postCount,
    Map<String, dynamic>? metadata,
  }) async {
    if (siteHost.isEmpty || tagName.isEmpty || category.isEmpty) {
      throw ArgumentError('Required fields cannot be empty');
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final metadataJson = metadata != null ? jsonEncode(metadata) : null;

    transaction(() {
      db.execute(
        '''
        INSERT INTO $kTagsTable ($_kTagsSiteHostColumn, $_kTagsTagNameColumn, $_kTagsCategoryColumn, $_kTagsPostCountColumn, $_kTagsMetadataColumn, $_kTagsCreatedAtColumn, $_kTagsUpdatedAtColumn)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT($_kTagsSiteHostColumn, $_kTagsTagNameColumn) DO UPDATE SET
          $_kTagsCategoryColumn = ?,
          $_kTagsPostCountColumn = ?,
          $_kTagsMetadataColumn = ?,
          $_kTagsUpdatedAtColumn = ?
        ''',
        [
          siteHost,
          tagName,
          category,
          postCount,
          metadataJson,
          now,
          now,
          category,
          postCount,
          metadataJson,
          now,
        ],
      );
    });
  }

  @override
  Future<String?> getTagCategory(String siteHost, String tagName) async {
    final result = db.select(
      'SELECT $_kTagsCategoryColumn FROM $kTagsTable WHERE $_kTagsSiteHostColumn = ? AND $_kTagsTagNameColumn = ? COLLATE NOCASE',
      [siteHost, tagName],
    );

    if (result.isEmpty) return null;

    return result.first[_kTagsCategoryColumn] as String;
  }

  @override
  Future<void> saveTagAlias({
    required String sourceSite,
    required String sourceTag,
    required String targetSite,
    required String targetTag,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    transaction(() {
      db.execute(
        '''
        INSERT INTO $kTagAliasesTable ($_kAliasesSourceSiteColumn, $_kAliasesSourceTagColumn, $_kAliasesTargetSiteColumn, $_kAliasesTargetTagColumn, $_kAliasesCreatedAtColumn)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT($_kAliasesSourceSiteColumn, $_kAliasesSourceTagColumn, $_kAliasesTargetSiteColumn) DO UPDATE SET
          $_kAliasesTargetTagColumn = ?,
          $_kAliasesCreatedAtColumn = ?
        ''',
        [sourceSite, sourceTag, targetSite, targetTag, now, targetTag, now],
      );
    });
  }

  @override
  Future<TagAlias?> getTagAlias(
    String sourceSite,
    String sourceTag,
    String targetSite,
  ) async {
    final result = db.select(
      '''
      SELECT $_kAliasesSourceSiteColumn, $_kAliasesSourceTagColumn, $_kAliasesTargetSiteColumn, $_kAliasesTargetTagColumn, $_kAliasesCreatedAtColumn 
      FROM $kTagAliasesTable 
      WHERE $_kAliasesSourceSiteColumn = ? AND $_kAliasesSourceTagColumn = ? COLLATE NOCASE AND $_kAliasesTargetSiteColumn = ?
      ''',
      [sourceSite, sourceTag, targetSite],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return TagAlias(
      sourceSite: row[_kAliasesSourceSiteColumn] as String,
      sourceTag: row[_kAliasesSourceTagColumn] as String,
      targetSite: row[_kAliasesTargetSiteColumn] as String,
      targetTag: row[_kAliasesTargetTagColumn] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row[_kAliasesCreatedAtColumn] as int,
      ),
    );
  }

  @override
  Future<void> clearTags() async {
    transaction(() {
      db.execute('DELETE FROM $kTagsTable');
    });
  }

  @override
  Future<void> clearAliases() async {
    transaction(() {
      db.execute('DELETE FROM $kTagAliasesTable');
    });
  }

  @override
  Future<void> saveTagsBatch(List<TagInfo> tagInfos) async {
    if (tagInfos.isEmpty) return;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    transaction(() {
      final stmt = db.prepare('''
        INSERT INTO $kTagsTable ($_kTagsSiteHostColumn, $_kTagsTagNameColumn, $_kTagsCategoryColumn, $_kTagsPostCountColumn, $_kTagsMetadataColumn, $_kTagsCreatedAtColumn, $_kTagsUpdatedAtColumn)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT($_kTagsSiteHostColumn, $_kTagsTagNameColumn) DO UPDATE SET
          $_kTagsCategoryColumn = ?,
          $_kTagsPostCountColumn = ?,
          $_kTagsMetadataColumn = ?,
          $_kTagsUpdatedAtColumn = ?
      ''');

      try {
        for (final tagInfo in tagInfos) {
          if (tagInfo.siteHost.isEmpty ||
              tagInfo.tagName.isEmpty ||
              tagInfo.category.isEmpty) {
            continue; // Skip invalid entries
          }

          final metadataJson = tagInfo.metadata != null
              ? jsonEncode(tagInfo.metadata)
              : null;

          stmt.execute([
            tagInfo.siteHost,
            tagInfo.tagName,
            tagInfo.category,
            tagInfo.postCount,
            metadataJson,
            now,
            now,
            tagInfo.category,
            tagInfo.postCount,
            metadataJson,
            now,
          ]);
        }
      } finally {
        stmt.dispose();
      }
    });
  }

  @override
  Future<TagResolutionResult> resolveTags(
    String siteHost,
    List<String> tagNames,
  ) async {
    if (tagNames.isEmpty) {
      return const TagResolutionResult(found: [], missing: []);
    }

    final normalizedTagNames = tagNames
        .map((tag) => tag.toLowerCase().replaceAll(' ', '_'))
        .toList();
    final tagNameSet = normalizedTagNames.toSet();

    final placeholders = List.filled(tagNameSet.length, '?').join(', ');

    final result = db.select(
      '''
    SELECT $_kTagsSiteHostColumn, $_kTagsTagNameColumn, $_kTagsCategoryColumn, 
           $_kTagsPostCountColumn, $_kTagsMetadataColumn, $_kTagsUpdatedAtColumn 
    FROM $kTagsTable 
    WHERE $_kTagsSiteHostColumn = ? AND $_kTagsTagNameColumn IN ($placeholders) COLLATE NOCASE
    ''',
      [siteHost, ...tagNameSet],
    );

    final foundTags = <CachedTag>[];
    final foundTagNames = <String>{};

    for (final row in result) {
      final tagName = row[_kTagsTagNameColumn] as String;
      final category = row[_kTagsCategoryColumn] as String;
      final postCount = row[_kTagsPostCountColumn] as int?;
      final metadataJson = row[_kTagsMetadataColumn] as String?;
      final updatedAtMs = row[_kTagsUpdatedAtColumn] as int;

      Map<String, dynamic>? metadata;
      if (metadataJson != null) {
        try {
          metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
        } catch (e) {
          metadata = null;
        }
      }

      foundTags.add(
        CachedTag(
          siteHost: siteHost,
          tagName: tagName,
          category: category,
          postCount: postCount,
          metadata: metadata,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
        ),
      );

      foundTagNames.add(tagName);
    }

    final missingTags = tagNameSet
        .where((tag) => !foundTagNames.contains(tag))
        .toList();

    return TagResolutionResult(
      found: foundTags,
      missing: missingTags,
    );
  }

  @override
  Future<void> dispose() async {
    if (!_disposed) {
      db.dispose();
      _disposed = true;
    }
  }
}
