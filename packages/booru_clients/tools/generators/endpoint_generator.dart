import 'package:codegen/codegen.dart';
import '../models/booru_config.dart';

class EndpointGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'endpoints.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    final endpoints = config.features.entries.map((entry) {
      final featureId = entry.key;
      final feature = entry.value;

      return {
        'featureId': featureId,
        'type': feature.type,
        'path': feature.endpoint,
        'hasParser': feature.parser != null,
        'parser': feature.parser ?? '',
        'paramMapping': TemplateUtils.buildParamMapping(feature.userParams),
      };
    }).toList();

    final defaultFeatures = config.features.keys.toList().asMap().entries.map((
      entry,
    ) {
      return {
        'featureId': entry.value,
        'isLast': entry.key == config.features.length - 1,
      };
    }).toList();

    return {
      'endpoints': endpoints,
      'defaultFeatures': defaultFeatures,
    };
  }
}
