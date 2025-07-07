// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'language.dart';
import 'locales.dart';

Future<List<BooruLanguage>> loadLanguageNames() async {
  final tasks = await Future.wait(
    supportedLocales.map((e) => e.toLanguageTag()).map(loadLanguage),
  );

  return tasks.nonNulls.toList();
}

Future<BooruLanguage?> loadLanguage(String lang) async {
  try {
    final path = 'assets/translations/$lang.json';
    final jsonString = await rootBundle.loadString(path);
    final jsonMap = json.decode(jsonString);
    final languageName = jsonMap['settings']['language']['language_name'];
    if (languageName != null) {
      return BooruLanguage(locale: lang, name: languageName);
    }
  } catch (e) {
    return null;
  }
  return null;
}
