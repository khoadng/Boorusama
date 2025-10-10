import 'dart:convert';
import 'package:codegen/codegen.dart';
import '../models/yaml_config_spec.dart';

class YamlConfigGenerator {
  String generate(List<YamlConfigSpec> specs, Set<String> protocols) {
    final configs = specs.map((spec) {
      return {
        'dartName': spec.dartName,
        'yamlName': spec.yamlName,
        'protocolEnum': _toEnumName(spec.protocol),
        'sites': spec.sites.map((site) {
          final hasMetadata = site.metadata.isNotEmpty;
          return {
            'url': site.url,
            'hasMetadata': hasMetadata,
            'metadataJson': hasMetadata ? _toJson(site.metadata) : null,
          };
        }).toList(),
        'loginUrl': spec.loginUrl,
        'hasLoginUrl': spec.loginUrl != null,
        'headers': spec.headers,
        'hasHeaders': spec.headers != null,
        'headersJson': spec.headers != null ? _toJson(spec.headers!) : null,
        'globalUserParams': spec.globalUserParams,
        'hasGlobalUserParams': spec.globalUserParams != null,
        'globalUserParamsJson': spec.globalUserParams != null
            ? _toJson(spec.globalUserParams!)
            : null,
        'auth': spec.auth,
        'hasAuth': spec.auth != null,
        'authJson': spec.auth != null ? _toJson(spec.auth!) : null,
        'features': spec.features,
        'hasFeatures': spec.features != null,
        'featuresJson': spec.features != null ? _toJson(spec.features!) : null,
      };
    }).toList();

    final protocolMappings = (protocols.toList()..sort())
        .map(
          (p) => {
            'yamlValue': p,
            'enumName': _toEnumName(p),
          },
        )
        .toList();

    final booruTypes = _generateBooruTypes(specs);
    final legacyIdMap = _generateLegacyIdMap(specs);

    final configNames = specs.map((spec) => spec.dartName).toList();

    final configMapEntries = <Map<String, dynamic>>[];
    for (final spec in specs) {
      final id = spec.booruTypeMetadata['id'] as int;
      final legacyIds =
          (spec.booruTypeMetadata['legacyIds'] as List<int>?) ?? [];
      final allIds = [id, ...legacyIds];

      for (final idValue in allIds) {
        configMapEntries.add({
          'id': idValue,
          'dartName': spec.dartName,
        });
      }
    }

    configMapEntries.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

    final context = {
      'configs': configs,
      'protocols': protocolMappings,
      'booruTypes': booruTypes,
      'legacyIdMap': legacyIdMap,
      'configNames': configNames,
      'configMapEntries': configMapEntries,
    };
    final template = TemplateManager().loadTemplate('yaml_configs.mustache');
    return TemplateManager().render(template, context);
  }

  List<Map<String, dynamic>> _generateBooruTypes(List<YamlConfigSpec> specs) {
    return specs.map((spec) {
      final metadata = spec.booruTypeMetadata;
      final params = <String>[];

      params.add("name: '${spec.dartName}',");
      params.add("yamlName: '${spec.yamlName}',");
      params.add("id: ${metadata['id']},");

      final displayName =
          metadata['displayName'] ?? _toDisplayName(spec.yamlName);
      params.add("displayName: '$displayName',");

      final canDownloadMultipleFiles =
          metadata['canDownloadMultipleFiles'] ?? true;
      if (!canDownloadMultipleFiles) {
        params.add('canDownloadMultipleFiles: false,');
      }

      final hasUnknownFullImageUrl =
          metadata['hasUnknownFullImageUrl'] ?? false;
      if (hasUnknownFullImageUrl) {
        params.add('hasUnknownFullImageUrl: true,');
      }

      final postCountMethod = metadata['postCountMethod'] ?? 'notSupported';
      if (postCountMethod != 'notSupported') {
        params.add('postCountMethod: PostCountMethod.$postCountMethod,');
      }

      final isSingleSite = metadata['isSingleSite'] ?? false;
      if (isSingleSite) {
        params.add('isSingleSite: true,');
      }

      return {
        'name': spec.dartName,
        'params': params.join('\n    '),
      };
    }).toList();
  }

  String _generateLegacyIdMap(List<YamlConfigSpec> specs) {
    final seenIds = <int, String>{};

    for (final spec in specs) {
      final metadata = spec.booruTypeMetadata;
      final id = metadata['id'] as int;
      final legacyIds = (metadata['legacyIds'] as List<int>?) ?? [];
      final allIds = [id, ...legacyIds];

      for (final idValue in allIds) {
        if (seenIds.containsKey(idValue)) {
          throw Exception(
            'Duplicate ID $idValue found in "${spec.yamlName}" and "${seenIds[idValue]}"',
          );
        }
        seenIds[idValue] = spec.yamlName;
      }
    }

    final cases = <String>[];

    for (final spec in specs) {
      final metadata = spec.booruTypeMetadata;
      final id = metadata['id'] as int;
      final legacyIds = (metadata['legacyIds'] as List<int>?) ?? [];
      final allIds = [id, ...legacyIds];

      if (allIds.isEmpty) continue;

      allIds.sort();

      final idPattern = allIds.join(' || ');
      cases.add('    $idPattern => ${spec.dartName},');
    }

    return cases.join('\n');
  }

  String _toDisplayName(String input) {
    // Convert kebab-case/snake_case to Title Case
    final parts = input.split(RegExp(r'[-_]'));
    return parts
        .map((p) {
          if (p.isEmpty) return '';
          return p[0].toUpperCase() + p.substring(1);
        })
        .join(' ');
  }

  String _toEnumName(String yamlValue) {
    return switch (yamlValue) {
      'https_1' => 'https_1_1',
      'https_2' => 'https_2_0',
      _ => yamlValue.replaceAll('-', '_'),
    };
  }

  String _toJson(Map<String, dynamic> map) {
    final encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(map);
    // Escape $ characters to avoid string interpolation issues
    return json.replaceAll(r'$', r'\$').replaceAll('\n', '\n        ');
  }
}
