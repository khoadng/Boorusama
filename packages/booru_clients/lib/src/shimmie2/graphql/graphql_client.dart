// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';

sealed class GraphQLResponse<T> {}

class GraphQLSuccess<T> extends GraphQLResponse<T> {
  GraphQLSuccess(this.data);
  final T data;
}

class GraphQLError<T> extends GraphQLResponse<T> {
  GraphQLError(this.errors);
  final List errors;
}

class GraphQLClient {
  GraphQLClient({
    required Dio dio,
    required Map<String, String> authParams,
  }) : _dio = dio,
       _authParams = authParams;

  final Dio _dio;
  final Map<String, String> _authParams;

  String get baseUrl => _dio.options.baseUrl;

  Future<GraphQLResponse<T>> executeQueryRaw<T>({
    required String query,
    required Map<String, dynamic> variables,
    required T Function(dynamic) parseData,
  }) async {
    final response = await _dio.post(
      '/graphql',
      queryParameters: _authParams,
      data: {'query': query, 'variables': variables},
    );

    return switch (response.data) {
      null => throw Exception('GraphQL response data is null'),
      {'errors': final List errors} => GraphQLError(errors),
      {'data': final data?} => GraphQLSuccess(parseData(data)),
      _ => throw Exception('Unexpected GraphQL response structure'),
    };
  }

  Future<T> executeQuery<T>({
    required String query,
    required Map<String, dynamic> variables,
    required T Function(dynamic) parseData,
  }) async {
    final result = await executeQueryRaw(
      query: query,
      variables: variables,
      parseData: parseData,
    );

    return switch (result) {
      GraphQLSuccess(data: final data) => data,
      GraphQLError(errors: final errors) => throw Exception(
        'GraphQL errors: ${_formatErrors(errors)}',
      ),
    };
  }

  String _formatErrors(List errors) => errors
      .whereType<Map>()
      .map((e) => e['message'] as String?)
      .whereType<String>()
      .join(', ');
}
