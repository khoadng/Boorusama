// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../../foundation/caching.dart';
import 'types/tag.dart';
import 'types/tag_display.dart';
import 'types/tag_repository.dart';

bool storeTagLargerThan1000Posts(Tag tag) => tag.postCount > 1000;

class EmptyTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async =>
      [];
}

class TagRepositoryBuilder
    with DoubleLayerCacheMixin<Tag>
    implements TagRepository {
  TagRepositoryBuilder({
    required String persistentStorageKey,
    required this.getTags,
    Duration persistentStaleDuration = const Duration(days: 3),
    Duration tempStaleDuration = const Duration(minutes: 10),
    int tempStorageMaxCapacity = 1000,
    this.shouldUsePersistentStorage = storeTagLargerThan1000Posts,
  }) {
    persistentCache = PersistentCache(
      persistentStorageKey: persistentStorageKey,
      persistentStaleDuration: persistentStaleDuration,
    );

    tempCache = Cache(
      staleDuration: tempStaleDuration,
      maxCapacity: tempStorageMaxCapacity,
    );
  }

  final Future<List<Tag>> Function(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) getTags;

  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) =>
      retrieve(
        keys: tags,
        fetcher: (freshTags) => getTags(
          freshTags,
          page,
          cancelToken: cancelToken,
        ),
      );

  @override
  String get debugFetcherName => 'API';

  @override
  String get debugObjectName => 'tags';

  @override
  Tag Function(Map<String, dynamic> json) get fromJson => Tag.fromJson;

  @override
  String Function(Tag data) get getKey => (tag) => tag.rawName;

  @override
  late PersistentCache persistentCache;

  @override
  late Cache<Tag> tempCache;

  @override
  Map<String, dynamic> Function(Tag data) get toJson => (tag) => tag.toJson();

  @override
  final bool Function(Tag data) shouldUsePersistentStorage;

  @override
  final bool enableDebugPrint = false;
}
