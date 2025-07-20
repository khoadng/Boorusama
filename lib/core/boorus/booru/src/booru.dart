// Package imports:
import 'package:booru_clients/core.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../http/http.dart';
import 'booru_type.dart';

abstract class Booru extends Equatable {
  const Booru({
    required this.name,
    required this.protocol,
  });

  final String name;
  final NetworkProtocol protocol;

  Iterable<String> get sites;

  BooruType get type;

  int get id => type.id;

  NetworkProtocol? getSiteProtocol(String url) => protocol;

  String? getLoginUrl() => null;

  bool hasSite(String url) => sites.any((site) => url == site);
  @override
  List<Object?> get props => [name];
}

mixin PassHashAuthMixin {
  String? get loginUrl;
}

abstract class FeatureAwareBooru extends Booru {
  const FeatureAwareBooru({
    required super.name,
    required super.protocol,
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
