// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

typedef TagCategoryOrder = int;

const _artistTag = TagCategory(
  id: 1,
  order: 0,
  name: 'artist',
);

const _copyrightTag = TagCategory(
  id: 3,
  order: 1,
  name: 'copyright',
);

const _characterTag = TagCategory(
  id: 4,
  order: 2,
  name: 'character',
);

const _generalTag = TagCategory(
  id: 0,
  order: 3,
  name: 'general',
);

const _metaTag = TagCategory(
  id: 5,
  order: 4,
  name: 'meta',
);

const _unknownTag = TagCategory(
  id: -1,
  name: 'unknown',
);

class TagCategory extends Equatable {
  const TagCategory({
    required this.id,
    required this.name,
    this.order,
    this.darkColor,
    this.lightColor,
  });

  factory TagCategory.unknown() => _unknownTag;
  factory TagCategory.artist() => _artistTag;
  factory TagCategory.copyright() => _copyrightTag;
  factory TagCategory.general() => _generalTag;
  factory TagCategory.character() => _characterTag;
  factory TagCategory.meta() => _metaTag;

  factory TagCategory.fromLegacyIdString(String? id) => switch (id) {
        '0' || 'tag' => _generalTag,
        '1' || 'artist' => _artistTag,
        '3' || 'copyright' => _copyrightTag,
        '4' || 'character' => _characterTag,
        '5' || 'metadata' || 'meta' => _metaTag,
        _ => _unknownTag,
      };

  factory TagCategory.fromLegacyId(int? id) =>
      TagCategory.fromLegacyIdString(id?.toString());

  final int id;
  final String name;
  final TagCategoryOrder? order;
  final Color? darkColor;
  final Color? lightColor;

  @override
  List<Object?> get props => [id, name, darkColor, lightColor];
}

extension BooruTagCategoryConverterX on TagCategory {
  String stringify() => id.toString();
}
