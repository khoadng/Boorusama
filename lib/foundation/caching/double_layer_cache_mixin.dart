// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'cache_mixin.dart';
import 'persistent_cache_mixin.dart';

/// A mixin for implementing a double-layer cache mechanism for data storage.
///
/// This mixin combines temporary in-memory caching and persistent storage
/// to efficiently manage and retrieve data.
mixin DoubleLayerCacheMixin<TData> {
  PersistentCache get persistentCache;
  Cache<TData> get tempCache;

  String get debugObjectName;
  String get debugFetcherName;

  /// Retrieves data based on a list of keys, with options for custom fetchers
  /// and storage checks.
  ///
  /// - [keys]: A list of keys to retrieve data for.
  /// - [fetcher]: A function that fetches data for keys not found in the caches.
  /// - [onTempStorageCheck]: An optional callback for checking data in temp storage.
  /// - [onPersistentStorageCheck]: An optional callback for checking data in persistent storage.
  Future<List<TData>> retrieve({
    required Set<String> keys,
    required Future<List<TData>> Function(Set<String> freshKeys) fetcher,
    void Function(List<TData> data)? onTempStorageCheck,
    void Function(List<TData> data)? onPersistentStorageCheck,
  }) async {
    _debugPrint('Getting data for a total of ${keys.length} $debugObjectName');

    final cachedData = _checkTempStorage(keys);

    final notInMemKeys =
        keys.where((key) => !cachedData.any((d) => getKey(d) == key)).toList();

    _debugPrint(
        'Reaching out to persistent storage for ${notInMemKeys.length} $debugObjectName');

    final persistentData = await _checkPersistentStorage(notInMemKeys);

    _debugPrint(
        'Found ${persistentData.length} $debugObjectName in persistent storage');

    final notInPersistentKeys = notInMemKeys
        .where((key) => !persistentData.any((d) => getKey(d) == key))
        .toSet();

    var freshData = <TData>[];

    if (notInPersistentKeys.isNotEmpty) {
      _debugPrint(
          'Reaching out to the $debugFetcherName for ${notInPersistentKeys.length} $debugObjectName');

      freshData = await fetcher(notInPersistentKeys);
    }

    var debugPersistentDataCount = 0;
    var debugTempDataCount = 0;

    for (final data in freshData) {
      if (shouldUsePersistentStorage(data)) {
        debugPersistentDataCount++;
        await _storeInPersistentStorage(data);
      } else {
        debugTempDataCount++;
        _storeInTempStorage(data);
      }
    }

    _debugPrint(
        'Stored $debugPersistentDataCount $debugObjectName in persistent storage and $debugTempDataCount $debugObjectName in temp storage');

    _debugPrint(
        'Returning ${cachedData.length} short-lived $debugObjectName, ${persistentData.length} long-lived $debugObjectName and ${freshData.length} fresh $debugObjectName');

    return [...cachedData, ...persistentData, ...freshData];
  }

  Future<void> _storeInPersistentStorage(TData data) async {
    final json = toJson(data);
    final encoded = jsonEncode(json);
    final key = getKey(data);
    await persistentCache.save(key, encoded);
  }

  void _storeInTempStorage(TData data) {
    final key = getKey(data);
    tempCache.set(key, data);
  }

  List<TData> _checkTempStorage(Set<String> keys) {
    final cachedData = <TData>[];

    for (final key in keys) {
      final cached = tempCache.get(key);

      if (cached == null) continue;

      cachedData.add(cached);
    }

    return cachedData;
  }

  Future<List<TData>> _checkPersistentStorage(List<String> keys) async {
    final cachedData = <TData>[];

    for (final key in keys) {
      final cached = await persistentCache.load(key);

      if (cached == null) continue;

      final json = jsonDecode(cached);

      final obj = fromJson(json);

      cachedData.add(obj);
    }

    return cachedData;
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      print('[DoubleLayerCacheMixin] $message');
    }
  }

  /// Determines if data should be stored persistently.
  bool Function(TData data) get shouldUsePersistentStorage;

  /// Converts JSON data to an object of type [TData].
  TData Function(Map<String, dynamic> json) get fromJson;

  /// Converts an object of type [TData] to JSON data.
  Map<String, dynamic> Function(TData data) get toJson;

  /// Retrieves a unique key for a data object.
  String Function(TData data) get getKey;
}
