// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../foundation.dart';

final supportedLanguagesProvider =
    FutureProvider<List<BooruLanguage>>((ref) async {
  final names = await loadLanguageNames();

  final supportedLanguages = names..sort((a, b) => a.name.compareTo(b.name));

  return supportedLanguages;
});
