// Dart imports:
import 'dart:io';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/blacklists/src/data/hive/factory.dart';
import 'package:boorusama/core/bookmarks/src/data/hive/factory.dart';
import 'package:boorusama/core/bookmarks/types.dart';
import 'package:boorusama/core/bulk_downloads/src/data/repo_io.dart';
import 'package:boorusama/core/cache/hive_misc_data_store.dart';
import 'package:boorusama/core/cache/hive_persistent_cache_store.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/hive/hive_adapters.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/search/histories/src/data/repo_io.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/tags/favorites/src/data/favorite_tag_repository_factory_hive.dart';
import 'package:boorusama/core/tags/local/src/data/repo_io.dart';
import 'package:boorusama/foundation/filesystem.dart';

void main() {
  late Directory root;

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('boorusama-adapters-');
    Hive.init(root.path);
    Hive.registerAdapter(FavoriteTagHiveObjectAdapter());
    Hive.registerAdapter(BlacklistedTagHiveObjectAdapter());
    Hive.registerAdapter(BookmarkHiveObjectAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
    await root.delete(recursive: true);
  });

  test(
    'Hive misc and persistent cache stores support basic lifecycle',
    () async {
      final miscBox = await Hive.openBox<String>('misc_adapter_test');
      final misc = HiveMiscDataStore(miscBox);
      expect(misc.get('missing'), isNull);
      await misc.put('theme', 'dark');
      expect(misc.get('theme'), 'dark');
      await misc.put('theme', 'light');
      expect(misc.get('theme'), 'light');
      await miscBox.close();

      final cacheBox = await Hive.openBox<String>('cache_adapter_test');
      final cache = HivePersistentCacheStore(cacheBox);
      expect(cache.length, 0);
      await cache.put('one', '1');
      await cache.put('two', '2');
      expect(cache.keys, containsAll(<String>['one', 'two']));
      expect(cache.get('one'), '1');
      expect(cache.get('missing'), isNull);
      await cache.clear();
      expect(cache.length, 0);
      await cacheBox.close();
    },
  );

  test('Hive repository factories preserve values across disposal', () async {
    const favoriteFactory = HiveFavoriteTagRepositoryFactory(
      boxName: 'favorite_factory_test',
    );
    final favorites = await favoriteFactory.create();
    await favorites.create(name: 'cat', labels: const ['pets']);
    await favoriteFactory.dispose(favorites);
    final reopenedFavorites = await favoriteFactory.create();
    expect(await reopenedFavorites.getFirst('cat'), isNotNull);
    await favoriteFactory.dispose(reopenedFavorites);

    final blacklistFactory = HiveGlobalBlacklistedTagRepositoryFactory(
      path: root.path,
    );
    final blacklist = await blacklistFactory.create();
    final added = await blacklist.addTag('spoiler');
    expect(added?.name, 'spoiler');
    await blacklistFactory.dispose(blacklist);
    final reopenedBlacklist = await blacklistFactory.create();
    expect(
      (await reopenedBlacklist.getBlacklist()).map((tag) => tag.name),
      contains('spoiler'),
    );
    await blacklistFactory.dispose(reopenedBlacklist);

    const bookmarkFactory = HiveBookmarkRepositoryFactory(
      boxName: 'bookmark_factory_test',
    );
    final bookmarks = await bookmarkFactory.create();
    await bookmarks.addBookmarkWithBookmarks([_bookmark()]);
    await bookmarkFactory.dispose(bookmarks);
    final reopenedBookmarks = await bookmarkFactory.create();
    final values = await reopenedBookmarks.getAllBookmarksOrEmpty(
      imageUrlResolver: (_) => const DefaultImageUrlResolver(),
    );
    expect(values.single.tags, contains('cat'));
    expect(values.single.postId, 101);
    await bookmarkFactory.dispose(reopenedBookmarks);
  });

  test(
    'SQLite search history factory creates and reopens its repository',
    () async {
      final factory = SqliteSearchHistoryRepositoryFactory(
        fileSystem: _TestFileSystem(root.path),
        logger: AppLogger(),
      );

      final repository = await factory.create();
      await repository.addHistory(
        'cat',
        queryType: QueryType.simple,
        booruTypeName: 'test',
        siteUrl: 'https://example.test',
      );
      expect((await repository.getHistories()).single.query, 'cat');
      await factory.dispose(repository);

      final reopened = await factory.create();
      expect((await reopened.getHistories()).single.searchCount, 1);
      await factory.dispose(reopened);
    },
  );

  test('SQLite feature factories create and dispose repositories', () async {
    final fileSystem = _TestFileSystem(root.path);
    final logger = AppLogger();

    final tagFactory = SqliteTagCacheRepositoryFactory(
      fileSystem: fileSystem,
      logger: logger,
    );
    final tags = await tagFactory.create();
    await tags.saveTag(
      siteHost: 'example.test',
      tagName: 'cat',
      category: 'general',
    );
    expect(await tags.getTagCategory('example.test', 'cat'), 'general');
    await tagFactory.dispose(tags);

    final downloadFactory = SqliteDownloadRepositoryFactory(
      fileSystem: fileSystem,
      logger: logger,
    );
    final downloads = await downloadFactory.create();
    expect(await downloads.getTasks(), isEmpty);
    await downloadFactory.dispose(downloads);
  });
}

Bookmark _bookmark() => Bookmark(
  id: 1,
  booruId: 1,
  createdAt: DateTime.utc(2020),
  updatedAt: DateTime.utc(2020),
  thumbnailUrl: 'https://example.test/thumb.jpg',
  sampleUrl: 'https://example.test/sample.jpg',
  originalUrl: 'https://example.test/original.jpg',
  sourceUrl: 'https://example.test/posts/101',
  width: 100,
  height: 100,
  md5: 'hash',
  tags: const {'cat'},
  realSourceUrl: 'https://example.test/source',
  format: '.jpg',
  imageUrlResolver: const DefaultImageUrlResolver(),
  postId: 101,
  metadata: const {},
  sitePostId: '101',
);

final class _TestFileSystem extends IoFileSystem {
  _TestFileSystem(this.path);

  final String path;

  @override
  Future<String> getAppStoragePath() async => path;
}
