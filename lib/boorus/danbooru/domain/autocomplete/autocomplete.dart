// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart' as p;
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart' as t;
import 'package:boorusama/boorus/danbooru/domain/users/user_level.dart';

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
  final AutocompleteCategory? category; // int or String
  final PostCount? postCount;
  final AutocompleteAntecedent? antecedent;
  final UserLevel? level;

  bool get hasAlias => antecedent != null;
  bool get hasCount => postCount != null;
  bool get hasUserLevel => level != null;
  bool get hasCategory => category != null;

  static const empty = AutocompleteData(label: '', value: '');

  @override
  List<Object?> get props =>
      [label, value, type, category, postCount, level, antecedent];
}

abstract class AutocompleteCategory {
  String getName();
  int getIndex();
}

class PoolCategory implements AutocompleteCategory {
  const PoolCategory({
    required this.category,
  });
  final p.PoolCategory category;

  @override
  String getName() => category.name;

  @override
  int getIndex() => category.index;
}

class TagCategory implements AutocompleteCategory {
  const TagCategory({
    required this.category,
  });
  final t.TagCategory category;

  @override
  String getName() => category.name;
  @override
  int getIndex() => category.index;
}
