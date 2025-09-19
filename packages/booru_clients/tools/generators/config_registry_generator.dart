import 'package:codegen/codegen.dart';
import '../models/booru_config.dart';

class ConfigRegistryGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'config_registry.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    // Only generate switch cases for features that have overrides
    final featuresWithOverrides = <String>{};
    for (final site in config.sites) {
      featuresWithOverrides.addAll(site.overrides.keys);
    }

    final switchCases = featuresWithOverrides.map((featureId) {
      final className = '${featureId.capitalize()}Feature';
      return {
        'featureClass': className,
        'featureName': featureId,
      };
    }).toList();

    return {
      'switchCases': switchCases,
    };
  }
}
