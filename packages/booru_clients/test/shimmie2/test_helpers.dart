import 'package:booru_clients/src/shimmie2/graphql/graphql_cache.dart';

class MockGraphQLCache implements GraphQLCache {
  final Map<String, dynamic> _storage = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  Future<T?> get<T>(String key) async {
    return _storage[key] as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    _storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
    _timestamps.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
    _timestamps.clear();
  }

  @override
  Future<DateTime?> getTimestamp(String key) async {
    return _timestamps[key];
  }

  @override
  Future<void> setTimestamp(String key, DateTime timestamp) async {
    _timestamps[key] = timestamp;
  }
}
