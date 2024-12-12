// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:easy_logger/easy_logger.dart';
import 'package:timeago/timeago.dart';

// Project imports:
import 'locales.dart';

export 'package:easy_localization/easy_localization.dart'
    hide
        StringTranslateExtension,
        TextTranslateExtension,
        BuildContextEasyLocalizationExtension;

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

  void setLocaleFromString(String? locale) {
    if (locale == null) return;

    final data = locale.split('-');

    setLocale(Locale(data[0], data[1]));
  }
}

const fallbackLocale = Locale('en', 'US');

class RootBundleAssetLoader extends el.AssetLoader {
  const RootBundleAssetLoader({
    required this.supportedLocales,
  });

  final List<Locale> supportedLocales;

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return null;
    }

    final localePath = getLocalePath(path, locale);
    final data = json.decode(await rootBundle.loadString(localePath));
    return removeEmptyFields(data);
  }
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
      assetLoader: RootBundleAssetLoader(
        supportedLocales: supportedLocales,
      ),
      child: child,
    );
  }
}
