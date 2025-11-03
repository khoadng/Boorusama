// Package imports:
import 'package:hive_ce/hive.dart';

mixin Shimmie2CacheMixin {
  Box get box;

  Future<void> remove(String key) async {
    await box.delete(key);
    await box.delete('${key}_timestamp');
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<DateTime?> getTimestamp(String key) async {
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

  Future<void> setTimestamp(String key, DateTime timestamp) async {
    await box.put('${key}_timestamp', timestamp.millisecondsSinceEpoch);
  }
}
