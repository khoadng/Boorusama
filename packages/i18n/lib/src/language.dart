// Package imports:
import 'package:equatable/equatable.dart';
import 'dart:ui';

class BooruLanguage extends Equatable {
  const BooruLanguage({required this.name, required this.locale});

  final String name;
  final String locale;

  BooruLanguage copyWith({String? name, String? locale}) {
    return BooruLanguage(
      name: name ?? this.name,
      locale: locale ?? this.locale,
    );
  }

  Locale? toLocale() {
    final languageCode = locale.split('-').firstOrNull;
    final countryCode = locale.split('-').lastOrNull;

    if (languageCode == null ||
        languageCode.isEmpty ||
        countryCode == null ||
        countryCode.isEmpty) {
      return null;
    }

    return Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }

  @override
  List<Object> get props => [name, locale];
}
