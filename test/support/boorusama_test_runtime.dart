// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:foundation/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/blacklists/types.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/cache/misc_data_store.dart';
import 'package:boorusama/core/cache/persistent_cache_store.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/config/src/data/booru_config_converter.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/developer_options/src/developer_options_repository.dart';
import 'package:boorusama/core/developer_options/types.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository.dart';
import 'package:boorusama/core/search/histories/src/types/search_history.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/settings/src/types/settings_repository.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/tags/configs/src/tag_info.dart';
import 'package:boorusama/core/tags/favorites/src/types/favorite_tag.dart';
import 'package:boorusama/foundation/applock/src/device_authenticator.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/iap/iap.dart';
import 'package:boorusama/foundation/info/app_info.dart';
import 'package:boorusama/foundation/info/device_info.dart';
import 'package:boorusama/foundation/networking/connectivity_service.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/window.dart';

/// Creates a complete runtime whose infrastructure is deterministic and
/// memory-backed. The defaults are suitable for widget tests; individual
/// boundaries can be replaced when a test needs to exercise another case.
BoorusamaRuntime createTestBoorusamaRuntime({
  AppPlatform platform = AppPlatform.unknown,
  ConnectivityService? connectivityService,
  DeviceAuthenticator? deviceAuthenticator,
  AppFileSystem? fileSystem,
  BoorusamaInitialState? initialState,
  BooruDb? booruDb,
  BooruRegistry? booruRegistry,
  GlobalBlacklistedTagRepository? globalBlacklistedTagRepository,
  DownloadService? downloadService,
  Map<String, String> Function(BooruConfigAuth config)? httpHeadersBuilder,
  FavoriteTagRepository? favoriteTagRepository,
  SearchHistoryRepository? searchHistoryRepository,
  SettingsRepository? settingsRepository,
  BooruConfigRepository? booruConfigRepository,
}) {
  final appLogger = AppLogger();
  final state =
      initialState ??
      const BoorusamaInitialState(
        initialConfig: BooruConfig.empty,
        configs: [],
        settings: Settings.defaultSettings,
        developerOptions: DeveloperOptions.defaults,
        logOptions: LogOptions.defaults,
      );

  return BoorusamaRuntime(
    initialState: state,
    dependencies: BoorusamaRuntimeDependencies(
      fileSystem: fileSystem ?? MemoryAppFileSystem(),
      booruDb: booruDb ?? const BooruDb(boorus: {}),
      booruRegistry: booruRegistry ?? BooruRegistry(),
      globalBlacklistedTagRepository:
          globalBlacklistedTagRepository ??
          MemoryGlobalBlacklistedTagRepository(),
      downloadService: downloadService ?? MemoryDownloadService(),
      httpHeadersBuilder: httpHeadersBuilder ?? (_) => const {},
      favoriteTagRepository:
          favoriteTagRepository ?? MemoryFavoriteTagRepository(),
      searchHistoryRepository:
          searchHistoryRepository ?? MemorySearchHistoryRepository(),
      settingsRepository:
          settingsRepository ?? MemorySettingsRepository(state.settings),
      developerOptionsRepository: MemoryDeveloperOptionsRepository(),
      booruConfigRepository:
          booruConfigRepository ?? MemoryBooruConfigRepository(),
      packageInfo: PackageInfo(
        appName: 'Boorusama Test',
        packageName: 'com.example.boorusama.test',
        version: '0.0.0',
        buildNumber: '0',
      ),
      deviceInfo: DeviceInfo.empty(),
      appInfo: AppInfo.empty,
      tagInfo: const TagInfo(
        metatags: {},
        defaultBlacklistedTags: {},
        r18Tags: {},
      ),
      appLogger: appLogger,
      logger: appLogger,
      logOptionsRepository: MemoryLogOptionsRepository(),
      miscDataStore: MemoryMiscDataStore(),
      persistentCacheStore: MemoryPersistentCacheStore(
        suppressChangelog: true,
      ),
      iapFactory: initDummyIap,
      platform: platform,
      connectivityService:
          connectivityService ?? const TestConnectivityService(),
      deviceAuthenticator:
          deviceAuthenticator ?? const TestDeviceAuthenticator(),
      windowService: const TestWindowService(),
      isFossBuild: true,
      isCronetAvailable: false,
    ),
  );
}

final class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository([this._settings = Settings.defaultSettings]);

  Settings _settings;
  final savedSettings = <Settings>[];

  @override
  Future<bool> save(Settings setting) async {
    _settings = setting;
    savedSettings.add(setting);
    return true;
  }

  @override
  SettingsOrError load() => TaskEither.right(_settings);
}

