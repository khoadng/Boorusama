final class FlavorConfig {
  const FlavorConfig({required this.envFile});

  final String envFile;
}

final class BoorusamaConfig {
  const BoorusamaConfig._();

  static const defaultTargetFile = 'lib/main.dart';
  static const fossTargetFile = 'lib/main_foss.dart';
  static const defaultOutputDir = 'artifacts';
  static const allowedFlavors = ['dev', 'prod'];
  static const fossExcludedDeps = [
    'purchases_flutter:',
    'rate_my_app:',
    'google_api_availability:',
  ];

  static const flavors = {
    'dev': FlavorConfig(envFile: 'env/dev.json'),
    'prod': FlavorConfig(envFile: 'env/prod.json'),
  };
}
