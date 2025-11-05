// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:crypto/crypto.dart';

// Project imports:
import 'graphql_cache.dart';
import 'graphql_client.dart';

class FieldDiscovery {
  FieldDiscovery({
    required GraphQLClient client,
    required List<String> allFields,
    required Set<String> coreFields,
    required String Function(Iterable<String>) buildDiscoveryQuery,
    required Map<String, dynamic> discoveryVariables,
    GraphQLCache? cache,
    Duration cacheTtl = const Duration(days: 7),
  }) : _client = client,
       _allFields = allFields,
       _coreFields = coreFields,
       _buildDiscoveryQuery = buildDiscoveryQuery,
       _discoveryVariables = discoveryVariables,
       _cache = cache ?? InMemoryGraphQLCache(),
       _cacheTtl = cacheTtl;

  final GraphQLClient _client;
  final List<String> _allFields;
  final Set<String> _coreFields;
  final String Function(Iterable<String>) _buildDiscoveryQuery;
  final Map<String, dynamic> _discoveryVariables;
  final GraphQLCache _cache;
  final Duration _cacheTtl;

  Set<String>? _availableFields;
  bool _discoveryAttempted = false;

  late final String _cacheKey = () {
    final hash = sha256.convert(utf8.encode(_client.baseUrl)).toString();
    return 'field_discovery_$hash';
  }();

  Future<Set<String>> ensureDiscovered() async {
    if (_availableFields case final fields?) return fields;

    final cached = await _cache.get<Set<String>>(_cacheKey);
    if (cached != null) {
      final timestamp = await _cache.getTimestamp(_cacheKey);
      final isExpired = _isCacheExpired(timestamp);

      if (!isExpired) {
        _availableFields = cached;
        _discoveryAttempted = true;
        return cached;
      }
    }

    await _discover();
    return _availableFields!;
  }

  bool _isCacheExpired(DateTime? timestamp) {
    if (timestamp == null) return true;
    final age = DateTime.now().difference(timestamp);
    return age > _cacheTtl;
  }

  Future<void> invalidateCache() async {
    _availableFields = null;
    _discoveryAttempted = false;
    await _cache.remove(_cacheKey);
    await _cache.remove('${_cacheKey}_timestamp');
  }

  Future<void> rediscover() async {
    await invalidateCache();
    await ensureDiscovered();
  }

  Future<void> _discover() async {
    if (_discoveryAttempted) return;
    _discoveryAttempted = true;

    try {
      final result = await _client.executeQueryRaw(
        query: _buildDiscoveryQuery(_allFields),
        variables: _discoveryVariables,
        parseData: (data) => data,
      );

      _availableFields = switch (result) {
        GraphQLSuccess() => _allFields.toSet(),
        GraphQLError(errors: final errors) => _parseAvailableFieldsFromErrors(
          errors,
        ),
      };

      await _cache.set(_cacheKey, _availableFields!);
      await _cache.setTimestamp(_cacheKey, DateTime.now());
    } catch (e) {
      _availableFields = _coreFields;
      await _cache.set(_cacheKey, _availableFields!);
      await _cache.setTimestamp(_cacheKey, DateTime.now());
    }
  }

  Set<String> _parseAvailableFieldsFromErrors(List errors) {
    final unavailableFields = errors
        .whereType<Map>()
        .map((e) => e['message'] as String?)
        .whereType<String>()
        .map(_extractFieldNameFromError)
        .whereType<String>()
        .toSet();

    return _allFields.toSet()..removeAll(unavailableFields);
  }

  String? _extractFieldNameFromError(String message) {
    final pattern = RegExp(r'Cannot query field "(\w+)"');
    final match = pattern.firstMatch(message);
    return match?.group(1);
  }
}
