// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import '../posts/providers.dart';
import 'parser.dart';

final animePicturesAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(animePicturesClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query.text);

        return tags.map(autocompleteDtoToAutocompleteData).toList();
      },
    );
  },
);

final animePicturesTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>((ref, config) {
  return TagExtractorBuilder(
    sorter: TagSorter.defaults(),
    fetcher: (post, options) async {
      final postDetails =
          await ref.read(postDetailsProvider((config, post.id)).future);

      return postDetails.tags
              ?.map((e) => e.tag)
              .nonNulls
              .map(tagDtoToTag)
              .toList() ??
          const <Tag>[];
    },
  );
});
