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

final sankakuTagGroupRepoProvider =
    Provider.family<TagGroupRepository<SankakuPost>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        return createTagGroupItems([
          ...post.artistDetailsTags,
          ...post.characterDetailsTags,
          ...post.copyrightDetailsTags,
          ...post.generalDetailsTags,
          ...post.metaDetailsTags,
        ]);
      },
    );
  },
);
