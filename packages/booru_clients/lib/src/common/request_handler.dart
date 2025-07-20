import 'package:dio/dio.dart';
import 'endpoint.dart';
import 'feature.dart';

typedef AuthParamsBuilder = Map<String, String> Function();
typedef ContextBuilder = Map<String, dynamic> Function(Map<String, dynamic>?);

class RequestHandler {
  const RequestHandler({
    required this.dio,
    required this.baseUrl,
    required this.config,
    required this.buildAuthParams,
    required this.buildContext,
  });

  final Dio dio;
  final String baseUrl;
  final EndpointConfig config;
  final AuthParamsBuilder buildAuthParams;
  final ContextBuilder buildContext;

  Future<T> makeRequest<T>({
    required BooruFeatureId featureId,
    Map<String, dynamic>? params,
    Map<String, dynamic>? context,
  }) async {
    final endpoint = config.getEndpoint(featureId);

    if (endpoint == null) {
      throw ArgumentError('Feature not supported: ${featureId.name}');
    }

    final stringParams = _buildRequestParams(params ?? {});
    final url = endpoint.buildUrl(baseUrl, stringParams);
    final requestContext = buildContext(context);

    final response = await dio.get(url);
    return endpoint.parseResponse(response, requestContext) as T;
  }

  Map<String, String> _buildRequestParams(Map<String, dynamic> params) {
    final result = <String, String>{...buildAuthParams()};

    params.forEach((key, value) {
      if (value != null) result[key] = value.toString();
    });

    return result;
  }
}
