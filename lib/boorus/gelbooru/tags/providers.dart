// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final gelbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTags(
          page: page,
          tags: tags,
        );

        return data.map(gelbooruTagDtoToTag).toList();
      },
    );
  },
);

final invalidTags = [
  ':&lt;',
];

final gelbooruTagGroupRepoProvider =
    Provider.family<TagGroupRepository<GelbooruPost>, BooruConfigAuth>(
  (ref, config) {
    final tagRepo = ref.watch(gelbooruTagRepoProvider(config));

    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        final tagList = post.tags;

        // filter tagList to remove invalid tags
        final filtered = tagList.where((e) => !invalidTags.contains(e)).toSet();

        if (filtered.isEmpty) return const [];

        final tags = await tagRepo.getTagsByName(filtered, 1);

        return createTagGroupItems(tags);
      },
    );
  },
);

final gelbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruClientProvider(config));

  return AutocompleteRepositoryBuilder(
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query.text, limit: 20);

      return dtos
          .map(autocompleteDtoToAutocompleteData)
          .where((e) => e != AutocompleteData.empty)
          .toList();
    },
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
  );
});
