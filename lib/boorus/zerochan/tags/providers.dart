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

final zerochanAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(zerochanClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v3',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final tags =
          await client.getAutocomplete(query: query.text.toLowerCase());

      return tags
          .where(
            // Can't search posts by meta tags for some reason
            (e) => e.type != 'Meta',
          )
          .map(autocompleteDtoToAutocompleteData)
          .toList();
    },
  );
});

final zerochanTagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, (BooruConfigAuth, int)>(
  (ref, params) async {
    final (config, id) = params;
    final client = ref.watch(zerochanClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data.where((e) => e.value != null).map(tagDtoToTag).toList();
  },
);

final zerochanTagGroupRepoProvider =
    Provider.family<TagGroupRepository<ZerochanPost>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        final params = (config, post.id);
        final tags = await ref.read(zerochanTagsFromIdProvider(params).future);

        return createTagGroupItems(tags);
      },
    );
  },
);
