class BooruConfig {
  const BooruConfig({
    required this.name,
    required this.globalUserParams,
    required this.features,
    required this.sites,
    this.defaultAuth,
  });

  final String name;
  final Map<String, String> globalUserParams;
  final Map<String, FeatureConfig> features;
  final List<SiteConfig> sites;
  final AuthConfig? defaultAuth;
}

class FeatureConfig {
  const FeatureConfig({
    required this.type,
    required this.endpoint,
    this.parser,
    required this.userParams,
    this.actions = const {},
    this.capabilities,
  });

  final String type;
  final String endpoint;
  final String? parser;
  final Map<String, String> userParams;
  final Map<String, ActionConfig> actions;
  final List<CapabilityField>? capabilities;
}

class ActionConfig {
  const ActionConfig({
    required this.name,
    required this.method,
    required this.endpoint,
    this.baseUrl,
    required this.auth,
    required this.response,
    required this.fixedParams,
    required this.userParams,
    required this.requiredParams,
  });

  final String name;
  final String method;
  final String endpoint;
  final String? baseUrl;
  final String auth;
  final String response;
  final Map<String, String> fixedParams;
  final Map<String, String> userParams;
  final Set<String> requiredParams;
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
    this.loginUrl,
    this.required,
    this.cookie,
  });

  final String? apiKeyUrl;
  final String? instructionsKey;
  final String? loginUrl;
  final bool? required;
  final String? cookie;
}

class OverrideConfig {
  const OverrideConfig({
    this.type,
    this.endpoint,
    this.parser,
    this.userParams,
    this.actions = const {},
    this.capabilities,
  });

  final String? type;
  final String? endpoint;
  final String? parser;
  final Map<String, String>? userParams;
  final Map<String, ActionConfig> actions;
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
