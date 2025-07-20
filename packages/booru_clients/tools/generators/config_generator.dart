import '../models/booru_config.dart';
import 'param_generator.dart';
import 'enum_generator.dart';
import 'feature_generator.dart';
import 'endpoint_generator.dart';
import 'site_generator.dart';
import 'template_manager.dart';

class ConfigGenerator {
  const ConfigGenerator();

  String generate(BooruConfig config, Set<String> allParams) {
    final featureIds = config.features.keys.toList();

    final paramGen = ParamGenerator();
    final enumGen = EnumGenerator();
    final featureGen = FeatureGenerator();
    final endpointGen = EndpointGenerator();
    final siteGen = SiteGenerator();

    final context = {
      'paramClass': paramGen.generate(allParams),
      'featureIdEnum': enumGen.generate(featureIds),
      'featureClasses': featureGen.generate(config),
      'endpointsSection': endpointGen.generate(config),
      'siteCapabilities': siteGen.generate(config),
      'featureMethods': featureGen.generateFeatureMethods(config),
    };

    final template = TemplateManager().loadTemplate('config.mustache');
    return TemplateManager().render(template, context);
  }
}
