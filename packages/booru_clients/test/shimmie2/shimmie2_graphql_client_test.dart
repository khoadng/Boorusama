import 'package:booru_clients/src/shimmie2/graphql/graphql_client.dart';
import 'package:booru_clients/src/shimmie2/shimmie2_graphql_client.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

class MockGraphQLClient extends GraphQLClient {
  MockGraphQLClient({
    this.responses = const [],
    this.mockBaseUrl = 'https://example.com',
  }) : super(
         dio: Dio(BaseOptions(baseUrl: mockBaseUrl)),
         authParams: () => {},
       );

  final List<GraphQLResponse> responses;
  final String mockBaseUrl;
  int _callCount = 0;

  @override
  String get baseUrl => mockBaseUrl;

  @override
  Future<GraphQLResponse<T>> executeQueryRaw<T>({
    required String query,
    required Map<String, dynamic> variables,
    required T Function(dynamic) parseData,
  }) async {
    if (_callCount >= responses.length) {
      throw Exception('No more mock responses');
    }
    final response = responses[_callCount++];
    return switch (response) {
      GraphQLSuccess(data: final data) => GraphQLSuccess(parseData(data)),
      GraphQLError(errors: final errors) => GraphQLError(errors),
    };
  }
}

void main() {
  group('Shimmie2GraphQLClient field error recovery', () {
    final cases = [
      (
        name: 'returns posts after recovering from field error',
        responses: [
          GraphQLSuccess<dynamic>({}), // Initial discovery
          GraphQLError<dynamic>([
            {'message': 'Cannot query field "rating"'},
          ]), // Field error
          GraphQLSuccess<dynamic>({}), // Rediscovery
          GraphQLSuccess<dynamic>({
            'posts': [
              {
                'post_id': 1,
                'hash': 'abc',
                'filename': 'test.jpg',
                'width': 800,
                'height': 600,
                'filesize': 1024,
                'posted': '2024-01-01',
                'source': '',
                'locked': false,
                'ext': 'jpg',
                'mime': 'image/jpeg',
                'image_link': '/images/1.jpg',
                'thumb_link': '/thumbs/1.jpg',
                'nice_name': 'test',
                'tooltip': 'test',
                'tags': ['tag1'],
                'owner': {'name': 'user', 'join_date': '2020-01-01'},
              },
            ],
          }), // Retry succeeds
        ],
        shouldThrow: false,
        expectedPostCount: 1,
      ),
      (
        name: 'throws exception for non-field errors',
        responses: [
          GraphQLSuccess<dynamic>({}),
          GraphQLError<dynamic>([
            {'message': 'Authentication required'},
          ]),
        ],
        shouldThrow: true,
        expectedPostCount: 0,
      ),
      (
        name: 'throws exception when retry also fails with field error',
        responses: [
          GraphQLSuccess<dynamic>({}), // Initial discovery
          GraphQLError<dynamic>([
            {'message': 'Cannot query field "rating"'},
          ]), // First field error
          GraphQLSuccess<dynamic>({}), // Rediscovery
          GraphQLError<dynamic>([
            {'message': 'Cannot query field "score"'},
          ]), // Retry also fails with field error
        ],
        shouldThrow: true,
        expectedPostCount: 0,
      ),
    ];

    for (final c in cases) {
      test(c.name, () async {
        final mockClient = MockGraphQLClient(responses: c.responses);
        final client = Shimmie2GraphQLClient(
          client: mockClient,
          cache: MockGraphQLCache(),
        );

        if (c.shouldThrow) {
          expect(
            () => client.getPosts(limit: 1),
            throwsA(isA<Exception>()),
          );
        } else {
          final result = await client.getPosts(limit: 1);
          expect(result.length, c.expectedPostCount);
        }
      });
    }
  });
}
