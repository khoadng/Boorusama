// Package imports:
import 'package:i18n/i18n.dart';

extension DeveloperOptionsTranslationsX on Translations {
  DeveloperOptionsL10n get developerOptions => const DeveloperOptionsL10n();
}

class DeveloperOptionsL10n {
  const DeveloperOptionsL10n();

  String get title => 'Developer options';

  String get blockAutomaticMedia => 'Block automatic media loading';

  String get blockAutomaticMediaDescription =>
      'Prevents images, videos, and media preloading from using the network. '
      'Explicit downloads remain available.';

  String get mediaLoadingOff => 'Media loading off';

  String get developerMode => 'Developer mode';
}
