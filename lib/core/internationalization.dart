// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:timeago/timeago.dart';

class BooruLanguage extends Equatable {
  final String name;
  final String locale;

  const BooruLanguage({
    required this.name,
    required this.locale,
  });

  @override
  List<Object> get props => [name, locale];

  BooruLanguage copyWith({
    String? name,
    String? locale,
  }) {
    return BooruLanguage(
      name: name ?? this.name,
      locale: locale ?? this.locale,
    );
  }
}

const supportedLocales = [
  Locale('en', 'US'), // English (United States)
  Locale('vi', 'VN'), // Vietnamese (Vietnam)
  Locale('ru', 'RU'), // Russian (Russia)
  Locale('be', 'BY'), // Belarusian (Belarus)
  Locale('ja', 'JP'), // Japanese (Japan)
  Locale('de', 'DE'), // German (Germany)
  Locale('es', 'ES'), // Spanish (Spain)
  Locale('pt', 'PT'), // Portuguese (Portugal)
  Locale('zh', 'CN'), // Simplified Chinese
  Locale('zh', 'TW'), // Traditional Chinese
];

Future<List<BooruLanguage>> loadLanguageNames() async {
  final languageNames = <BooruLanguage>[];
  final languages = supportedLocales
      .map((e) => e.countryCode != null
          ? '${e.languageCode}-${e.countryCode}'
          : e.languageCode)
      .toList();

  for (String lang in languages) {
    final path = 'assets/translations/$lang.json';
    final jsonString = await rootBundle.loadString(path);
    final jsonMap = json.decode(jsonString);
    final languageName = jsonMap['settings']['language']['language_name'];
    if (languageName != null) {
      languageNames.add(BooruLanguage(
        locale: lang,
        name: languageName,
      ));
    }
  }

  return languageNames;
}

Future<void> ensureI18nInitialized() async {
  await EasyLocalization.ensureInitialized();

  //TODO: shouldn't hardcode language.
  setLocaleMessages('en-US', EnMessages());
  setLocaleMessages('vi-VN', ViMessages());
  setLocaleMessages('ru-RU', RuMessages());
  setLocaleMessages('be-BY', RuMessages());
  setLocaleMessages('ja-JP', JaMessages());
  setLocaleMessages('de-DE', DeMessages());
  setLocaleMessages('pt-PT', PtBrMessages());
  setLocaleMessages('es-ES', EsMessages());
  setLocaleMessages('zh_CN', ZhCnMessages());
  setLocaleMessages('zh_TW', ZhMessages());
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
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      child: child,
    );
  }
}
