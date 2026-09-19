import 'package:yaml/yaml.dart';
import '../models/booru_config.dart';

class DataExtractor {
  static const _builtInSemanticParams = {
    'api-key',
    'comment-id',
    'cursor',
    'limit',
    'page',
    'post-id',
    'query',
    'tags',
    'user-id',
  };

  static BooruConfig? extractGelbooruV2Config(YamlList yamlData) {
    for (final entry in yamlData) {
      if (entry is YamlMap && entry.containsKey('gelbooru_v2')) {
        return _parseGelbooruV2Config(entry['gelbooru_v2']);
      }
    }
    return null;
  }

  static Set<String> extractAllParams(YamlList yamlData) {
    final allParams = <String>{};

    for (final entry in yamlData) {
      if (entry is YamlMap) {
        for (final booruConfig in entry.values) {
          if (booruConfig is YamlMap) {
            _extractParamsFromConfig(booruConfig, allParams);
          }
        }
      }
    }

    return allParams;
  }

  static Set<String> extractParserNames(YamlList yamlData) {
    final parsers = <String>{};

    for (final entry in yamlData) {
      if (entry is YamlMap && entry.containsKey('gelbooru_v2')) {
        _extractParsersFromConfig(entry['gelbooru_v2'], parsers);
      }
    }

    return parsers;
  }

  static void _extractParsersFromConfig(YamlMap config, Set<String> parsers) {
    final features = config['features'] as YamlMap?;
    features?.values.forEach((feature) {
      if (feature is YamlMap && feature['parser'] != null) {
        parsers.add(feature['parser']);
      }
    });

    final sites = config['sites'] as YamlList?;
    sites?.forEach((site) {
      if (site is YamlMap) {
        final overrides = site['overrides'] as YamlMap?;
        overrides?.values.forEach((override) {
          if (override is YamlMap && override['parser'] != null) {
            parsers.add(override['parser']);
          }
        });
      }
    });
  }

  static BooruConfig _parseGelbooruV2Config(YamlMap configMap) {
    final globalParams = _parseGlobalParams(configMap['global-user-params']);
    final features = _parseFeatures(configMap['features']);
    final defaultAuth = _parseAuthConfig(configMap['auth']);
    final sites = _parseSites(configMap['sites'], defaultAuth);
    _validateActionConfigs(
      features: features,
      sites: sites,
      knownParams: _knownParams(configMap),
    );

    return BooruConfig(
      name: 'gelbooru_v2',
      globalUserParams: globalParams,
      features: features,
      sites: sites,
      defaultAuth: defaultAuth,
    );
  }

  static Map<String, String> _parseGlobalParams(dynamic params) {
    if (params == null) return {};

    return Map<String, String>.from(params as YamlMap);
  }

  static Map<String, FeatureConfig> _parseFeatures(dynamic features) {
    if (features == null) return {};

    final featuresMap = features as YamlMap;
    final result = <String, FeatureConfig>{};

    for (final entry in featuresMap.entries) {
      final featureId = entry.key as String;
      final config = entry.value as YamlMap;

      result[featureId] = FeatureConfig(
        type: config['type'] ?? 'api',
        endpoint: config['endpoint'] ?? '',
        parser: config['parser'],
        userParams: Map<String, String>.from(config['user-params'] ?? {}),
        actions: _parseActions(config['actions'], 'feature "$featureId"'),
        sorting: _parseSorting(config['sorting'], 'feature "$featureId"'),
        capabilities: _parseTypedCapabilities(config['capabilities']),
      );
    }

    return result;
  }

  static List<CapabilityField>? _parseTypedCapabilities(dynamic capabilities) {
    if (capabilities == null) return null;
    if (capabilities is YamlMap && capabilities.isEmpty) return null;

    final capMap = capabilities as YamlMap;
    return capMap.entries.map((entry) {
      final key = entry.key as String;
      final value = entry.value;

      return CapabilityField(
        name: key,
        type: _dartTypeFromYamlValue(value),
        value: value,
      );
    }).toList();
  }

  static String _dartTypeFromYamlValue(dynamic value) {
    return switch (value.runtimeType) {
      const (bool) => 'bool',
      const (int) => 'int',
      const (double) => 'double',
      const (String) => 'String',
      const (YamlList) => 'List<dynamic>',
      const (YamlMap) => 'Map<String, dynamic>',
      _ => 'dynamic',
    };
  }

