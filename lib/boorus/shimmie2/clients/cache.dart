// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:hive_ce/hive.dart';

class GraphQLCacheHive implements GraphQLCache {
  GraphQLCacheHive(this._box);

  final Future<Box> _box;

  @override
  Future<T?> get<T>(String key) async {
    final box = await _box;
    final value = box.get(key);

    if (value == null) return null;

    return switch ((T, value)) {
      (const (Set<String>), final String jsonStr) =>
        _decodeStringSet(jsonStr) as T?,
      (_, final T typedValue) => typedValue,
      _ => null,
    };
  }

  Set<String>? _decodeStringSet(String jsonStr) {
    try {
      return switch (jsonDecode(jsonStr)) {
        final List list => list.whereType<String>().toSet(),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> set<T>(String key, T value) async {
    final box = await _box;
    final encoded = switch (value) {
      final Set<String> set => jsonEncode(set.toList()),
      _ => value,
    };
    await box.put(key, encoded);
  }

  @override
  Future<void> remove(String key) async {
    final box = await _box;
    await box.delete(key);
  }

  @override
  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }

  @override
  Future<DateTime?> getTimestamp(String key) async {
    final box = await _box;
    final value = box.get('${key}_timestamp');
    if (value == null) return null;

    return switch (value) {
      final int milliseconds => DateTime.fromMillisecondsSinceEpoch(
        milliseconds,
      ),
      final String iso => DateTime.tryParse(iso),
      _ => null,
    };
  }

  @override
  Future<void> setTimestamp(String key, DateTime timestamp) async {
    final box = await _box;
    await box.put('${key}_timestamp', timestamp.millisecondsSinceEpoch);
  }
}
