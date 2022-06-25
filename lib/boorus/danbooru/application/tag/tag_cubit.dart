// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/common/collection_utils.dart';

typedef TagCategoryOrder = int;

class TagGroupItem {
  TagGroupItem({
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;
}

String tagCategoryToString(TagCategory category) {
  switch (category) {
    case TagCategory.artist:
      return 'Artist';
    case TagCategory.charater:
      return 'Character';
    case TagCategory.copyright:
      return 'Copyright';
    case TagCategory.general:
      return 'General';
    case TagCategory.meta:
      return 'Meta';
    default:
      return '';
  }
}

class TagCubit extends Cubit<AsyncLoadState<List<TagGroupItem>>> {
  TagCubit({
    required this.tagRepository,
  }) : super(const AsyncLoadState.initial());

  final ITagRepository tagRepository;

  void getTagsByNameComma(String tagsComma) {
    tryAsync<List<Tag>>(
      action: () => tagRepository.getTagsByNameComma(tagsComma, 1),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onSuccess: (tags) async {
        tags.sort((a, b) => a.rawName.compareTo(b.rawName));
        final group = tags
            .groupBy((e) => e.category)
            .entries
            .map((e) => TagGroupItem(
                  groupName: tagCategoryToString(e.key),
                  tags: e.value,
                  order: tagCategoryToOrder(e.key),
                ))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        emit(AsyncLoadState.success(group));
      },
    );
  }
}

Color getTagColor(TagCategory category, ThemeMode themeMode) {
  final colors =
      themeMode == ThemeMode.light ? TagColors.light() : TagColors.dark();
  switch (category) {
    case TagCategory.artist:
      return colors.artist;
    case TagCategory.copyright:
      return colors.copyright;
    case TagCategory.charater:
      return colors.character;
    case TagCategory.general:
      return colors.general;
    case TagCategory.meta:
      return colors.meta;
    default:
      return colors.general;
  }
}

class TagColors {
  const TagColors({
    required this.artist,
    required this.character,
    required this.copyright,
    required this.general,
    required this.meta,
  });

  factory TagColors.light() => const TagColors(
        artist: _red3,
        character: _green3,
        copyright: _purple3,
        general: _azure4,
        meta: _yellow2,
      );

  factory TagColors.dark() => const TagColors(
        artist: _red6,
        character: _green4,
        copyright: _magenta6,
        general: _blue5,
        meta: _orange3,
      );

  // light theme
  static const _red3 = Color.fromARGB(255, 255, 138, 139);
  static const _purple3 = Color.fromARGB(255, 199, 151, 255);
  static const _green3 = Color.fromARGB(255, 53, 198, 74);
  static const _azure4 = Color.fromARGB(255, 0, 155, 230);
  static const _yellow2 = Color.fromARGB(255, 234, 208, 132);

  // dark theme
  static const _red6 = Color.fromARGB(255, 192, 0, 4);
  static const _magenta6 = Color.fromARGB(255, 168, 0, 170);
  static const _green4 = Color.fromARGB(255, 0, 171, 44);
  static const _blue5 = Color.fromARGB(255, 0, 177, 248);
  static const _orange3 = Color.fromARGB(255, 253, 146, 0);

  final Color artist;
  final Color general;
  final Color character;
  final Color copyright;
  final Color meta;
}

TagCategoryOrder tagCategoryToOrder(TagCategory category) {
  switch (category) {
    case TagCategory.artist:
      return 0;
    case TagCategory.copyright:
      return 1;
    case TagCategory.charater:
      return 2;
    case TagCategory.general:
      return 3;
    case TagCategory.meta:
      return 4;
    default:
      return 5;
  }
}
