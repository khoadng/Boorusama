// Package imports:
import 'package:booru_clients/anime_pictures.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';

AutocompleteData autocompleteDtoToAutocompleteData(AutocompleteDto e) =>
    AutocompleteData(
      label: e.t?.toLowerCase() ?? '???',
      value: e.t?.toLowerCase() ?? '???',
      antecedent: e.t2?.toLowerCase(),
      category: animePicturesTagTypeToTagCategory(e.c).name,
    );

TagGroupItem animePicturesTagTypeToTagGroupItem(
  AnimePicturesTagType type, {
  required PostDetailsDto postDetails,
}) =>
    TagGroupItem(
      category: animePicturesTagTypeToTagCategory(type).id,
      groupName: _mapToGroupName(type),
      order: _mapToOrder(type),
      tags: postDetails.tags
              ?.where((e) => e.tag?.type == type)
              .nonNulls
              .map((e) => e.tag!)
              .map(
                (e) => Tag(
                  name: e.tag ?? '???',
                  category: animePicturesTagTypeToTagCategory(e.type),
                  postCount: e.num ?? 0,
                ),
              )
              .toList() ??
          [],
    );

TagCategory animePicturesTagTypeToTagCategory(AnimePicturesTagType? type) =>
    switch (type) {
      null => TagCategory.general(),
      AnimePicturesTagType.unknown => TagCategory.general(),
      AnimePicturesTagType.character => TagCategory.character(),
      AnimePicturesTagType.reference => TagCategory.general(),
      AnimePicturesTagType.copyrightProduct => TagCategory.copyright(),
      AnimePicturesTagType.author => TagCategory.artist(),
      AnimePicturesTagType.copyrightGame => TagCategory.copyright(),
      AnimePicturesTagType.copyrightOther => TagCategory.copyright(),
      AnimePicturesTagType.object => TagCategory.general(),
    };

int _mapToOrder(AnimePicturesTagType type) => switch (type) {
      AnimePicturesTagType.copyrightProduct => 0,
      AnimePicturesTagType.copyrightGame => 1,
      AnimePicturesTagType.copyrightOther => 2,
      AnimePicturesTagType.character => 3,
      AnimePicturesTagType.author => 4,
      AnimePicturesTagType.reference => 5,
      AnimePicturesTagType.object => 6,
      AnimePicturesTagType.unknown => 7,
    };

String _mapToGroupName(AnimePicturesTagType type) => switch (type) {
      AnimePicturesTagType.character => 'Character',
      AnimePicturesTagType.reference => 'Reference',
      AnimePicturesTagType.author => 'Author',
      AnimePicturesTagType.object => 'Object',
      AnimePicturesTagType.unknown => 'Unknown',
      AnimePicturesTagType.copyrightProduct => 'Copyright (Product)',
      AnimePicturesTagType.copyrightGame => 'Game Copyright',
      AnimePicturesTagType.copyrightOther => 'Other Copyright',
    };
