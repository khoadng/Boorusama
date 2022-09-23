// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:hive/hive.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/core/infra/caching/cacher.dart';

class AutocompleteHttpCacher implements Cacher<String, String> {
  const AutocompleteHttpCacher({
    required this.box,
  });

  final Box<String> box;

  @override
  void clear() => box.clear();

  @override
  bool exist(String key) => box.containsKey(key);

  @override
  String? get(String key) {
    if (!exist(key)) return null;
    return box.get(key);
  }

  @override
  Future<void> put(String key, String item) async {
    await box.put(key, item);
  }
}

CacheObject cacheObjectFromJson(String str) =>
    CacheObject.fromJson(json.decode(str));

String cacheObjectToJson(CacheObject data) => json.encode(data.toJson());

class CacheObject {
  CacheObject({
    required this.value,
    required this.expire,
  });

  factory CacheObject.fromJson(Map<String, dynamic> json) => CacheObject(
        value: json['value'],
        expire: DateTime.parse(json['expire']),
      );

  final String value;
  final DateTime expire;

  Map<String, dynamic> toJson() => {
        'value': value,
        'expire': expire.toIso8601String(),
      };
}

extension CacheObjectX on CacheObject {
  bool isExpire(DateTime now) => now.isAfter(expire);
  bool isFresh(DateTime now) => !isExpire(now);
}

Future<HttpResponse<dynamic>> updateCache(
  Cacher<String, String> cache,
  String key,
  HttpResponse<dynamic> value,
) async {
  final info = parseCacheInfo(value);

  // Do nothing if no information available
  if (info == null) return value;

  final duration = Duration(seconds: info.maxAge);
  final expire = DateTime.now().add(duration);
  final obj = cacheObjectToJson(CacheObject(
    value: jsonEncode(value.data),
    expire: expire,
  ));

  await cache.put(key, obj);

  return value;
}

enum CacheVisibility {
  public,
  private,
}

class HttpCacheInfo {
  const HttpCacheInfo({
    required this.maxAge,
    required this.visibility,
  });

  final int maxAge;
  final CacheVisibility visibility;
}

HttpCacheInfo? parseCacheInfo(HttpResponse<dynamic> response) {
  final cacheControlHeader = response.response.headers.value('Cache-Control');

  // No cache information available
  if (cacheControlHeader == null) return null;

  final cacheControl = parseCacheControl(cacheControlHeader);
  final visibility = cacheControl.containsKey('public')
      ? parseCacheVisibility(cacheControl['public']!)
      : CacheVisibility.public;

  final maxAge = cacheControl.containsKey('max-age')
      ? parseMaxAge(cacheControl['max-age']!)
      : 0;

  return HttpCacheInfo(
    maxAge: maxAge,
    visibility: visibility,
  );
}

CacheVisibility parseCacheVisibility(String value) {
  if (value == 'public') return CacheVisibility.public;
  if (value == 'private') return CacheVisibility.private;

  return CacheVisibility.public;
}

final responseDirective = [
  'max-age',
  'public',
];

Map<String, String> parseCacheControl(String? value) {
  String parseKey(String v) {
    for (final d in responseDirective) {
      if (v.contains(d)) {
        return d;
      }
    }
    return v;
  }

  if (value == null) return {};
  return {for (var i in value.split(',').map((e) => e.trim())) parseKey(i): i};
}

int parseMaxAge(String value) {
  final ageString = value.replaceAll('max-age=', '');
  final age = int.tryParse(ageString);
  return age ?? 0;
}
