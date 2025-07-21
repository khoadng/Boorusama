// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:timeago/timeago.dart';

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
      _ => throw Exception('Unsupported locale $locale'),
    };
