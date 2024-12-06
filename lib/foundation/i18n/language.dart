// Package imports:
import 'package:equatable/equatable.dart';

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
