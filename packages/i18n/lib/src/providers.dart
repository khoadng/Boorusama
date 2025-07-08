// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'language.dart';
import 'loader.dart';

final supportedLanguagesProvider = FutureProvider<List<BooruLanguage>>((
  ref,
) async {
  final names = await loadLanguageNames();

  final supportedLanguages = names..sort((a, b) => a.name.compareTo(b.name));

  return supportedLanguages;
});

BooruLanguage? findLanguageByNameOrLocale(
  List<BooruLanguage> languages,
  String nameOrLocale,
) {
  return languages.firstWhereOrNull(
    (lang) => lang.name == nameOrLocale || lang.locale == nameOrLocale,
  );
}
