// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'language_data.dart';

class LanguageExtractor {
  static Future<List<LanguageData>> extractLanguages(
    Directory translationsDir,
  ) async {
    final languages = <LanguageData>[];

    final files = translationsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final languageData = await _extractLanguageFromFile(file);
        if (languageData != null) {
          languages.add(languageData);
        }
      } catch (e) {
        print('Warning: Failed to parse ${file.path}: $e');
      }
    }

    // Sort by locale for consistent output
    languages.sort((a, b) => a.locale.compareTo(b.locale));

    return languages;
  }

  static Future<LanguageData?> _extractLanguageFromFile(File file) async {
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    // Extract locale from filename (e.g., 'en-US.json' -> 'en-US')
    final locale = _extractLocaleFromFilename(file.path);
    if (locale == null) return null;

    // Extract language name from JSON structure
    final languageName = _extractLanguageName(json);
    if (languageName == null) return null;

    return LanguageData(
      locale: locale,
      name: languageName,
    );
  }

  static String? _extractLocaleFromFilename(String filePath) {
    final fileName = filePath.split('/').last;
    if (!fileName.endsWith('.json')) return null;

    return fileName.substring(0, fileName.length - 5); // Remove '.json'
  }

  static String? _extractLanguageName(Map<String, dynamic> json) {
    try {
      // Navigate to settings.language.language_name
      final settings = json['settings'] as Map<String, dynamic>?;
      if (settings == null) return null;

      final language = settings['language'] as Map<String, dynamic>?;
      if (language == null) return null;

      return language['language_name'] as String?;
    } catch (e) {
      return null;
    }
  }
}
