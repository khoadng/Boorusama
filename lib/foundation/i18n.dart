// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:easy_logger/easy_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/time.dart';

export 'package:easy_localization/easy_localization.dart'
    hide
        StringTranslateExtension,
        TextTranslateExtension,
        BuildContextEasyLocalizationExtension;

final supportedLanguagesProvider = Provider<List<BooruLanguage>>((ref) {
  throw UnimplementedError();
});

const fallbackLocale = Locale('en', 'US');

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
      _ => throw Exception('Unsupported locale $locale')
    };

extension StringTranslateX on String {
  String tr() => el.tr(this);

  String plural(num value) => el.plural(this, value);
}

extension TextTranslateX on Text {
  Text tr() => Text(
        el.tr(data ?? ''),
        key: key,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
      );
}

extension I18nX on BuildContext {
  List<LocalizationsDelegate> get localizationDelegates =>
      el.EasyLocalization.of(this)?.delegates ?? [];

  Locale get locale => el.EasyLocalization.of(this)?.locale ?? fallbackLocale;

  List<Locale> get supportedLocales =>
      el.EasyLocalization.of(this)?.supportedLocales ?? [];

  void setLocale(Locale locale) =>
      el.EasyLocalization.of(this)?.setLocale(locale);
}

class BooruLanguage extends Equatable {
  const BooruLanguage({
    required this.name,
    required this.locale,
  });

  final String name;
  final String locale;

  BooruLanguage copyWith({
    String? name,
    String? locale,
  }) {
    return BooruLanguage(
      name: name ?? this.name,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object> get props => [name, locale];
}

Future<List<BooruLanguage>> loadLanguageNames() async {
  final tasks = await Future.wait(
      supportedLocales.map((e) => e.toLanguageTag()).map(loadLanguage));

  return tasks.whereNotNull().toList();
}

Future<BooruLanguage?> loadLanguage(String lang) async {
  try {
    final path = 'assets/translations/$lang.json';
    final jsonString = await rootBundle.loadString(path);
    final jsonMap = json.decode(jsonString);
    final languageName = jsonMap['settings']['language']['language_name'];
    if (languageName != null) {
      return BooruLanguage(
        locale: lang,
        name: languageName,
      );
    }
  } catch (e) {
    return null;
  }
  return null;
}

dynamic removeEmptyFields(dynamic json) {
  if (json is Map) {
    json.removeWhere((key, value) => value == null || value == '');
    json.forEach((key, value) {
      json[key] = removeEmptyFields(value);
    });
  } else if (json is List) {
    json.removeWhere((item) => item == null || item == '');
    for (var i = 0; i < json.length; i++) {
      json[i] = removeEmptyFields(json[i]);
    }
  }
  return json;
}

Future<void> ensureI18nInitialized() async {
  el.EasyLocalization.logger = EasyLogger(
    enableBuildModes: [],
  );

  await el.EasyLocalization.ensureInitialized();

  for (final locale in supportedLocales) {
    setLocaleMessages(
      locale.toLanguageTag(),
      getMessagesForLocale(locale),
    );
  }
}

class BooruLocalization extends StatelessWidget {
  const BooruLocalization({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return el.EasyLocalization(
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      fallbackLocale: fallbackLocale,
      useFallbackTranslations: true,
      assetLoader: const RootBundleAssetLoader(),
      child: child,
    );
  }
}

class RootBundleAssetLoader extends el.AssetLoader {
  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final localePath = getLocalePath(path, locale);
    final data = json.decode(await rootBundle.loadString(localePath));
    return removeEmptyFields(data);
  }
}
