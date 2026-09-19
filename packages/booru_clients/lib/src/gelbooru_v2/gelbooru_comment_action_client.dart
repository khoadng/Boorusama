import 'package:dio/dio.dart';

import '../common/feature.dart';
import '../gelbooru/gelbooru_session.dart';

const gelbooruV2CommentUpvoteAction = 'upvote';

class GelbooruCommentActionException implements Exception {
  const GelbooruCommentActionException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

final class GelbooruCommentActionClient {
  GelbooruCommentActionClient({
    required Dio dio,
    required String baseUrl,
    required String? userId,
    required String? passHash,
    required Map<String, FeatureActionEndpoint> actions,
  }) : _dio = dio,
       _baseUrl = baseUrl,
       _userId = userId,
       _passHash = passHash,
       _actions = Map.unmodifiable(actions);

  final Dio _dio;
  final String _baseUrl;
  final String? _userId;
  final String? _passHash;
  final Map<String, FeatureActionEndpoint> _actions;

  bool supports(String actionName) => _actions.containsKey(actionName);

  bool canInvoke(String actionName) {
    final action = _actions[actionName];
    if (action == null) return false;

    return switch (action.auth) {
      ActionAuthMode.none => true,
      ActionAuthMode.sessionCookie => _hasSession,
    };
  }

  Future<int> upvote({
    required int postId,
    required int commentId,
    CancelToken? cancelToken,
  }) async {
    final value = await _invoke(
      gelbooruV2CommentUpvoteAction,
      semanticParams: {
        P.postId: postId,
        P.commentId: commentId,
      },
      cancelToken: cancelToken,
    );

    if (value is int) return value;

    throw GelbooruCommentActionException(
      'Comment action "$gelbooruV2CommentUpvoteAction" returned an invalid integer response.',
    );
  }

  Future<Object?> _invoke(
    String actionName, {
    required Map<String, Object?> semanticParams,
    CancelToken? cancelToken,
  }) async {
    final action = _actions[actionName];
    if (action == null) {
      throw GelbooruCommentActionException(
        'Comment action "$actionName" is not supported.',
      );
    }

    if (!canInvoke(actionName)) {
      throw GelbooruCommentActionException(
        'Comment action "$actionName" requires an authenticated session.',
      );
    }

    final mappedParams = <String, String>{};
    for (final entry in semanticParams.entries) {
      final value = entry.value;
      if (value == null) continue;

      final wireName = action.paramMappings[entry.key];
      if (wireName == null || wireName.isEmpty) {
        throw GelbooruCommentActionException(
          'Comment action "$actionName" is missing a mapping for semantic parameter "${entry.key}".',
        );
      }
      mappedParams[wireName] = value.toString();
    }

    final requestParams = <String, String>{
      ...mappedParams,
      ...action.fixedParams,
    };
    final endpoint = Uri.parse(action.baseUrl ?? _baseUrl).resolve(action.path);

    try {
      final response = switch (action.method) {
        ActionRequestMethod.get => await _dio.get(
          _withQueryParameters(endpoint, requestParams).toString(),
          cancelToken: cancelToken,
          options: _optionsFor(action),
        ),
        ActionRequestMethod.post => await _dio.post(
          endpoint.toString(),
          data: requestParams,
          cancelToken: cancelToken,
          options: _optionsFor(action),
        ),
      };

      return _decodeResponse(action, response.data);
    } on DioException catch (error, stackTrace) {
      if (CancelToken.isCancel(error)) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      throw GelbooruCommentActionException(
        'Comment action "$actionName" failed.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on GelbooruCommentActionException {
      rethrow;
    } catch (error, stackTrace) {
      throw GelbooruCommentActionException(
        'Comment action "$actionName" failed.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Options _optionsFor(FeatureActionEndpoint action) {
    final headers = switch (action.auth) {
      ActionAuthMode.none => null,
      ActionAuthMode.sessionCookie => buildGelbooruSessionHeaders(
        userId: _userId!,
        passHash: _passHash!,
      ),
    };

    return Options(
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
      headers: headers,
    );
  }

  Object? _decodeResponse(FeatureActionEndpoint action, dynamic data) {
    return switch (action.responseType) {
      ActionResponseType.empty => null,
      ActionResponseType.integer => _decodeInteger(action.name, data),
      ActionResponseType.text when data is String => data,
      ActionResponseType.text => throw _invalidResponse(action.name),
      ActionResponseType.json => data,
    };
  }

  int _decodeInteger(String actionName, dynamic data) {
    final value = switch (data) {
      final int value => value,
      final num value when value == value.toInt() => value.toInt(),
      final String value => int.tryParse(value.trim()),
      _ => null,
    };

    if (value == null) throw _invalidResponse(actionName);
    return value;
  }

  GelbooruCommentActionException _invalidResponse(String actionName) =>
      GelbooruCommentActionException(
        'Comment action "$actionName" returned an invalid response.',
      );

  Uri _withQueryParameters(Uri endpoint, Map<String, String> params) {
    return endpoint.replace(
      queryParameters: {
        ...endpoint.queryParameters,
        ...params,
      },
    );
  }

  bool get _hasSession =>
      _userId?.isNotEmpty == true && _passHash?.isNotEmpty == true;
}
