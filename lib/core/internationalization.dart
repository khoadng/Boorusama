// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:timeago/timeago.dart';

const supportedLocales = [
  //TODO: should parse from translation files instead of hardcoding
  Locale('en', ''),
  Locale('vi', ''),
  Locale('ru', ''),
  Locale('be', ''),
  Locale('ja', ''),
  Locale('de', ''),
  Locale('fr', ''),
  Locale('es', ''),
  Locale('pt', ''),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
];

Future<void> ensureI18nInitialized() async {
  await EasyLocalization.ensureInitialized();

  //TODO: shouldn't hardcode language.
  setLocaleMessages('vi', ViMessages());
  setLocaleMessages('ru', RuMessages());
  setLocaleMessages('be', RuMessages());
  setLocaleMessages('ja', JaMessages());
  setLocaleMessages('de', DeMessages());
  setLocaleMessages('pt', PtBrMessages());
  setLocaleMessages('es', EsMessages());
  setLocaleMessages('zh_hans', ZhCnMessages());
  setLocaleMessages('zh_hant', ZhMessages());
}

class BooruLocalization extends StatelessWidget {
  const BooruLocalization({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en', ''),
      useFallbackTranslations: true,
      child: child,
    );
  }
}
