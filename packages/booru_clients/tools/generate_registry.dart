import 'dart:io';

import 'package:codegen/codegen.dart';
import 'package:yaml/yaml.dart';
import 'parsers/yaml_config_parser.dart';
import 'generators/registry_generator.dart';

void main() async {
  try {
    await CodegenRunner().runWithInput(
      config: CodegenConfig(
        templateDirectory: 'tools/templates',
        inputPath: 'boorus.yaml',
        outputPath: '../../lib/boorus/registry.g.dart',
      ),
      inputLoader: _loadYamlData,
      generator: _generateRegistry,
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<List<Map<String, String>>> _loadYamlData(String data) async {
  final yamlData = loadYaml(data) as YamlList;
  final result = YamlConfigParser.parse(yamlData);

  return result.configs.map((spec) {
    return {
      'dartName': spec.dartName,
      'yamlName': spec.yamlName,
    };
  }).toList();
}

Future<String> _generateRegistry(List<Map<String, String>> configs) async {
  return RegistryGenerator().generate(configs);
}
