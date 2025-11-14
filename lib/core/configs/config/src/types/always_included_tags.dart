// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

class AlwaysIncludedTags extends Equatable {
  const AlwaysIncludedTags._(this.tags);

  const AlwaysIncludedTags.empty() : tags = const [];

  factory AlwaysIncludedTags.fromList(List<String> tags) =>
      AlwaysIncludedTags._(tags);

  static AlwaysIncludedTags? parse(dynamic value) {
    return switch (value) {
      final AlwaysIncludedTags tags => tags,
      final String s => _parseFromJsonString(s),
      final List<String> tags => AlwaysIncludedTags._(tags),
      _ => null,
    };
  }

  static AlwaysIncludedTags? _parseFromJsonString(String jsonString) {
    if (jsonString.isEmpty) return null;

    try {
      return switch (jsonDecode(jsonString)) {
        final List<dynamic> list => AlwaysIncludedTags._(
          list.map((e) => e.toString()).toList(),
        ),
        _ => null,
      };
    } catch (e) {
      return null;
    }
  }

  final List<String> tags;

  List<String> get includedTags =>
      tags.where((e) => !e.startsWith('-')).toList();

  List<String> get excludedTags =>
      tags.where((e) => e.startsWith('-')).map((e) => e.substring(1)).toList();

  AlwaysIncludedTags addIncluded(String tag) {
    if (tag.isEmpty) return this;
    return AlwaysIncludedTags._([...tags, tag]);
  }

  AlwaysIncludedTags addExcluded(String tag) {
    if (tag.isEmpty) return this;
    return AlwaysIncludedTags._([...tags, '-$tag']);
  }

  AlwaysIncludedTags remove(String tag) {
    if (tag.isEmpty) return this;
    return AlwaysIncludedTags._(tags.where((e) => e != tag).toList());
  }

  String toJsonString() => jsonEncode(tags);

  @override
  List<Object?> get props => [tags];
}
