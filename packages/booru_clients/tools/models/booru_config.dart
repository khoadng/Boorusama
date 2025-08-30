class BooruConfig {
  const BooruConfig({
    required this.name,
    required this.globalUserParams,
    required this.features,
    required this.sites,
  });

  final String name;
  final Map<String, String> globalUserParams;
  final Map<String, FeatureConfig> features;
  final List<SiteConfig> sites;
}

class FeatureConfig {
  const FeatureConfig({
    required this.type,
    required this.endpoint,
    this.parser,
    required this.userParams,
    this.capabilities,
  });

  final String type;
  final String endpoint;
  final String? parser;
  final Map<String, String> userParams;
  final List<CapabilityField>? capabilities;
}

class SiteConfig {
  const SiteConfig({
    required this.url,
    required this.overrides,
    this.auth,
  });

  final String url;
  final Map<String, OverrideConfig> overrides;
  final AuthConfig? auth;
}

class AuthConfig {
  const AuthConfig({
    this.apiKeyUrl,
    this.instructionsKey,
  });

  final String? apiKeyUrl;
  final String? instructionsKey;
}

class OverrideConfig {
  const OverrideConfig({
    this.type,
    this.endpoint,
    this.parser,
    this.userParams,
    this.capabilities,
  });

  final String? type;
  final String? endpoint;
  final String? parser;
  final Map<String, String>? userParams;
  final List<CapabilityField>? capabilities;
}

class CapabilityField {
  const CapabilityField({
    required this.name,
    required this.type,
    required this.value,
  });

  final String name;
  final String type;
  final dynamic value;
}

class GenerationContext {
  const GenerationContext({
    required this.config,
    required this.allParams,
    required this.featureIds,
  });

  final BooruConfig config;
  final Set<String> allParams;
  final List<String> featureIds;
}
