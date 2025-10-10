// Package imports:
import 'package:booru_clients/core.dart';
import 'package:booru_clients/generated.dart';
import 'package:equatable/equatable.dart';

abstract class Booru extends Equatable {
  const Booru({
    required this.config,
  });

  final BooruYamlConfig config;

  BooruType get type => config.type;

  int get id => type.id;

  Map<String, dynamic>? get headers => config.headers;

  NetworkProtocol? getSiteProtocol(String url) => config.protocol;

  String? getLoginUrl() => config.loginUrl;

  bool hasSite(String url) => config.sites.any((site) => url == site.url);
  @override
  List<Object?> get props => [config.type.id];
}

abstract class FeatureAwareBooru extends Booru {
  const FeatureAwareBooru({
    required super.config,
    required this.globalUserParams,
  });

  final Map<String, String> globalUserParams;

  SiteCapabilities? getCapabilitiesForSite(String siteUrl) {
    return BooruConfigRegistry.getSiteCapabilities(type.yamlName, siteUrl);
  }

  Map<String, String> getGlobalUserParams() => globalUserParams;

  EndpointConfig buildClientConfig({
    required EndpointConfig baseConfig,
    required String siteUrl,
    required ResponseParser? Function(String?) parserResolver,
  }) {
    final capabilities = getCapabilitiesForSite(siteUrl);
    if (capabilities == null) {
      return baseConfig;
    }

    final endpointOverrides = <BooruFeatureId, Endpoint>{};

    capabilities.overrides.forEach((featureId, override) {
      final baseEndpoint = baseConfig.getEndpoint(featureId);
      if (baseEndpoint == null) return;

      ResponseParser? parser = baseEndpoint.parser;
      if (override.parserStrategy != null) {
        parser = parserResolver(override.parserStrategy) ?? parser;
      }

      endpointOverrides[featureId] = baseEndpoint.copyWith(
        parser: parser,
        path: override.path,
        baseUrl: override.baseUrl,
        userParams: override.paramMapping,
        type: override.type,
      );
    });

    return baseConfig.withOverrides(endpointOverrides);
  }
}

class BooruScaffold extends Booru {
  const BooruScaffold({
    required super.config,
  });
}
