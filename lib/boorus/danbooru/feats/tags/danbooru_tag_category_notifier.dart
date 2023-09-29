// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/functional.dart';
import 'tags_provider.dart';

class DanbooruTagCategoryNotifier extends Notifier<IMap<String, TagCategory>> {
  @override
  IMap<String, TagCategory> build() {
    return <String, TagCategory>{}.lock;
  }

  Future<void> save(List<String> tags) async {
    final categoryRepo = ref.read(danbooruTagCategoryRepoProvider);
    final tagRepo = ref.read(danbooruTagRepoProvider);

    final unknownCategories = <String>[];
    final knownCategories = <String, TagCategory>{};

    for (final tag in tags) {
      final category = await categoryRepo.get(tag);
      if (category == null) {
        unknownCategories.add(tag);
      } else {
        knownCategories[tag] = category;
      }
    }

    if (unknownCategories.isNotEmpty) {
      final unknownTags = await tagRepo.getTagsByName(unknownCategories, 1);

      for (final tag in unknownTags) {
        await categoryRepo.save(tag.name, tag.category);
        knownCategories[tag.name] = tag.category;
      }
    }

    state = state.addMap(knownCategories);
  }
}
