// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';

typedef AutocompleteValue = String;
typedef AutocompleteLabel = String;
typedef AutocompleteAntecedent = String;

class AutocompleteData extends Equatable {
  const AutocompleteData({
    required this.label,
    required this.value,
    this.type,
    this.category,
    this.postCount,
    this.level,
    this.antecedent,
  });

  final String? type;
  final AutocompleteLabel label;
  final AutocompleteValue value;
  final String? category;
  final PostCount? postCount;
  final AutocompleteAntecedent? antecedent;
  final String? level;

  bool get hasAlias => antecedent != null;
  bool get hasCount => postCount != null;
  bool get hasUserLevel => level != null;
  bool get hasCategory => category != null;

  static const empty = AutocompleteData(label: '', value: '');

  @override
  List<Object?> get props =>
      [label, value, type, category, postCount, level, antecedent];
}
