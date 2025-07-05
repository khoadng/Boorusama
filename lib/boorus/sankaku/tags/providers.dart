// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final sankakuAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(sankakuClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    autocomplete: (query) => client.getAutocomplete(query: query.text).then(
          (value) => value
              .map(
                tagDtoToAutocompleteData,
              )
              .toList(),
        ),
  );
});

final sankakuTagExtractorProvider =
    Provider.family<TagExtractor<SankakuPost>, BooruConfigAuth>(
  (ref, config) {
    return TagExtractorBuilder(
      sorter: TagSorter.defaults(),
      fetcher: (post, options) {
        if (post case final SankakuPost sankakuPost) {
          return [
            ...sankakuPost.artistDetailsTags,
            ...sankakuPost.characterDetailsTags,
            ...sankakuPost.copyrightDetailsTags,
            ...sankakuPost.generalDetailsTags,
            ...sankakuPost.metaDetailsTags,
          ];
        } else {
          return TagExtractor.extractTagsFromGenericPost(post);
        }
      },
    );
  },
);
