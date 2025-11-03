import 'dart:convert';

import 'package:booru_clients/src/shimmie2/graphql/field_discovery.dart';
import 'package:booru_clients/src/shimmie2/graphql/graphql_client.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

class MockGraphQLClient extends GraphQLClient {
  MockGraphQLClient({
    this.mockResponse,
    this.shouldThrow = false,
    this.mockBaseUrl = 'https://example.com',
  }) : super(
         dio: Dio(BaseOptions(baseUrl: mockBaseUrl)),
         authParams: () => {},
       );

  GraphQLResponse? mockResponse;
  bool shouldThrow;
  final String mockBaseUrl;

  @override
  String get baseUrl => mockBaseUrl;

  @override
  Future<GraphQLResponse<T>> executeQueryRaw<T>({
    required String query,
    required Map<String, dynamic> variables,
    required T Function(dynamic) parseData,
  }) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return mockResponse! as GraphQLResponse<T>;
  }
}

void main() {
  final allFields = ['field1', 'field2', 'field3'];
  final coreFields = {'field1'};

  String buildQuery(Iterable<String> fields) => 'query { ${fields.join(' ')} }';

  String getCacheKey(String baseUrl) {
    final hash = sha256.convert(utf8.encode(baseUrl)).toString();
    return 'field_discovery_$hash';
  }

  group('FieldDiscovery', () {
    final cases = [
      (
        name: 'all fields available on successful response',
        response: GraphQLSuccess<dynamic>({'data': {}}),
        shouldThrow: false,
        expectedFields: {'field1', 'field2', 'field3'},
      ),
      (
        name: 'unavailable fields removed on error response',
        response: GraphQLError<dynamic>([
          {'message': 'Cannot query field "field2"'},
        ]),
        shouldThrow: false,
        expectedFields: {'field1', 'field3'},
      ),
      (
        name: 'core fields returned on exception',
        response: null,
        shouldThrow: true,
        expectedFields: {'field1'},
      ),
    ];

    for (final c in cases) {
      test(c.name, () async {
        final client = MockGraphQLClient(
          mockResponse: c.response,
          shouldThrow: c.shouldThrow,
        );

        final discovery = FieldDiscovery(
          client: client,
          allFields: allFields,
          coreFields: coreFields,
          buildDiscoveryQuery: buildQuery,
          discoveryVariables: {},
        );

        final fields = await discovery.ensureDiscovered();
        expect(fields, c.expectedFields);
      });
    }

    test('stores discovered fields in cache', () async {
      final cache = MockGraphQLCache();
      final client = MockGraphQLClient(
        mockResponse: GraphQLSuccess<dynamic>({'data': {}}),
      );

      final discovery = FieldDiscovery(
        client: client,
        allFields: allFields,
        coreFields: coreFields,
        buildDiscoveryQuery: buildQuery,
        discoveryVariables: {},
        cache: cache,
      );

      final fields = await discovery.ensureDiscovered();

      expect(fields, allFields.toSet());
      expect(await cache.get<Set<String>>(getCacheKey(client.baseUrl)), fields);
    });

    test(
      'returns cached data instead of rediscovering when cache valid',
      () async {
        final cache = MockGraphQLCache();
        final cacheKey = getCacheKey('https://example.com');
        final cachedFields = {'field1', 'field2'};

        // Pre-populate cache with subset of fields
        await cache.set(cacheKey, cachedFields);
        await cache.setTimestamp(cacheKey, DateTime.now());

        // Mock would return ALL fields if discovery runs
        final client = MockGraphQLClient(
          mockResponse: GraphQLSuccess<dynamic>({'data': {}}),
        );

        final discovery = FieldDiscovery(
          client: client,
          allFields: allFields,
          coreFields: coreFields,
          buildDiscoveryQuery: buildQuery,
          discoveryVariables: {},
          cache: cache,
          cacheTtl: const Duration(days: 7),
        );

        final fields = await discovery.ensureDiscovered();

        // Should return cached subset, NOT all fields
        expect(fields, cachedFields);
      },
    );

    test('ignores expired cache and rediscovers', () async {
      final cache = MockGraphQLCache();
      final cacheKey = getCacheKey('https://example.com');

      // Pre-populate with stale data
      await cache.set(cacheKey, {'field1'});
      await cache.setTimestamp(
        cacheKey,
        DateTime.now().subtract(const Duration(days: 8)),
      );

      // Mock returns success = all fields available
      final client = MockGraphQLClient(
        mockResponse: GraphQLSuccess<dynamic>({'data': {}}),
      );

      final discovery = FieldDiscovery(
        client: client,
        allFields: allFields,
        coreFields: coreFields,
        buildDiscoveryQuery: buildQuery,
        discoveryVariables: {},
        cache: cache,
        cacheTtl: const Duration(days: 7),
      );

      final fields = await discovery.ensureDiscovered();

      // Should rediscover and return all fields, not stale cached field
      expect(fields, allFields.toSet());
    });

    test('clears cache data when invalidated', () async {
      final cache = MockGraphQLCache();
      final client = MockGraphQLClient(
        mockResponse: GraphQLSuccess<dynamic>({'data': {}}),
      );

      final discovery = FieldDiscovery(
        client: client,
        allFields: allFields,
        coreFields: coreFields,
        buildDiscoveryQuery: buildQuery,
        discoveryVariables: {},
        cache: cache,
      );

      await discovery.ensureDiscovered();

      final cachedBefore = await cache.get<Set<String>>(
        getCacheKey(client.baseUrl),
      );
      expect(cachedBefore, isNotNull);

      await discovery.invalidateCache();

      final cachedAfter = await cache.get<Set<String>>(
        getCacheKey(client.baseUrl),
      );
      expect(cachedAfter, isNull);
    });
  });
}
