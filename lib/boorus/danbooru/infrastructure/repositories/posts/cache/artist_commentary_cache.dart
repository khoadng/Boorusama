// Package imports:
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/core/infrastructure/caching/i_cache.dart';

final artistCommentaryCacheProvider = Provider<IArtistCommentaryCache>((ref) {
  final box = Hive.openBox("artist_commentary");
  return ArtistCommentaryCache(box);
});

abstract class IArtistCommentaryCache implements ICache<ArtistCommentary> {}

class ArtistCommentaryCache implements IArtistCommentaryCache {
  final Future<Box> _cache;

  ArtistCommentaryCache(this._cache);

  @override
  void put(String key, ArtistCommentary item, Duration expire) async {
    final box = await _cache;
    final json = item.toJson();
    json["expire"] = DateTime.now().add(expire).toIso8601String();
    box.put(key, json);
  }

  @override
  Future<ArtistCommentary> get(String key) async {
    final box = await _cache;
    final data = box.get(key);
    if (data == null) {
      return ArtistCommentary.empty();
    } else {
      return ArtistCommentary.fromJson(data..remove("expire"));
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
