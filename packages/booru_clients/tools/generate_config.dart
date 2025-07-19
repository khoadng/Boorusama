import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  final yamlFile = File('../../boorus.yaml');
  if (!yamlFile.existsSync()) {
    print('boorus.yaml not found');
    return;
  }

  final yamlContent = await yamlFile.readAsString();
  final yamlData = loadYaml(yamlContent) as YamlList;

  dynamic gelbooruV2Config;
  for (final entry in yamlData) {
    if (entry is YamlMap && entry.containsKey('gelbooru_v2')) {
      gelbooruV2Config = entry['gelbooru_v2'];
      break;
    }
  }

  if (gelbooruV2Config == null) {
    print('gelbooru_v2 config not found');
    return;
  }

  final generated = _buildConfigClass(gelbooruV2Config);

  final outputFile = File('lib/src/generated/booru_config.dart');
  await outputFile.create(recursive: true);
  await outputFile.writeAsString(generated);

  print('Generated booru_config.dart');
}

String _buildConfigClass(dynamic config) {
  final configMap = config as YamlMap;
  final endpoints = <String, String>{};
  final overrideEndpoints = <String, String>{};

  // Extract feature IDs from YAML
  final featureIds = <String>[];
  final defaultFeatures = configMap['features'] as YamlMap?;
  if (defaultFeatures != null) {
    featureIds.addAll(defaultFeatures.keys.cast<String>());
  }

  // Generate default endpoint constants
  if (defaultFeatures != null) {
    for (final entry in defaultFeatures.entries) {
      final featureId = entry.key as String;
      final constName = '_${featureId}Endpoint';
      endpoints[constName] = _buildFeatureEndpointDefinition(
        featureId,
        entry.value,
      );
    }
  }

  // Generate override endpoint constants
  final sites = configMap['sites'] as YamlList?;
  if (sites != null) {
    for (final site in sites) {
      if (site is YamlMap && site['overrides'] != null) {
        final siteUrl = site['url'] as String;
        final siteName = _getSiteName(siteUrl);
        final overrides = site['overrides'] as YamlMap;

        for (final entry in overrides.entries) {
          final featureId = entry.key as String;
          final constName = '_$siteName${featureId.capitalize()}Endpoint';
          overrideEndpoints[constName] = _buildFeatureEndpointDefinition(
            featureId,
            entry.value,
          );
        }
      }
    }
  }

  final featureIdEnum = _buildFeatureIdEnum(featureIds);
  final featureClasses = _buildFeatureClasses(featureIds);
  final globalParams = _buildGlobalParams(configMap['global-user-params']);
  final defaultFeaturesMap = _buildDefaultFeaturesMap(defaultFeatures);
  final siteCapabilities = _buildSiteCapabilitiesMap(
    configMap['features'],
    configMap['sites'],
  );
  final featureMethods = _buildFeatureMethods(featureIds);
  final sitesList = _buildSitesList(configMap['sites']);

  return '''
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:equatable/equatable.dart';

$featureIdEnum

$featureClasses

enum EndpointType {
  api('api'),
  html('html');

  const EndpointType(this.name);
  final String name;

  static EndpointType fromString(String? typeStr) {
    for (final type in values) {
      if (type.name == typeStr) return type;
    }
    return EndpointType.api;
  }
}

class FeatureEndpoint {
  const FeatureEndpoint({
    required this.featureId,
    required this.type,
    required this.path,
    this.baseUrl,
    this.parserStrategy,
    this.paramMapping = const {},
    this.additionalConfig = const {},
  });

  final BooruFeatureId featureId;
  final EndpointType type;
  final String path;
  final String? baseUrl;
  final String? parserStrategy;
  final Map<String, String> paramMapping;
  final Map<String, dynamic> additionalConfig;
}

class SiteCapabilities {
  const SiteCapabilities({
    required this.siteUrl,
    required this.featureEndpoints,
  });

  final String siteUrl;
  final Map<BooruFeatureId, FeatureEndpoint> featureEndpoints;

  FeatureEndpoint? getEndpoint(BooruFeatureId featureId) {
    return featureEndpoints[featureId];
  }

  bool hasFeature(BooruFeatureId featureId) {
    return featureEndpoints.containsKey(featureId);
  }
}

class GelbooruV2Config {
${endpoints.entries.map((e) => '  static const ${e.key} = ${e.value};').join('\n')}

${overrideEndpoints.entries.map((e) => '  static const ${e.key} = ${e.value};').join('\n')}

  static const globalUserParams = $globalParams;
  
  static const sites = $sitesList;
  
  static const defaultFeatures = $defaultFeaturesMap;
  
  static const siteCapabilities = $siteCapabilities;

$featureMethods
}
''';
}

