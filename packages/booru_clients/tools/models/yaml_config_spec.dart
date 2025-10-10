class YamlConfigSpec {
  const YamlConfigSpec({
    required this.yamlName,
    required this.dartName,
    required this.protocol,
    required this.sites,
    required this.booruTypeMetadata,
    this.loginUrl,
    this.headers,
    this.globalUserParams,
    this.auth,
    this.features,
  });

  final String yamlName;
  final String dartName;
  final String protocol;
  final List<SiteSpec> sites;
  final Map<String, dynamic> booruTypeMetadata;
  final String? loginUrl;
  final Map<String, String>? headers;
  final Map<String, String>? globalUserParams;
  final Map<String, dynamic>? auth;
  final Map<String, dynamic>? features;
}

class SiteSpec {
  const SiteSpec({
    required this.url,
    required this.metadata,
  });

  final String url;
  final Map<String, dynamic> metadata;
}
