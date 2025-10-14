// Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Package imports:
import 'package:timeago/timeago.dart';

// Project imports:
import 'gen/languages.g.dart';
import 'gen/strings.g.dart';
import 'language.dart';
import 'locales.dart';

extension StringTranslateX on String {
  String get hc => this;
}

extension I18nX on BuildContext {
  List<LocalizationsDelegate> get localizationDelegates =>
      GlobalMaterialLocalizations.delegates;

  Locale get locale => TranslationProvider.of(this).flutterLocale;

  List<Locale> get supportedLocales => AppLocaleUtils.supportedLocales;

  void setLocale(Locale locale) =>
      LocaleSettings.setLocaleRaw(locale.languageCode);

  void setLocaleLanguage(BooruLanguage? lang) {
    if (lang == null) return;

    final locale = lang.toLocale();

    if (locale == null) return;

    setLocale(locale);
  }
}

extension LocaleX on Locale {
  String toLanguageTag() => '$languageCode-${countryCode ?? ''}';
}

Future<void> ensureI18nInitialized(String localeRaw) async {
  final language = GeneratedLanguages.findLanguage(localeRaw);

  if (language != null) {
    await LocaleSettings.setLocaleRaw(language.locale);
  }

  for (final locale in supportedLocales) {
    setLocaleMessages(locale.toLanguageTag(), getMessagesForLocale(locale));
  }
}

class BooruLocalization extends StatelessWidget {
  const BooruLocalization({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(child: child);
  }
}
