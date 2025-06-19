// Package imports:
import 'package:equatable/equatable.dart';

class AutocompleteQuery extends Equatable {
  const AutocompleteQuery({
    required this.text,
    this.category,
  });

  const AutocompleteQuery.text(this.text) : category = null;

  final String text;
  final String? category;

  @override
  List<Object?> get props => [text, category];
}
