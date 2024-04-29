// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

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
    this.subOptions,
    this.forceChooseSubOption = false,
  });

  final String? type;
  final AutocompleteLabel label;
  final AutocompleteValue value;
  final String? category;
  final PostCount? postCount;
  final AutocompleteAntecedent? antecedent;
  final String? level;

  // This is used for custom autocomplete options
  final List<AutocompleteSubOption>? subOptions;
  final bool forceChooseSubOption;
  bool get hasSubOptions => subOptions != null && subOptions!.isNotEmpty;

  bool get hasAlias => antecedent != null;
  bool get hasCount => postCount != null;
  bool get hasUserLevel => level != null;
  bool get hasCategory => category != null;

  static const empty = AutocompleteData(label: '', value: '');
  static const abbreviation = 'tag-abbreviation';
  static const autoCorrect = 'tag-autocorrect';
  static const otherName = 'tag-other-name';
  static const alias = 'tag-alias';
  static const word = 'tag-word';
  static const tag = 'tag';

  static const user = 'user';
  static const pool = 'pool';

  static const tagTypes = [
    abbreviation,
    autoCorrect,
    otherName,
    alias,
    word,
    tag,
  ];

  static const userTypes = [
    user,
  ];

  static const poolTypes = [
    pool,
  ];

  static bool isTagType(String? type) => tagTypes.contains(type);

  factory AutocompleteData.fromJson(Map<String, dynamic> json) {
    return AutocompleteData(
      type: json['type'],
      label: json['label'],
      value: json['value'],
      category: json['category'],
      postCount: json['post_count'],
      level: json['level'],
      antecedent: json['antecedent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'value': value,
      'category': category,
      'post_count': postCount,
      'level': level,
      'antecedent': antecedent,
    };
  }

  @override
  List<Object?> get props =>
      [label, value, type, category, postCount, level, antecedent];
}

class AutocompleteSubOption extends Equatable {
  final String value;
  final AutocompleteSubOptionQueryBuildType queryBuildType;

  const AutocompleteSubOption({
    required this.value,
    required this.queryBuildType,
  });

  @override
  List<Object?> get props => [value, queryBuildType];
}

extension AutocompleteSubOptionX on AutocompleteSubOption {
  String resolveQuery(String query) => switch (queryBuildType) {
        AutocompleteSubOptionQueryBuildType.appendWithColon => '$query:$value'
      };
}

extension AutocompleteDataX on AutocompleteData {
  AutocompleteData overrideWithSubOptions(AutocompleteSubOption subOption) {
    return AutocompleteData(
      label: subOption.resolveQuery(value),
      value: subOption.resolveQuery(value),
      type: type,
      category: category,
      postCount: postCount,
      level: level,
      antecedent: antecedent,
      subOptions: null, // clear subOptions
      forceChooseSubOption: false,
    );
  }
}

enum AutocompleteSubOptionQueryBuildType {
  appendWithColon,
}
