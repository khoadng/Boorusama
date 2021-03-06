// Package imports:
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';
import 'package:boorusama/core/infrastructure/caching/i_cache.dart';

final postStatisticsCacheProvider = Provider<IPostStatisticsCache>((ref) {
  final box = Hive.openBox("artist_commentary");
  return PostStatisticsCache(box);
});

abstract class IPostStatisticsCache implements ICache<PostStatistics> {}

class PostStatisticsCache implements IPostStatisticsCache {
  final Future<Box> _cache;

  PostStatisticsCache(this._cache);

  @override
  void put(String key, PostStatistics item, Duration expire) async {
    final box = await _cache;
    final json = item.toJson();
    json["expire"] = DateTime.now().add(expire).toIso8601String();
    box.put(key, json);
  }

  @override
  Future<PostStatistics> get(String key) async {
    final box = await _cache;
    final data = box.get(key);
    if (data == null) {
      return PostStatistics.empty();
    } else {
      return PostStatistics.fromJson(data..remove("expire"));
    }
  }

  @override
  Future<bool> isExist(String key) async {
    final box = await _cache;
    return box.containsKey(key);
  }

  @override
  Future<bool> isExpired(String key) async {
    final box = await _cache;
    final data = box.get(key);
    final expire = DateTime.parse(data["expire"]);

    return DateTime.now().isAfter(expire);
  }
}