final class MemoryGlobalBlacklistedTagRepository
    implements GlobalBlacklistedTagRepository {
  final _tags = <BlacklistedTag>[];

  @override
  Future<BlacklistedTag?> addTag(String tag) async => null;

  @override
  Future<List<BlacklistedTag>> addTags(List<BlacklistedTag> tags) async =>
      _tags..addAll(tags);

  @override
  Future<List<BlacklistedTag>> getBlacklist() async => List.unmodifiable(_tags);

  @override
  Future<void> removeTag(int tagId) async {
    _tags.removeWhere((tag) => tag.id == tagId);
  }

  @override
  Future<BlacklistedTag> updateTag(int tagId, String newTag) async {
    final index = _tags.indexWhere((tag) => tag.id == tagId);
    if (index == -1) {
      throw StateError('Blacklist tag not found: $tagId');
    }

    final updated = _tags[index].copyWith(
      name: newTag,
      updatedDate: DateTime.now(),
    );
    _tags[index] = updated;
    return updated;
  }
}

final class MemoryFavoriteTagRepository implements FavoriteTagRepository {
  final _tags = <FavoriteTag>[];

  @override
  Future<List<FavoriteTag>> get(String name) async =>
      _tags.where((tag) => tag.name == name).toList();

  @override
  Future<List<FavoriteTag>> getAll() async => List.of(_tags);

  @override
  Future<FavoriteTag?> getFirst(String name) async =>
      _tags.cast<FavoriteTag?>().firstWhere(
        (tag) => tag?.name == name,
        orElse: () => null,
      );

  @override
  Future<FavoriteTag?> deleteFirst(String name) async {
    final index = _tags.indexWhere((tag) => tag.name == name);
    if (index == -1) return null;

    return _tags.removeAt(index);
  }

  @override
  Future<FavoriteTag> create({
    required String name,
    List<String>? labels,
    QueryType? queryType,
  }) async {
    final now = DateTime.now();
    final tag = FavoriteTag(
      name: name,
      createdAt: now,
      updatedAt: now,
      labels: labels,
      queryType: queryType,
    );
    _tags.add(tag);
    return tag;
  }

  @override
  Future<FavoriteTag?> restore(FavoriteTag tag) async {
    if (_tags.any((item) => item.name == tag.name)) return null;

    _tags.add(tag);
    return tag;
  }

  @override
  Future<List<FavoriteTag>> createFrom(List<FavoriteTag> tags) async {
    _tags.addAll(tags);
    return List.unmodifiable(tags);
  }

  @override
  Future<FavoriteTag?> updateFirst(String name, FavoriteTag tag) async {
    final index = _tags.indexWhere((item) => item.name == name);
    if (index == -1) return null;

    _tags[index] = tag;
    return tag;
  }
}

final class MemorySearchHistoryRepository implements SearchHistoryRepository {
  final _histories = <SearchHistory>[];

  @override
  Future<List<SearchHistory>> getHistories() async =>
      List.unmodifiable(_histories);

  @override
  Future<List<SearchHistory>> addHistory(
    String query, {
    required QueryType queryType,
    required String booruTypeName,
    required String siteUrl,
  }) async {
    final history = SearchHistory.now(
      query,
      queryType,
      booruTypeName: booruTypeName,
      siteUrl: siteUrl,
    );
    _histories
      ..removeWhere((item) => item.query == query)
      ..insert(0, history);
    return List.unmodifiable(_histories);
  }

  @override
  Future<List<SearchHistory>> removeHistory(SearchHistory history) async {
    _histories.remove(history);
    return List.unmodifiable(_histories);
  }

  @override
  Future<bool> clearAll() async {
    _histories.clear();
    return true;
  }
}

final class MemoryDownloadService implements DownloadService {
  final requests = <DownloadOptions>[];

  @override
  Future<DownloadResult> download(DownloadOptions options) async {
    requests.add(options);
    return DownloadEnqueued(
      DownloadTaskInfo(
        path: options.path ?? '',
        id: options.filename,
      ),
    );
  }

  @override
  Future<bool> cancelAll(String group) async => false;

  @override
  Future<void> pauseAll(String group) async {}

  @override
  Future<void> resumeAll(String group) async {}
}

final class MemoryDeveloperOptionsRepository
    implements DeveloperOptionsRepository {
  MemoryDeveloperOptionsRepository([
    this._options = DeveloperOptions.defaults,
  ]);

  DeveloperOptions _options;

  @override
  Future<DeveloperOptions> load() async => _options;

  @override
  Future<void> save(DeveloperOptions options) async {
    _options = options;
  }
}