String _buildFeatureIdEnum(List<String> featureIds) {
  final enumValues = featureIds.map((id) => "$id('$id')").join(',\n  ');

  return '''enum BooruFeatureId {
  $enumValues;

  const BooruFeatureId(this.name);
  final String name;

  static BooruFeatureId? fromName(String name) {
    for (final feature in values) {
      if (feature.name == name) return feature;
    }
    return null;
  }
}''';
}

String _buildFeatureClasses(List<String> featureIds) {
  final classes = featureIds
      .map((id) {
        final className = '${id.capitalize()}Feature';
        return '''class $className extends BooruFeature {
  const $className() : super(BooruFeatureId.$id);
}''';
      })
      .join('\n\n');

  return '''abstract class BooruFeature extends Equatable {
  const BooruFeature(this.id);
  final BooruFeatureId id;

  @override
  List<Object?> get props => [id];
}

$classes''';
}

String _buildFeatureMethods(List<String> featureIds) {
  final switchCases = featureIds
      .map(
        (id) => '    BooruFeatureId.$id => const ${id.capitalize()}Feature(),',
      )
      .join('\n');

  return '''  static BooruFeature? createFeature(BooruFeatureId id) => switch (id) {
$switchCases
  };

  static List<BooruFeature> createAllFeatures() => 
      defaultFeatures.keys.map(createFeature).whereType<BooruFeature>().toList();''';
}

String _buildSitesList(dynamic sites) {
  if (sites == null) return '<String>[]';

  final siteUrls = <String>[];
  for (final site in (sites as YamlList)) {
    if (site is YamlMap) {
      final url = site['url'] as String?;
      if (url != null) siteUrls.add("'$url'");
    } else if (site is String) {
      siteUrls.add("'$site'");
    }
  }

  return '<String>[${siteUrls.join(', ')}]';
}

String _buildFeatureEndpointDefinition(String featureId, dynamic config) {
  final configMap = config as YamlMap;
  final type = configMap['type'] ?? 'api';
  final path = configMap['endpoint'];
  final parser = configMap['parser'];
  final userParams = configMap['user-params'];

  final parserLine = parser != null ? '\n    parserStrategy: \'$parser\',' : '';
  final paramMap = userParams != null
      ? (userParams as YamlMap).entries
            .map((e) => '\'${e.key}\': \'${e.value}\'')
            .join(', ')
      : '';

  return '''FeatureEndpoint(
    featureId: BooruFeatureId.$featureId,
    type: EndpointType.$type,
    path: '$path',$parserLine
    paramMapping: {$paramMap},
  )''';
}

String _buildGlobalParams(dynamic params) {
  if (params == null) return '<String, String>{}';

  final entries = (params as YamlMap).entries
      .map((e) => '\'${e.key}\': \'${e.value}\'')
      .join(', ');

  return '<String, String>{$entries}';
}

String _buildDefaultFeaturesMap(dynamic features) {
  if (features == null) return '<BooruFeatureId, FeatureEndpoint>{}';

  final entries = (features as YamlMap).entries
      .map((e) {
        final featureId = e.key as String;
        return 'BooruFeatureId.$featureId: _${featureId}Endpoint';
      })
      .join(',\n    ');

  return '<BooruFeatureId, FeatureEndpoint>{\n    $entries,\n  }';
}

String _buildSiteCapabilitiesMap(dynamic defaultFeatures, dynamic sites) {
  if (sites == null) return '<String, SiteCapabilities>{}';

  final capabilities = <String>[];

  for (final site in (sites as YamlList)) {
    if (site is YamlMap) {
      final url = site['url'] as String;
      final siteName = _getSiteName(url);
      final overrides = site['overrides'] as YamlMap?;

      final features = <String>[];

      // Add default features
      if (defaultFeatures != null) {
        for (final entry in (defaultFeatures as YamlMap).entries) {
          final featureId = entry.key as String;
          final isOverridden = overrides?.containsKey(entry.key) == true;
          if (isOverridden) {
            features.add(
              'BooruFeatureId.$featureId: _$siteName${featureId.capitalize()}Endpoint',
            );
          } else {
            features.add('BooruFeatureId.$featureId: _${featureId}Endpoint');
          }
        }
      }

      capabilities.add('''    '$url': SiteCapabilities(
      siteUrl: '$url',
      featureEndpoints: {
        ${features.join(',\n        ')},
      },
    )''');
    }
  }

  return '<String, SiteCapabilities>{\n${capabilities.join(',\n')},\n  }';
}

String _getSiteName(String url) {
  return url
      .replaceAll(RegExp(r'https?://'), '')
      .replaceAll(RegExp(r'[./]'), '')
      .replaceAll('-', '');
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
