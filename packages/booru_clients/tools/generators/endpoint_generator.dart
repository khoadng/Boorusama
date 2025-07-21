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
      'globalParamsMap': _buildGlobalParamsMap(config.globalUserParams),
      'sitesList': _buildSitesList(config.sites),
      'defaultFeatures': defaultFeatures,
    };
  }

  String _buildGlobalParamsMap(Map<String, String> params) {
    if (params.isEmpty) return '<String, String>{}';

    final entries = params.entries
        .map((e) => "'${e.key}': '${e.value}'")
        .join(', ');

    return '<String, String>{$entries}';
  }

  String _buildSitesList(List<SiteConfig> sites) {
    if (sites.isEmpty) return '<String>[]';

    final siteUrls = sites.map((site) => "'${site.url}'").join(', ');
    return '<String>[$siteUrls]';
  }
}
