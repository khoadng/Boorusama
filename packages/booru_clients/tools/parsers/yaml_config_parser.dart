import 'package:yaml/yaml.dart';
import '../models/yaml_config_spec.dart';

class YamlConfigParser {
  static ({List<YamlConfigSpec> configs, Set<String> protocols}) parse(
    YamlList yamlData,
  ) {
    final specs = <YamlConfigSpec>[];
    final protocols = <String>{};

    for (final entry in yamlData) {
      if (entry is! YamlMap) continue;

      for (final booruEntry in entry.entries) {
        final yamlName = booruEntry.key as String;
        final config = booruEntry.value as YamlMap;

        final protocol = config['protocol'] as String? ?? 'https_2';
        protocols.add(protocol);

        // Also collect protocols from sites
        final sites = config['sites'];
        if (sites is YamlList) {
          for (final site in sites) {
            if (site is YamlMap && site.containsKey('protocol')) {
              protocols.add(site['protocol'] as String);
            }
          }
        }

        // Extract metadata for BooruType
        final metadata = config['metadata'] as YamlMap?;
        final booruTypeMetadata = _extractBooruTypeMetadata(metadata, yamlName);

        specs.add(
          YamlConfigSpec(
            yamlName: yamlName,
            dartName: _toDartName(yamlName),
            protocol: protocol,
            sites: _parseSites(config['sites']),
            booruTypeMetadata: booruTypeMetadata,
            loginUrl: config['login-url'] as String?,
            headers: _parseHeaders(config['headers']),
            globalUserParams: _parseMap(config['global-user-params']),
            auth: _parseRaw(config['auth']),
            features: _parseRaw(config['features']),
          ),
        );
      }
    }

    return (configs: specs, protocols: protocols);
  }

  static Map<String, dynamic> _extractBooruTypeMetadata(
    YamlMap? metadata,
    String yamlName,
  ) {
    if (metadata == null || !metadata.containsKey('id')) {
      throw Exception(
        'Missing required "id" field in metadata for "$yamlName"',
      );
    }

    final id = metadata['id'] as int;
    if (id <= 0) {
      throw Exception(
        'Invalid ID $id for "$yamlName": ID must be greater than 0 (0 is reserved for unknown)',
      );
    }

    final legacyIds = _parseLegacyIds(metadata['legacy-ids']);
    for (final legacyId in legacyIds) {
      if (legacyId <= 0) {
        throw Exception(
          'Invalid legacy ID $legacyId for "$yamlName": ID must be greater than 0',
        );
      }
    }

    return {
      'id': id,
      'name': metadata['name'] as String?,
      'displayName': metadata['display-name'] as String?,
      'canDownloadMultipleFiles':
          metadata['can-download-multiple-files'] as bool?,
      'hasUnknownFullImageUrl': metadata['has-unknown-full-image-url'] as bool?,
      'postCountMethod': metadata['post-count-method'] as String?,
      'isSingleSite': metadata['single-site'] as bool?,
      'legacyIds': legacyIds,
    };
  }

  static List<int> _parseLegacyIds(dynamic legacyIds) {
    if (legacyIds == null) return [];
    if (legacyIds is YamlList) {
      return legacyIds.map((e) => e as int).toList();
    }
    if (legacyIds is List) {
      return legacyIds.cast<int>();
    }
    return [];
  }

  static List<SiteSpec> _parseSites(dynamic sites) {
    if (sites == null) return [];

    final result = <SiteSpec>[];
    for (final site in sites as YamlList) {
      if (site is String) {
        result.add(SiteSpec(url: site, metadata: {}));
      } else if (site is YamlMap) {
        final url = site['url'] as String;
        final metadata = Map<String, dynamic>.from(site)..remove('url');
        result.add(SiteSpec(url: url, metadata: metadata));
      }
    }
    return result;
  }

  static Map<String, String>? _parseHeaders(dynamic headers) {
    if (headers == null) return null;

    final result = <String, String>{};
    for (final header in headers as YamlList) {
      if (header is YamlMap) {
        // Headers are stored as list of single-entry maps
        for (final entry in header.entries) {
          result[entry.key.toString()] = entry.value.toString();
        }
      } else if (header is String) {
        // Also support string format "Key: Value"
        final colonIndex = header.indexOf(':');
        if (colonIndex > 0) {
          final key = header.substring(0, colonIndex).trim();
          final value = header.substring(colonIndex + 1).trim();
          result[key] = value;
        }
      }
    }
    return result.isNotEmpty ? result : null;
  }

  static Map<String, String>? _parseMap(dynamic data) {
    if (data == null) return null;
    return Map<String, String>.from(data as YamlMap);
  }

  static Map<String, dynamic>? _parseRaw(dynamic data) {
    if (data == null) return null;
    return Map<String, dynamic>.from(data as YamlMap);
  }

  static String _toDartName(String yamlName) {
    // Replace hyphens with underscores, then convert to camelCase
    final normalized = yamlName.replaceAll('-', '_');
    final className = normalized
        .split('_')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join('');
    return className[0].toLowerCase() + className.substring(1);
  }
}
