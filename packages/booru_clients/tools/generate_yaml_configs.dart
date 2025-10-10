import 'dart:io';

import 'package:codegen/codegen.dart';
import 'package:yaml/yaml.dart';
import 'parsers/yaml_config_parser.dart';
import 'generators/yaml_config_generator.dart';

void main() async {
  try {
    await CodegenRunner().runWithInput(
      config: CodegenConfig(
        templateDirectory: 'tools/templates',
        inputPath: 'boorus.yaml',
        outputPath: 'lib/src/generated/yaml_configs.dart',
      ),
      inputLoader: _loadYamlData,
      generator: _generateConfigs,
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<List<dynamic>> _loadYamlData(String data) async {
  final yamlData = loadYaml(data) as YamlList;
  final result = YamlConfigParser.parse(yamlData);

  return [result.configs, result.protocols];
}

Future<String> _generateConfigs(List<dynamic> data) async {
  final configs = data[0];
  final protocols = data[1];
  return YamlConfigGenerator().generate(configs, protocols);
}
