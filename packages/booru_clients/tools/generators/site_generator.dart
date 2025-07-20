import '../utils/template_utils.dart';
import 'generator.dart';
import '../models/booru_config.dart';

class SiteGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'site_capabilities.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    final sites = config.sites.asMap().entries.map((entry) {
      final index = entry.key;
      final site = entry.value;

      final overrides = site.overrides.entries.map((overrideEntry) {
        final override = overrideEntry.value;

        return {
          'featureId': overrideEntry.key,
          'hasType': override.type != null,
          'type': override.type ?? '',
          'hasPath': override.endpoint != null,
          'path': override.endpoint ?? '',
          'hasParser': override.parser != null,
          'parser': override.parser ?? '',
          'hasParams':
              override.userParams != null && override.userParams!.isNotEmpty,
          'paramMapping': TemplateUtils.buildParamMapping(
            override.userParams ?? {},
          ),
          'hasCapabilities':
              override.capabilities != null &&
              override.capabilities!.isNotEmpty,
          'capabilities': _buildCapabilities(override.capabilities),
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
      'sites': sites,
    };
  }

  String generateSitesList(BooruConfig config) {
    if (config.sites.isEmpty) return '<String>[]';
    final siteUrls = config.sites.map((site) => "'${site.url}'").join(', ');
    return '<String>[$siteUrls]';
  }

  String _buildCapabilities(List<CapabilityField>? capabilities) {
    if (capabilities == null || capabilities.isEmpty) {
      return '<String, dynamic>{}';
    }

    if (capabilities.length == 1) {
      final cap = capabilities.first;
      final value = _formatDartValue(cap.value);
      return '<String, dynamic>{\n            \'${cap.name}\': $value,\n          }';
    }

    final entries = capabilities
        .map((cap) {
          final value = _formatDartValue(cap.value);
          return "            '${cap.name}': $value,";
        })
        .join('\n');

    return '<String, dynamic>{\n$entries\n          }';
  }

  String _formatDartValue(dynamic value) {
    return switch (value.runtimeType) {
      const (bool) || const (int) || const (double) => value.toString(),
      const (String) => "'$value'",
      _ => "'$value'",
    };
  }
}
