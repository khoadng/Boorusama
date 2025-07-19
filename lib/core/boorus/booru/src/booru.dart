// Package imports:
import 'package:booru_clients/core.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../http/http.dart';
import 'booru_type.dart';
import 'feature_registry.dart';

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
    required this.siteCapabilities,
    required this.featureRegistry,
    required this.globalUserParams,
  });

  final Map<String, SiteCapabilities> siteCapabilities;
  final Map<String, String> globalUserParams;
  final BooruFeatureRegistry featureRegistry;

  SiteCapabilities? getCapabilitiesForSite(String siteUrl) {
    return siteCapabilities[siteUrl];
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
    capabilities.featureEndpoints.forEach((featureId, featureEndpoint) {
      final baseEndpoint = baseConfig.getEndpoint<Endpoint>(featureId);
      if (baseEndpoint != null) {
        final parser = featureEndpoint.parserStrategy != null
            ? parserResolver(featureEndpoint.parserStrategy) ??
                  baseEndpoint.parser
            : baseEndpoint.parser;

        endpointOverrides[featureId] = Endpoint.fromFeature(
          feature: featureEndpoint,
          parser: parser,
        );
      }
    });

    return baseConfig.withOverrides(endpointOverrides);
  }

  bool hasFeature(BooruFeatureId featureId) =>
      featureRegistry.hasFeature(featureId);

  T? getFeature<T extends BooruFeature>(BooruFeatureId featureId) =>
      featureRegistry.get<T>(featureId);
}
