// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart';
import 'package:boorusama/common/collection_utils.dart';

class TagGroupItem {
  TagGroupItem({
    required this.groupName,
    required this.tags,
  });

  final String groupName;
  final List<Tag> tags;
}

String tagCategoryToString(TagCategory category) {
  switch (category) {
    case TagCategory.artist:
      return "Artist";
    case TagCategory.charater:
      return "Character";
    case TagCategory.copyright:
      return "Copyright";
    case TagCategory.general:
      return "General";
    case TagCategory.meta:
      return "Meta";
    default:
      return '';
  }
}

class TagCubit extends Cubit<AsyncLoadState<List<TagGroupItem>>> {
  TagCubit({
    required this.tagRepository,
  }) : super(AsyncLoadState.initial());

  final ITagRepository tagRepository;

  void getTagsByNameComma(String tagStringComma) {
    TryAsync<List<Tag>>(
      action: () => tagRepository.getTagsByNameComma(tagStringComma, 1),
      onLoading: () => emit(AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onSuccess: (tags) {
        tags.sort((a, b) => a.rawName.compareTo(b.rawName));
        final group = tags
            .groupBy((e) => e.category)
            .entries
            .map((e) => TagGroupItem(
                groupName: tagCategoryToString(e.key), tags: e.value))
            .toList();

        emit(AsyncLoadState.success(group));
      },
    );
  }
}
