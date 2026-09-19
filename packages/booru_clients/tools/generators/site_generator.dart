import 'package:codegen/codegen.dart';
import '../models/booru_config.dart';
import 'feature_generator.dart';

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
          actions: feature.actions,
          sorting: feature.sorting,
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
          'hasFeature':
              override.capabilities?.isNotEmpty == true ||
              override.actions.isNotEmpty ||
              override.sorting != null,
          'featureConstructor': _buildFeatureConstructor(
            featureId,
            override.capabilities,
            actions: override.actions,
            sorting: override.sorting,
            indentLevel: 10, // Extra indentation for overrides
          ),
        };
      }).toList();

      return {
        'url': site.url,
        'hasOverrides': overrides.isNotEmpty,
        'overrides': overrides,
        'hasAuth': site.auth != null,
        'apiKeyUrl': site.auth?.apiKeyUrl ?? '',
        'instructionsKey': site.auth?.instructionsKey ?? '',
        'loginUrl': site.auth?.loginUrl ?? '',
        'required': site.auth?.required,
        'hasRequired': site.auth?.required != null,
        'cookie': site.auth?.cookie ?? '',
        'hasCookie': site.auth?.cookie != null,
        'isLast': index == config.sites.length - 1,
      };
    }).toList();

    return {
      'defaults': defaults,
      'sites': sites,
      'featureGetters': _generateFeatureGetters(config),
      'defaultAuth': config.defaultAuth != null
          ? {
              'apiKeyUrl': config.defaultAuth!.apiKeyUrl,
              'hasApiKeyUrl': config.defaultAuth!.apiKeyUrl != null,
              'instructionsKey': config.defaultAuth!.instructionsKey,
              'hasInstructionsKey': config.defaultAuth!.instructionsKey != null,
              'loginUrl': config.defaultAuth!.loginUrl,
              'hasLoginUrl': config.defaultAuth!.loginUrl != null,
              'required': config.defaultAuth!.required,
              'hasRequired': config.defaultAuth!.required != null,
              'cookie': config.defaultAuth!.cookie,
              'hasCookie': config.defaultAuth!.cookie != null,
            }
          : null,
    };
  }

  String generateOverrideClasses(BooruConfig config) {
    final classes = <String>{};

    for (final site in config.sites) {
      for (final featureId in site.overrides.keys) {
        final className = '${featureId.capitalize()}EndpointOverride';
        classes.add('''
class $className extends EndpointOverride {
  $className({
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
    Map<String, ActionConfig> actions = const {},
    SortingConfig? sorting,
    int indentLevel = 4,
  }) => FeatureGenerator().buildFeatureConstructor(
    featureId,
    capabilities,
    actions,
    sorting: sorting,
    indentLevel: indentLevel,
  );

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
}
