// Package imports:
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
