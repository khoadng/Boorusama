import 'package:dio/dio.dart';
import 'package:coreutils/coreutils.dart';
import 'endpoint.dart';
import 'feature.dart';
import 'feature_sort.dart';

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
    FeatureSortSelection? sort,
  }) async {
    final endpoint = config.getEndpoint(featureId);

    if (endpoint == null) {
      throw ArgumentError('Feature not supported: ${featureId.name}');
    }

    final stringParams = _buildRequestParams(params ?? {});
    var url = endpoint.buildUrl(baseUrl, stringParams);
    final requestContext = buildContext(context);
    Options? options;

    if (sort != null) {
      switch (sort.transport) {
        case FeatureSortTransport.cookie:
          options = Options(
            headers: {
              'cookie': CookieUtils.mergeCookieHeaders(
                _baseCookieHeader(),
                '${sort.key}=${sort.value}',
              ),
            },
          );
        case FeatureSortTransport.queryParameter:
          final uri = Uri.parse(url);
          url = uri
              .replace(
                queryParameters: {
                  ...uri.queryParameters,
                  sort.key: sort.value,
                },
              )
              .toString();
      }
    }

    final response = await dio.get(url, options: options);
    return endpoint.parseResponse(response, requestContext) as T;
  }

  String _baseCookieHeader() {
    for (final entry in dio.options.headers.entries) {
      if (entry.key.toLowerCase() == 'cookie') {
        return entry.value?.toString() ?? '';
      }
    }

    return '';
  }

  Map<String, String> _buildRequestParams(Map<String, dynamic> params) {
    final result = <String, String>{...buildAuthParams()};

    params.forEach((key, value) {
      if (value != null) result[key] = value.toString();
    });

    return result;
  }
}