final class MemoryBooruConfigRepository implements BooruConfigRepository {
  final _configs = <BooruConfig>[];

  @override
  Future<BooruConfig?> add(BooruConfigData data) async {
    final config = data.toBooruConfig(id: _configs.length + 1);
    if (config != null) _configs.add(config);
    return config;
  }

  @override
  Future<List<BooruConfig>> addAll(List<BooruConfig> configs) async {
    final added = <BooruConfig>[];
    for (final config in configs) {
      final data = config.toBooruConfigData();
      final result = await add(data);
      if (result != null) added.add(result);
    }
    return added;
  }

  @override
  Future<void> clear() async => _configs.clear();

  @override
  Future<List<BooruConfig>> getAll() async => List.unmodifiable(_configs);

  @override
  Future<void> remove(BooruConfig config) async {
    _configs.removeWhere((value) => value.id == config.id);
  }

  @override
  Future<BooruConfig?> update(int id, BooruConfigData data) async {
    final index = _configs.indexWhere((config) => config.id == id);
    if (index == -1) return null;

    final config = data.toBooruConfig(id: id);
    if (config != null) _configs[index] = config;
    return config;
  }
}

final class MemoryLogOptionsRepository implements LogOptionsRepository {
  LogOptions _options = LogOptions.defaults;

  @override
  Future<LogOptions> load() async => _options;

  @override
  Future<void> save(LogOptions options) async {
    _options = options;
  }
}

final class MemoryMiscDataStore implements MiscDataStore {
  final _values = <String, String>{};

  @override
  String? get(String key) => _values[key];

  @override
  Future<void> put(String key, String value) async {
    _values[key] = value;
  }
}

final class MemoryPersistentCacheStore implements PersistentCacheStore {
  MemoryPersistentCacheStore({this.suppressChangelog = false});

  final bool suppressChangelog;
  final _values = <String, String>{};

  @override
  Iterable<String> get keys => _values.keys;

  @override
  int get length => _values.length;

  @override
  String? get(String key) {
    if (suppressChangelog &&
        key.startsWith('changelog_') &&
        key.endsWith('_seen')) {
      return '';
    }

    return _values[key];
  }

  @override
  Future<void> put(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> clear() async => _values.clear();
}

final class TestConnectivityService implements ConnectivityService {
  const TestConnectivityService({this.result = ConnectivityResult.wifi});

  final ConnectivityResult result;

  @override
  Stream<List<ConnectivityResult>> get changes => const Stream.empty();

  @override
  Future<List<ConnectivityResult>> getCurrent() async => [result];
}

final class TestDeviceAuthenticator implements DeviceAuthenticator {
  const TestDeviceAuthenticator();

  @override
  Future<bool> get canCheckBiometrics async => false;

  @override
  Future<bool> isDeviceSupported() async => false;

  @override
  Future<bool> authenticate({required String localizedReason}) async => false;
}

final class TestWindowService implements WindowService {
  const TestWindowService();

  @override
  Future<bool> isAlwaysOnTop() async => false;

  @override
  Future<void> setAlwaysOnTop(bool value) async {}
}

/// An in-memory [AppFileSystem] for tests that must exercise file behavior.
/// No method resolves or touches a host filesystem path.
final class MemoryAppFileSystem implements AppFileSystem {
  final _files = <String, Uint8List>{};
  final _directories = <String>{'/memory'};
  final _modified = <String, DateTime>{};
  var _temporaryDirectoryIndex = 0;

  @override
  Future<String> getAppStoragePath() async => '/memory/app';

  @override
  Future<String?> getTemporaryPath() async => '/memory/tmp';

  @override
  Future<String?> getDownloadPath() async => '/memory/downloads';

  @override
  Future<bool> fileExists(String path) async => fileExistsSync(path);

  @override
  bool fileExistsSync(String path) => _files.containsKey(path);

  @override
  Future<Uint8List> readBytes(String path) async => readBytesSync(path);

