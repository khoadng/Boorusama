// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:timeago/timeago.dart';

const supportedLocales = [
  Locale('en', 'US'), // English (United States)
  Locale('vi', 'VN'), // Vietnamese (Vietnam)
  Locale('ru', 'RU'), // Russian (Russia)
  Locale('be', 'BY'), // Belarusian (Belarus)
  Locale('ja', 'JP'), // Japanese (Japan)
  Locale('de', 'DE'), // German (Germany)
  Locale('es', 'ES'), // Spanish (Spain)
  Locale('pt', 'PT'), // Portuguese (Portugal)
  Locale('pt', 'BR'), // Portuguese (Brazil)
  Locale('zh', 'CN'), // Simplified Chinese
  Locale('zh', 'TW'), // Traditional Chinese
  Locale('uk', 'UA'), // Ukrainian (Ukraine)
  Locale('tr', 'TR'), // Turkish (Turkey)
  Locale('fr', 'FR'), // French (France)
  Locale('th', 'TH'), // Thai (Thailand)
  Locale('nb', 'NO'), // Norwegian Bokmål (Norway)
  Locale('ro', 'RO'), // Romanian (Romania)
  Locale('ta', 'IN'), // Tamil (India)
  Locale('ko', 'KR'), // Korean (South Korea)
  Locale('it', 'IT'), // Italian (Italy)
];

LookupMessages getMessagesForLocale(Locale locale) =>
    switch (locale.toLanguageTag()) {
      'en-US' => EnMessages(),
      'vi-VN' => ViMessages(),
      'ru-RU' => RuMessages(),
      'be-BY' => BeMessages(),
      'ja-JP' => JaMessages(),
      'de-DE' => DeMessages(),
      'pt-PT' => PtBrMessages(),
      'pt-BR' => PtBrMessages(),
      'es-ES' => EsMessages(),
      'zh-CN' => ZhCnMessages(),
      'zh-TW' => ZhMessages(),
      'uk-UA' => UkMessages(),
      'tr-TR' => TrMessages(),
      'fr-FR' => FrMessages(),
      'th-TH' => ThMessages(),
      'nb-NO' => NbNoMessages(),
      'ro-RO' => RoMessages(),
      'ta-IN' => TaMessages(),
      'ko-KR' => KoMessages(),
      'it-IT' => ItMessages(),
      _ => throw Exception('Unsupported locale $locale')
    };