  static List<SiteConfig> _parseSites(dynamic sites, AuthConfig? defaultAuth) {
    if (sites == null) return [];

    final sitesList = sites as YamlList;
    final result = <SiteConfig>[];

    for (final site in sitesList) {
      if (site is YamlMap) {
        final url = site['url'] as String;
        final overrides = _parseOverrides(site['overrides']);
        final siteAuth = _parseAuthConfig(site['auth']);
        final mergedAuth = _mergeAuthConfig(defaultAuth, siteAuth, url);

        result.add(
          SiteConfig(
            url: url,
            overrides: overrides,
            auth: mergedAuth,
          ),
        );
      }
    }

    return result;
  }

  static AuthConfig? _parseAuthConfig(dynamic auth) {
    if (auth == null) return null;

    final authMap = auth as YamlMap;
    return AuthConfig(
      apiKeyUrl: authMap['api-key-url'] as String?,
      instructionsKey: authMap['instructions-key'] as String?,
      loginUrl: authMap['login-url'] as String?,
      required: authMap['required'] as bool?,
      cookie: authMap['cookie'] as String?,
    );
  }

  static AuthConfig? _mergeAuthConfig(
    AuthConfig? defaultAuth,
    AuthConfig? siteAuth,
    String siteUrl,
  ) {
    if (defaultAuth == null && siteAuth == null) return null;

    // If no default auth, just return site auth
    if (defaultAuth == null) return siteAuth;

    // If no site auth, merge default auth with site URL
    if (siteAuth == null) {
      return AuthConfig(
        apiKeyUrl: _resolveUrl(defaultAuth.apiKeyUrl, siteUrl),
        instructionsKey: defaultAuth.instructionsKey,
        loginUrl: _resolveUrl(defaultAuth.loginUrl, siteUrl),
        required: defaultAuth.required,
        cookie: defaultAuth.cookie,
      );
    }

    // Merge both, with site auth taking precedence
    return AuthConfig(
      apiKeyUrl:
          siteAuth.apiKeyUrl ?? _resolveUrl(defaultAuth.apiKeyUrl, siteUrl),
      instructionsKey: siteAuth.instructionsKey ?? defaultAuth.instructionsKey,
      loginUrl: siteAuth.loginUrl ?? _resolveUrl(defaultAuth.loginUrl, siteUrl),
      required: siteAuth.required ?? defaultAuth.required,
      cookie: siteAuth.cookie ?? defaultAuth.cookie,
    );
  }

  static String? _resolveUrl(String? urlOrPath, String siteUrl) {
    if (urlOrPath == null) return null;

    // If it's already a full URL, return as is
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return urlOrPath;
    }

