// Package imports:
import 'package:equatable/equatable.dart';

class Wiki extends Equatable {
  const Wiki({
    required this.id,
    required this.title,
    required this.body,
    required this.otherNames,
    required this.type,
  });

  factory Wiki.empty() => const Wiki(
    body: '',
    id: 0,
    title: '',
    otherNames: [],
    type: UnknownWiki(),
  );

  final int id;
  final String title;
  final String body;
  final List<String> otherNames;
  final WikiType type;

  @override
  List<Object?> get props => [id, title, body, otherNames, type];
}

sealed class WikiType extends Equatable {
  const WikiType();

  factory WikiType.fromTitle(String title) {
    final prefix = _metaPrefixFor(title);
    if (prefix != null) {
      return MetaWiki(prefix: prefix);
    }

    return TagWiki(tag: title);
  }
}

final class TagWiki extends WikiType {
  const TagWiki({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

final class MetaWiki extends WikiType {
  const MetaWiki({
    required this.prefix,
  });

  final String prefix;

  @override
  List<Object?> get props => [prefix];
}

final class UnknownWiki extends WikiType {
  const UnknownWiki();

  @override
  List<Object?> get props => const [];
}

const _metaWikiPrefixes = [
  'list_of_',
  'tag_group:',
  'pool_group:',
  'howto:',
  'about:',
  'help:',
  'template:',
  'api:',
];

String? _metaPrefixFor(String title) {
  final normalizedTitle = title.toLowerCase();

  for (final prefix in _metaWikiPrefixes) {
    if (normalizedTitle.startsWith(prefix)) {
      return prefix;
    }
  }

  return null;
}