  @override
  Uint8List readBytesSync(String path) {
    final bytes = _files[path];
    if (bytes == null) throw StateError('File does not exist: $path');
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeBytes(String path, Uint8List bytes) async {
    _ensureParentDirectories(path);
    _files[path] = Uint8List.fromList(bytes);
    _modified[path] = DateTime.utc(2020);
  }

  @override
  Future<String> readString(String path) async =>
      utf8.decode(readBytesSync(path));

  @override
  Future<String?> readStringIfExists(String path) async {
    if (!fileExistsSync(path)) return null;
    return readString(path);
  }

  @override
  Future<void> writeString(
    String path,
    String content, {
    bool flush = false,
  }) => writeBytes(path, Uint8List.fromList(utf8.encode(content)));

  @override
  Future<void> deleteFile(String path) async {
    if (!fileExistsSync(path)) throw StateError('File does not exist: $path');
    _files.remove(path);
    _modified.remove(path);
  }

  @override
  Future<void> deleteFileIfExists(String path) async {
    if (fileExistsSync(path)) await deleteFile(path);
  }

  @override
  Future<void> copyFile(String source, String destination) async {
    await writeBytes(destination, readBytesSync(source));
  }

  @override
  void copyFileSync(String source, String destination) {
    _ensureParentDirectories(destination);
    _files[destination] = readBytesSync(source);
    _modified[destination] = DateTime.utc(2020);
  }

  @override
  Future<void> renameFile(String source, String destination) async {
    copyFileSync(source, destination);
    await deleteFile(source);
  }

  @override
  Future<int> fileSize(String path) async => fileSizeSync(path);

  @override
  int fileSizeSync(String path) => readBytesSync(path).length;

  @override
  Future<DateTime> lastModified(String path) async => lastModifiedSync(path);

  @override
  DateTime lastModifiedSync(String path) {
    if (!fileExistsSync(path)) throw StateError('File does not exist: $path');
    return _modified[path] ?? DateTime.utc(2020);
  }

  @override
  Stream<List<int>> openRead(String path, {int? start, int? end}) async* {
    final bytes = readBytesSync(path);
    yield bytes.sublist(start ?? 0, end ?? bytes.length);
  }

  @override
  Future<StreamSink<List<int>>> openWrite(String path) async {
    _ensureParentDirectories(path);
    // The returned sink owns the controller and closes it when the caller is
    // done writing.
    // ignore: close_sinks
    final controller = StreamController<List<int>>();
    final chunks = <int>[];
    controller.stream.listen(
      chunks.addAll,
      onDone: () {
        _files[path] = Uint8List.fromList(chunks);
        _modified[path] = DateTime.utc(2020);
      },
    );
    return controller.sink;
  }

  @override
  Future<String> createTempDirectory(String prefix) async {
    final path = '/memory/$prefix-${_temporaryDirectoryIndex++}';
    _directories.add(path);
    return path;
  }

  @override
  Future<bool> directoryExists(String path) async => directoryExistsSync(path);

  @override
  bool directoryExistsSync(String path) => _directories.contains(path);

  @override
  Future<void> createDirectory(String path, {bool recursive = false}) async {
    if (recursive) {
      _ensureParentDirectories(path);
    }
    _directories.add(path);
  }

  @override
  Future<void> deleteDirectory(String path, {bool recursive = false}) async {
    deleteDirectorySync(path, recursive: recursive);
  }

  @override
  void deleteDirectorySync(String path, {bool recursive = false}) {
    if (recursive) {
      _directories.removeWhere(
        (value) => value == path || value.startsWith('$path/'),
      );
      _files.removeWhere((key, _) => key.startsWith('$path/'));
    } else {
      _directories.remove(path);
    }
  }

  @override
  Future<List<FileSystemEntry>> listDirectory(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  }) async => listDirectorySync(path, recursive: recursive);

  @override
  List<FileSystemEntry> listDirectorySync(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  }) {
    final prefix = path.endsWith('/') ? path : '$path/';
    final paths = <String>{
      ..._directories.where((value) => value.startsWith(prefix)),
      ..._files.keys.where((value) => value.startsWith(prefix)),
    };
    return paths
        .where(
          (value) => recursive || !value.substring(prefix.length).contains('/'),
        )
        .map(
          (value) => FileSystemEntry(
            path: value,
            type: _files.containsKey(value)
                ? FileSystemEntryType.file
                : FileSystemEntryType.directory,
          ),
        )
        .toList();
  }

  @override
  Stream<FileSystemEntry> listDirectoryStream(
    String path, {
    bool recursive = false,
    bool followLinks = true,
  }) => Stream.fromIterable(listDirectorySync(path, recursive: recursive));

  void _ensureParentDirectories(String path) {
    final parts = path.split('/');
    final current = StringBuffer();
    for (final part in parts.take(parts.length - 1)) {
      if (part.isEmpty) continue;
      current.write('/$part');
      _directories.add(current.toString());
    }
  }
}
