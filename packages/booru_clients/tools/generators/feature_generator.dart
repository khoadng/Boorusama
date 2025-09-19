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
}
