// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
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
    ref.cacheFor(const Duration(minutes: 1));

    final (config, id) = params;
    final client = ref.watch(zerochanClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data.where((e) => e.value != null).map(tagDtoToTag).toList();
  },
);

final zerochanTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
  (ref, config) {
    return TagExtractorBuilder(
      sorter: TagSorter.defaults(),
      fetcher: (post, options) async {
        final tags = await ref
            .read(zerochanTagsFromIdProvider((config, post.id)).future);

        return tags;
      },
    );
  },
);
