// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/tags/metatag/extractor.dart';
import 'package:boorusama/core/tags/tag/providers.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/core/users/colors.dart';
import 'package:boorusama/functional.dart';

export 'autocomplete_repository.dart';

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

bool isSfwTag({
  required String value,
  String? antecedent,
  required Set<String> nsfwTags,
}) {
  for (final tag in nsfwTags) {
    if (value.contains(tag)) {
      return false;
    }

    if (antecedent?.contains(tag) ?? false) {
      return false;
    }
  }

  final words = value.split('_');
  final aliasWords = antecedent?.split('_') ?? [];

  for (final tag in nsfwTags) {
    for (final word in words) {
      if (word.contains(tag)) {
        return false;
      }
    }

    for (final word in aliasWords) {
      if (word.contains(tag)) {
        return false;
      }
    }
  }

  return true;
}

List<String> filterNsfwRawTagString(
  String tag,
  Set<String> nsfwTags, {
  bool shouldFilter = true,
}) {
  final tags = tag.split(' ').toList();

  return shouldFilter
      ? tags
          .where((e) => isSfwTag(
                value: e,
                nsfwTags: nsfwTags,
              ))
          .toList()
      : tags;
}

IList<AutocompleteData> filterNsfw(
  List<AutocompleteData> data,
  Set<String> nsfwTags, {
  bool shouldFilter = true,
}) {
  return shouldFilter
      ? data
          .where((e) => isSfwTag(
                value: e.value,
                antecedent: e.antecedent,
                nsfwTags: nsfwTags,
              ))
          .toList()
          .lock
      : data.lock;
}

Color? generateAutocompleteTagColor(
  WidgetRef ref,
  BuildContext context,
  AutocompleteData tag,
) {
  if (tag.hasCategory) {
    return ref.watch(tagColorProvider(tag.category!));
  } else if (tag.hasUserLevel) {
    return Color(getUserHexColor(stringToUserLevel(tag.level)));
  }

  return null;
}

extension AutocompleteDataDisplayX on AutocompleteData {
  String toDisplayHtml(
    String value, [
    MetatagExtractor? metatagExtractor,
  ]) {
    final noOperatorQuery = (value.startsWith('-') || value.startsWith('~'))
        ? value.substring(1)
        : value;
    final rawQuery = noOperatorQuery.replaceAll('_', ' ').toLowerCase();
    final metatag = metatagExtractor?.fromString(value);
    final query =
        metatag != null ? rawQuery.replaceFirst('$metatag:', '') : rawQuery;

    String replaceAndHighlight(String text) {
      return text.replaceAllMapped(
        RegExp(
          RegExp.escape(query),
          caseSensitive: false,
        ),
        (match) => '<b>${match.group(0)}</b>',
      );
    }

    return hasAlias
        ? '<p>${replaceAndHighlight(antecedent!.replaceAll('_', ' '))} ➞ ${replaceAndHighlight(label)}</p>'
        : '<p>${replaceAndHighlight(label.replaceAll('_', ' '))}</p>';
  }
}