    // If it's a relative path, join with site URL
    final baseUrl = Uri.parse(siteUrl);
    final resolvedUri = baseUrl.resolve(urlOrPath);
    return resolvedUri.toString();
  }

  static Map<String, OverrideConfig> _parseOverrides(dynamic overrides) {
    if (overrides == null) return {};

    final overridesMap = overrides as YamlMap;
    final result = <String, OverrideConfig>{};

    for (final entry in overridesMap.entries) {
      final featureId = entry.key as String;
      final config = entry.value as YamlMap;

      result[featureId] = OverrideConfig(
        type: config['type'],
        endpoint: config['endpoint'],
        parser: config['parser'],
        userParams: config['user-params'] != null
            ? Map<String, String>.from(config['user-params'])
            : null,
        actions: _parseActions(config['actions'], 'override "$featureId"'),
        sorting: _parseSorting(config['sorting'], 'override "$featureId"'),
        capabilities: _parseTypedCapabilities(config['capabilities']),
      );
    }

    return result;
  }

  static void _extractParamsFromConfig(YamlMap config, Set<String> allParams) {
    // Extract global user params
    final globalParams = config['global-user-params'] as YamlMap?;
    if (globalParams != null) {
      allParams.addAll(globalParams.keys.cast<String>());
    }

    // Extract feature user params
    final features = config['features'] as YamlMap?;
    if (features != null) {
      for (final feature in features.values) {
        if (feature is YamlMap) {
          final userParams = feature['user-params'] as YamlMap?;
          if (userParams != null) {
            allParams.addAll(userParams.keys.cast<String>());
          }
          _extractActionParams(feature['actions'], allParams);
        }
      }
    }

    // Extract site override params
    final sites = config['sites'] as YamlList?;
    if (sites != null) {
      for (final site in sites) {
        if (site is YamlMap) {
          final overrides = site['overrides'] as YamlMap?;
          if (overrides != null) {
            for (final override in overrides.values) {
              if (override is YamlMap) {
                final userParams = override['user-params'] as YamlMap?;
                if (userParams != null) {
                  allParams.addAll(userParams.keys.cast<String>());
                }
                _extractActionParams(override['actions'], allParams);
              }
            }
          }
        }
      }
    }
  }

  static Map<String, ActionConfig> _parseActions(
    dynamic actions,
    String location,
  ) {
    if (actions == null) return {};
    if (actions is! YamlMap) {
      throw FormatException('$location actions must be a map');
    }

    final result = <String, ActionConfig>{};
    for (final entry in actions.entries) {
      final actionName = entry.key;
      if (actionName is! String || actionName.trim().isEmpty) {
        throw FormatException(
          '$location contains an action with an empty name',
        );
      }
      if (entry.value is! YamlMap) {
        throw FormatException(
          '$location action "$actionName" must be a map',
        );
      }

      final config = entry.value as YamlMap;
      result[actionName] = ActionConfig(
        name: actionName,
        method: config['method']?.toString() ?? '',
        endpoint: config['endpoint']?.toString() ?? '',
        baseUrl: config['base-url']?.toString(),
        auth: config['auth']?.toString() ?? '',
        response: config['response']?.toString() ?? '',
        fixedParams: _parseStringMap(
          config['params'],
          '$location action "$actionName" params',
        ),
        userParams: _parseStringMap(
          config['user-params'],
          '$location action "$actionName" user-params',
        ),
        requiredParams: _parseStringSet(
          config['required-user-params'],
          '$location action "$actionName" required-user-params',
        ),
      );
    }

    return result;
  }

  static SortingConfig? _parseSorting(dynamic value, String location) {
    if (value == null) return null;
    if (value is! YamlMap) {
      throw FormatException('$location sorting must be a map');
    }

    final transport = value['transport'];
    final key = value['key'];
    final defaultOrder = value['default'];
    final values = _parseStringMap(
      value['values'],
      '$location sorting values',
    );

    const transports = {'cookie', 'query-parameter'};
    if (transport is! String || !transports.contains(transport)) {
      throw FormatException(
        '$location sorting has unsupported transport "$transport"',
      );
    }
    if (key is! String || key.trim().isEmpty) {
      throw FormatException('$location sorting must have a non-empty key');
    }
    if (defaultOrder is! String || !values.containsKey(defaultOrder)) {
      throw FormatException(
        '$location sorting default must reference one of its values',
      );
    }
    if (values.isEmpty) {
      throw FormatException('$location sorting must define values');
    }
    if (transport == 'cookie' &&
        (key.contains(RegExp(r'[;\r\n]')) ||
            values.values.any((entry) => entry.contains(RegExp(r'[;\r\n]'))))) {
      throw FormatException(
        '$location sorting contains an invalid cookie key or value',
      );
    }

    return SortingConfig(
      transport: transport,
      key: key,
      defaultOrder: defaultOrder,
      values: values,
    );
  }

  static Map<String, String> _parseStringMap(dynamic value, String location) {
    if (value == null) return {};
    if (value is! YamlMap) {
      throw FormatException('$location must be a map');
    }

    final result = <String, String>{};
    for (final entry in value.entries) {
      final key = entry.key;
      final entryValue = entry.value;
      if (key is! String || key.isEmpty) {
        throw FormatException('$location contains an empty key');
      }
      if (entryValue is! String) {
        throw FormatException('$location values must be strings');
      }
      result[key] = entryValue;
    }

    return result;
  }

  static Set<String> _parseStringSet(dynamic value, String location) {
    if (value == null) {
      throw FormatException('$location is required');
    }
    if (value is! YamlList) {
      throw FormatException('$location must be a list');
    }

    final result = <String>{};
    for (final entry in value) {
      if (entry is! String || entry.isEmpty) {
        throw FormatException('$location must contain non-empty strings');
      }
      result.add(entry);
    }

    return result;
  }

  static Set<String> _knownParams(YamlMap config) {
    final knownParams = <String>{
      ..._builtInSemanticParams,
      ..._parseGlobalParams(config['global-user-params']).keys,
    };

    void addFeatureParams(dynamic features) {
      if (features is! YamlMap) return;
      for (final feature in features.values) {
        if (feature is YamlMap && feature['user-params'] is YamlMap) {
          knownParams.addAll(
            (feature['user-params'] as YamlMap).keys.cast<String>(),
          );
        }
      }
    }

    addFeatureParams(config['features']);

    final sites = config['sites'];
    if (sites is YamlList) {
      for (final site in sites) {
        if (site is! YamlMap || site['overrides'] is! YamlMap) continue;
        final overrides = site['overrides'] as YamlMap;
        addFeatureParams(overrides);
      }
    }

    return knownParams;
  }

  static void _validateActionConfigs({
    required Map<String, FeatureConfig> features,
    required List<SiteConfig> sites,
    required Set<String> knownParams,
  }) {
    for (final entry in features.entries) {
      _validateActions(
        entry.value.actions,
        'feature "${entry.key}"',
        knownParams,
      );
    }
    for (final site in sites) {
      for (final entry in site.overrides.entries) {
        _validateActions(
          entry.value.actions,
          'site "${site.url}" override "${entry.key}"',
          knownParams,
        );
      }
    }
  }

  static void _validateActions(
    Map<String, ActionConfig> actions,
    String location,
    Set<String> knownParams,
  ) {
    final names = <String>{};
    const methods = {'get', 'post'};
    const authModes = {'none', 'session-cookie'};
    const responseTypes = {'empty', 'integer', 'text', 'json'};

    for (final entry in actions.entries) {
      final action = entry.value;
      if (!names.add(action.name) || action.name.trim().isEmpty) {
        throw FormatException(
          '$location contains a duplicate or empty action name',
        );
      }
      if (!methods.contains(action.method)) {
        throw FormatException(
          '$location action "${action.name}" has unsupported method "${action.method}"',
        );
      }
      if (action.endpoint.trim().isEmpty) {
        throw FormatException(
          '$location action "${action.name}" must have a non-empty endpoint',
        );
      }
      if (!authModes.contains(action.auth)) {
        throw FormatException(
          '$location action "${action.name}" has unsupported auth mode "${action.auth}"',
        );
      }
      if (!responseTypes.contains(action.response)) {
        throw FormatException(
          '$location action "${action.name}" has unsupported response type "${action.response}"',
        );
      }

      final mappedWireParams = <String>{};
      for (final entry in action.userParams.entries) {
        final semanticName = entry.key;
        final wireName = entry.value;
        if (!knownParams.contains(semanticName)) {
          throw FormatException(
            '$location action "${action.name}" uses unknown semantic parameter "$semanticName"',
          );
        }
        if (wireName.isEmpty || !mappedWireParams.add(wireName)) {
          throw FormatException(
            '$location action "${action.name}" maps multiple inputs to wire parameter "$wireName"',
          );
        }
      }
      for (final semanticName in action.requiredParams) {
        if (!knownParams.contains(semanticName)) {
          throw FormatException(
            '$location action "${action.name}" uses unknown required semantic parameter "$semanticName"',
          );
        }
        final wireName = action.userParams[semanticName];
        if (wireName == null || wireName.isEmpty) {
          throw FormatException(
            '$location action "${action.name}" is missing a mapping for required semantic parameter "$semanticName"',
          );
        }
      }
      for (final key in action.fixedParams.keys) {
        if (key.isEmpty) {
          throw FormatException(
            '$location action "${action.name}" contains an empty fixed parameter name',
          );
        }
      }
    }
  }

  static void _extractActionParams(dynamic actions, Set<String> allParams) {
    if (actions is! YamlMap) return;
    for (final action in actions.values) {
      if (action is YamlMap && action['user-params'] is YamlMap) {
        allParams.addAll(
          (action['user-params'] as YamlMap).keys.cast<String>(),
        );
      }
    }
  }
}
