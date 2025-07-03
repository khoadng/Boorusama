// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../foundation/utils/color_utils.dart';
import '../client_provider.dart';
import '../posts/types.dart';

final szurubooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.autocomplete(query: query.text);

        final categories =
            await ref.read(szurubooruTagCategoriesProvider(config).future);

        return tags
            .map(
              (e) => AutocompleteData(
                label:
                    e.names?.firstOrNull?.toLowerCase().replaceAll('_', ' ') ??
                        '???',
                value: e.names?.firstOrNull?.toLowerCase() ?? '???',
                category: categories
                    .firstWhereOrNull((element) => element.name == e.category)
                    ?.name,
                postCount: e.usages,
              ),
            )
            .toList();
      },
    );
  },
);

final szurubooruTagCategoriesProvider =
    FutureProvider.family<List<TagCategory>, BooruConfigAuth>(
  (ref, config) async {
    final client = ref.read(szurubooruClientProvider(config));

    final categories = await client.getTagCategories();

    return categories
        .mapIndexed(
          (index, e) => TagCategory(
            id: index,
            name: e.name ?? '???',
            order: e.order,
            darkColor: ColorUtils.hexToColor(e.color),
            lightColor: ColorUtils.hexToColor(e.color),
          ),
        )
        .toList();
  },
);

final szurubooruTagGroupRepoProvider =
    Provider.family<TagGroupRepository<SzurubooruPost>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        return createTagGroupItems(post.tagDetails);
      },
    );
  },
);
