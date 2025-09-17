import 'package:codegen/codegen.dart';
import '../models/booru_config.dart';

class FeatureGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'features.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    return _buildContextWithOverrides(config, '', '');
  }

  String generateWithOverrides(
    BooruConfig config,
    String overrideClasses,
    String featureGetters,
  ) {
    final template = TemplateManager().loadTemplate(templateName);
    final context = _buildContextWithOverrides(
      config,
      overrideClasses,
      featureGetters,
    );
    return TemplateManager().render(template, context);
  }

  Map<String, dynamic> _buildContextWithOverrides(
    BooruConfig config,
    String overrideClasses,
    String featureGetters,
  ) {
    final featureClasses = config.features.entries.map((entry) {
      final featureId = entry.key;
      final feature = entry.value;
      final capabilities = feature.capabilities ?? [];

      return {
        'className': '${featureId.capitalize()}Feature',
        'featureId': featureId,
        'endpointType': feature.type,
        'hasCapabilities': capabilities.isNotEmpty,
        'capabilities': capabilities
            .map(
              (cap) => {
                'name': kebabToCamel(cap.name),
                'type': cap.type,
                'isLast': cap == capabilities.last,
              },
            )
            .toList(),
      };
    }).toList();

    return {
      'featureClasses': featureClasses,
      'overrideClasses': overrideClasses,
      'featureGetters': featureGetters,
    };
  }

  String generateRegistry(BooruConfig config) {
    // Only generate switch cases for features that have overrides
    final featuresWithOverrides = <String>{};
    for (final site in config.sites) {
      featuresWithOverrides.addAll(site.overrides.keys);
    }

    final switchCases = featuresWithOverrides
        .map((featureId) {
          final className = '${featureId.capitalize()}Feature';
          return "      $className _ => capabilities.$featureId,";
        })
        .join('\n');

    return '''class BooruConfigRegistry {
  static T? getFeature<T extends BooruFeature>(String booruType, String siteUrl) {
    final capabilities = getSiteCapabilities(booruType, siteUrl);
    if (capabilities == null) return null;
    
    return switch (T) {
$switchCases
      _ => null,
    } as T?;
  }
  
  static SiteCapabilities? getSiteCapabilities(String booruType, String url) {
    return switch (booruType) {
      'gelbooru_v2' => GelbooruV2Config.siteCapabilities(url),
      _ => null,
    };
  }
}''';
  }
}
