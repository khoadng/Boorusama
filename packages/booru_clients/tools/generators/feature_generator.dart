import 'generator.dart';
import '../utils/string_utils.dart';
import '../models/booru_config.dart';

class FeatureGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'features.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    final featureClasses = config.features.entries.map((entry) {
      final featureId = entry.key;
      final feature = entry.value;
      final capabilities = feature.capabilities ?? [];

      return {
        'className': '${featureId.capitalize()}Feature',
        'featureId': featureId,
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
        'constructorParams': capabilities
            .map(
              (cap) => {
                'name': kebabToCamel(cap.name),
                'isLast': cap == capabilities.last,
              },
            )
            .toList(),
      };
    }).toList();

    return {
      'featureClasses': featureClasses,
    };
  }

  String generateFeatureMethods(BooruConfig config) {
    final switchCases = config.features.entries
        .map((entry) {
          final featureId = entry.key;
          final feature = entry.value;
          final capabilities = feature.capabilities ?? [];

          if (capabilities.isEmpty) {
            return '    BooruFeatureId.$featureId => const ${featureId.capitalize()}Feature(),';
          }

          final params = capabilities
              .map(
                (cap) =>
                    '${kebabToCamel(cap.name)}: ${_formatDartValue(cap.value)}',
              )
              .join(', ');

          return '    BooruFeatureId.$featureId => const ${featureId.capitalize()}Feature($params),';
        })
        .join('\n');

    return '''  static BooruFeature? createFeature(BooruFeatureId id) => switch (id) {
$switchCases
  };

  static List<BooruFeature> createAllFeatures() => 
      defaultFeatures.keys.map(createFeature).whereType<BooruFeature>().toList();''';
  }

  String _formatDartValue(dynamic value) {
    return switch (value.runtimeType) {
      const (bool) || const (int) || const (double) => value.toString(),
      const (String) => "'$value'",
      _ => "'$value'",
    };
  }
}
