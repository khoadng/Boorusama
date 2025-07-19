import 'package:dio/dio.dart';
import 'feature.dart';

typedef ResponseParser<T> =
    T Function(Response response, Map<String, dynamic> context);

class Endpoint<T> {
  const Endpoint({
    required this.featureId,
    required this.path,
    required this.parser,
    this.type = EndpointType.api,
    this.baseUrl,
    this.userParams = const {},
  });

  factory Endpoint.fromFeature({
    required FeatureEndpoint feature,
    required ResponseParser<T> parser,
  }) {
    return Endpoint<T>(
      featureId: feature.featureId,
      path: feature.path,
      type: feature.type,
      baseUrl: feature.baseUrl,
      userParams: feature.paramMapping,
      parser: parser,
    );
  }

  final BooruFeatureId featureId;
  final String path;
  final EndpointType type;
  final String? baseUrl;
  final Map<String, String> userParams;
  final ResponseParser<T> parser;

  String buildUrl(String defaultBaseUrl, Map<String, String> inputParams) {
    final base = baseUrl ?? defaultBaseUrl;
    final uri = Uri.parse(base).resolve(path);

    final translatedParams = <String, String>{};
    inputParams.forEach((key, value) {
      final siteParamName = userParams[key] ?? key;
      translatedParams[siteParamName] = value;
    });

    final existingParams = uri.queryParameters;
    final allParams = {...existingParams, ...translatedParams};

    return uri.replace(queryParameters: allParams).toString();
  }

  T parseResponse(Response response, Map<String, dynamic> context) {
    return parser(response, context);
  }

  Endpoint<T> copyWith({
    BooruFeatureId? featureId,
    String? path,
    EndpointType? type,
    String? baseUrl,
    Map<String, String>? userParams,
    ResponseParser<T>? parser,
  }) {
    return Endpoint<T>(
      featureId: featureId ?? this.featureId,
      path: path ?? this.path,
      type: type ?? this.type,
      baseUrl: baseUrl ?? this.baseUrl,
      userParams: userParams ?? this.userParams,
      parser: parser ?? this.parser,
    );
  }
}

class EndpointConfig {
  const EndpointConfig({
    this.globalUserParams,
    required this.endpoints,
  });

  final Map<String, String>? globalUserParams;
  final List<Endpoint> endpoints;

  T? getEndpoint<T>(BooruFeatureId featureId) {
    return endpoints
            .where((endpoint) => endpoint.featureId == featureId)
            .firstOrNull
        as T?;
  }

  String buildUrl({
    required BooruFeatureId featureId,
    required String baseUrl,
    required Map<String, String> userParams,
  }) {
    final endpoint = getEndpoint<Endpoint>(featureId);
    if (endpoint == null) {
      throw ArgumentError('Feature not supported: ${featureId.name}');
    }

    return endpoint.buildUrl(baseUrl, userParams);
  }

  T parseResponse<T>({
    required BooruFeatureId featureId,
    required Response response,
    required Map<String, dynamic> context,
  }) {
    final endpoint = getEndpoint<Endpoint<T>>(featureId);
    if (endpoint == null) {
      throw ArgumentError('Feature not supported: ${featureId.name}');
    }

    return endpoint.parseResponse(response, context);
  }

  EndpointConfig copyWith({
    Map<String, String>? globalUserParams,
    List<Endpoint>? endpoints,
  }) {
    return EndpointConfig(
      globalUserParams: globalUserParams ?? this.globalUserParams,
      endpoints: endpoints ?? this.endpoints,
    );
  }

  EndpointConfig withOverrides(Map<BooruFeatureId, Endpoint> overrides) {
    final updatedEndpoints = <Endpoint>[];

    for (final endpoint in endpoints) {
      final override = overrides[endpoint.featureId];
      if (override != null) {
        updatedEndpoints.add(override);
      } else {
        updatedEndpoints.add(
          endpoint.copyWith(
            userParams: {...?globalUserParams, ...endpoint.userParams},
          ),
        );
      }
    }

    overrides.forEach((featureId, override) {
      final exists = endpoints.any((e) => e.featureId == featureId);
      if (!exists) {
        updatedEndpoints.add(override);
      }
    });

    return EndpointConfig(
      globalUserParams: globalUserParams,
      endpoints: updatedEndpoints,
    );
  }
}
