// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/caching/persistent_cache_mixin.dart';
import 'tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  });
}

bool storeTagLargerThan1000Posts(Tag tag) => tag.postCount > 1000;

class TagRepositoryBuilder
    with PersistentCacheMixin, CacheMixin<Tag>
    implements TagRepository {
  TagRepositoryBuilder({
    required this.persistentStorageKey,
    required this.getTags,
    this.persistentStaleDuration = const Duration(days: 3),
    Duration tempStaleDuration = const Duration(minutes: 10),
    int tempStorageMaxCapacity = 1000,
    this.shouldUsePersistentStorage = storeTagLargerThan1000Posts,
  }) {
    maxCapacity = 1000;
    staleDuration = tempStaleDuration;
  }

  final Future<List<Tag>> Function(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) getTags;

  @override
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async {
    _debugPrint('Getting data for a total of ${tags.length} tags');

    final cachedTags = _checkTempStorage(tags);

    _debugPrint('Found ${cachedTags.length} tags in temp storage');

    final notInMemTags =
        tags.where((tag) => !cachedTags.any((t) => t.rawName == tag)).toList();

    _debugPrint(
        'Reaching out to persistent storage for ${notInMemTags.length} tags');

    final persistentTags = await _checkPersistentStorage(notInMemTags);

    _debugPrint('Found ${persistentTags.length} tags in persistent storage');

    final notInPersistentTags = notInMemTags
        .where((tag) => !persistentTags.any((t) => t.rawName == tag))
        .toList();

    var freshTags = <Tag>[];

    if (notInPersistentTags.isNotEmpty) {
      _debugPrint(
          'Reaching out to the API for ${notInPersistentTags.length} tags');

      freshTags = await getTags(notInPersistentTags, page);
    }

    var debugPersistentTagCount = 0;
    var debugTempTagCount = 0;

    for (final tag in freshTags) {
      if (shouldUsePersistentStorage(tag)) {
        debugPersistentTagCount++;
        await _storeInPersistentStorage(tag);
      } else {
        debugTempTagCount++;
        _storeInTempStorage(tag);
      }
    }

    _debugPrint(
        'Stored $debugPersistentTagCount tags in persistent storage and $debugTempTagCount tags in temp storage');

    _debugPrint(
        'Returning ${cachedTags.length + persistentTags.length} cached tags and ${freshTags.length} fresh tags');

    return [...cachedTags, ...persistentTags, ...freshTags];
  }

  Future<void> _storeInPersistentStorage(Tag tag) async {
    final json = tag.toJson();
    final encoded = jsonEncode(json);
    await save(tag.rawName, encoded);
  }

  void _storeInTempStorage(Tag tag) {
    set(tag.rawName, tag);
  }

  // Check temp storage for tags
  List<Tag> _checkTempStorage(List<String> tags) {
    final cachedTags = <Tag>[];

    for (final tag in tags) {
      final cached = get(tag);

      if (cached == null) continue;

      cachedTags.add(cached);
    }

    return cachedTags;
  }

  Future<List<Tag>> _checkPersistentStorage(List<String> tags) async {
    final cachedTags = <Tag>[];

    for (final tag in tags) {
      final cached = await load(tag);

      if (cached == null) continue;

      final json = jsonDecode(cached);

      final tagObj = Tag.fromJson(json);

      cachedTags.add(tagObj);
    }

    return cachedTags;
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  @override
  final Duration persistentStaleDuration;

  @override
  final String persistentStorageKey;

  @override
  late int maxCapacity;

  @override
  late Duration staleDuration;

  final bool Function(Tag tag) shouldUsePersistentStorage;
}
