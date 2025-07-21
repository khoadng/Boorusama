import 'package:yaml/yaml.dart';
import 'package:codegen/codegen.dart';
import 'parsers/data_extractor.dart';
import 'generators/config_generator.dart';

void main() async {
  await CodegenRunner().runWithInput(
    config: CodegenConfig(
      templateDirectory: 'tools/templates',
      inputPath: '../../boorus.yaml',
      outputPath: 'lib/src/generated/booru_config.dart',
    ),
    inputLoader: (data) async {
      final yamlData = loadYaml(data);
      final gelbooruV2Config = DataExtractor.extractGelbooruV2Config(yamlData);

      if (gelbooruV2Config == null) {
        throw Exception('Failed to extract config from YAML data');
      }

      final allParams = DataExtractor.extractAllParams(yamlData);
      return (gelbooruV2Config, allParams);
    },
    generator: (input) async {
      final (config, allParams) = input;
      return ConfigGenerator().generate(config, allParams);
    },
  );
}
