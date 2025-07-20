import '../utils/template_utils.dart';
import '../utils/string_utils.dart';
import 'generator.dart';
import '../models/booru_config.dart';

class SiteGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'site_capabilities.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    final defaults = config.features.entries.map((featureEntry) {
      final featureId = featureEntry.key;
      final feature = featureEntry.value;

      return {
        'featureId': featureId,
        'featureConstructor': _buildFeatureConstructor(
          featureId,
          feature.capabilities,
        ),
      };
    }).toList();

    final sites = config.sites.asMap().entries.map((entry) {
      final index = entry.key;
      final site = entry.value;

      final overrides = site.overrides.entries.map((overrideEntry) {
        final featureId = overrideEntry.key;
        final override = overrideEntry.value;

        return {
          'featureId': featureId,
          'overrideClassName': '${featureId.capitalize()}EndpointOverride',
          'hasType': override.type != null,
          'type': override.type ?? '',
          'hasPath': override.endpoint != null,
          'path': override.endpoint ?? '',
          'hasParser': override.parser != null,
          'parser': override.parser ?? '',
          'hasParams': override.userParams?.isNotEmpty == true,
          'paramMapping': TemplateUtils.buildParamMapping(
            override.userParams ?? {},
          ),
          'hasFeature': override.capabilities?.isNotEmpty == true,
          'featureConstructor': _buildFeatureConstructor(
            featureId,
            override.capabilities,
            indentLevel: 10, // Extra indentation for overrides
          ),
        };
      }).toList();

      return {
        'url': site.url,
        'hasOverrides': overrides.isNotEmpty,
        'overrides': overrides,
        'isLast': index == config.sites.length - 1,
      };
    }).toList();

    return {
      'defaults': defaults,
      'sites': sites,
      'featureGetters': _generateFeatureGetters(config),
    };
  }

  String generateOverrideClasses(BooruConfig config) {
    final classes = <String>{};

    for (final site in config.sites) {
      for (final featureId in site.overrides.keys) {
        final className = '${featureId.capitalize()}EndpointOverride';
        classes.add('''
class $className extends EndpointOverride {
  const $className({
    super.parserStrategy,
    super.path,
    super.baseUrl,
    super.paramMapping,
    super.type,
    this.feature,
  });

  final ${featureId.capitalize()}Feature? feature;
}''');
      }
    }

    return classes.join('\n\n');
  }

  String _buildFeatureConstructor(
    String featureId,
    List<CapabilityField>? capabilities, {
    int indentLevel = 4,
  }) {
    if (capabilities == null || capabilities.isEmpty) {
      return '${featureId.capitalize()}Feature()';
    }

    final baseIndent = ' ' * indentLevel;
    final paramIndent = ' ' * (indentLevel + 2);

    if (capabilities.length == 1) {
      final cap = capabilities.first;
      return '''${featureId.capitalize()}Feature(
$paramIndent${kebabToCamel(cap.name)}: ${_formatDartValue(cap.value)},
$baseIndent)''';
    }

    final params = capabilities
        .map(
          (cap) =>
              '$paramIndent${kebabToCamel(cap.name)}: ${_formatDartValue(cap.value)},',
        )
        .join('\n');

    return '''${featureId.capitalize()}Feature(
$params
$baseIndent)''';
  }

  String _generateFeatureGetters(BooruConfig config) {
    final featuresWithOverrides = <String>{};

    // Only include features that have overrides in at least one site
    for (final site in config.sites) {
      featuresWithOverrides.addAll(site.overrides.keys);
    }

    final getters = featuresWithOverrides
        .map((featureId) {
          return '''  ${featureId.capitalize()}Feature? get $featureId {
    final override = overrides[BooruFeatureId.$featureId] as ${featureId.capitalize()}EndpointOverride?;
    if (override?.feature != null) return override!.feature;
    return GelbooruV2Config._defaults[BooruFeatureId.$featureId] as ${featureId.capitalize()}Feature?;
  }''';
        })
        .join('\n\n');

    return getters;
  }

  String _formatDartValue(dynamic value) {
    return switch (value.runtimeType) {
      const (bool) || const (int) || const (double) => value.toString(),
      const (String) => "'$value'",
      _ => "'$value'",
    };
  }
}
