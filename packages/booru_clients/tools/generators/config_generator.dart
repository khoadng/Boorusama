import 'package:codegen/codegen.dart';
import '../models/booru_config.dart';
import 'param_generator.dart';
import 'enum_generator.dart';
import 'feature_generator.dart';
import 'endpoint_generator.dart';
import 'site_generator.dart';
import 'parser_registry_generator.dart';
import '../parsers/data_extractor.dart';
import 'package:yaml/yaml.dart';

class ConfigGenerator {
  const ConfigGenerator();

  String generate(
    BooruConfig config,
    Set<String> allParams,
    YamlList yamlData,
  ) {
    final featureIds = config.features.keys.toList();

    final paramGen = ParamGenerator();
    final enumGen = EnumGenerator();
    final featureGen = FeatureGenerator();
    final endpointGen = EndpointGenerator();
    final siteGen = SiteGenerator();
    final parserGen = ParserRegistryGenerator();

    final overrideClasses = siteGen.generateOverrideClasses(config);
    final siteContext = siteGen.buildContext(config);
    final featureGetters = siteContext['featureGetters'] as String;

    // Extract and generate parser registry
    final parserNames = DataExtractor.extractParserNames(yamlData);
    final parserRegistry = parserGen.generate(parserNames);

    final context = {
      'paramClass': paramGen.generate(allParams),
      'featureIdEnum': enumGen.generate(featureIds),
      'featureClasses': featureGen.generateWithOverrides(
        config,
        overrideClasses,
        featureGetters,
      ),
      'parserRegistry': parserRegistry,
      'hasImport': parserNames.isNotEmpty,
      'endpointsSection': endpointGen.generate(config),
      'siteCapabilities': siteGen.generate(config),
      'registrySection': featureGen.generateRegistry(config),
    };

    final template = TemplateManager().loadTemplate('config.mustache');
    return TemplateManager().render(template, context);
  }
}
