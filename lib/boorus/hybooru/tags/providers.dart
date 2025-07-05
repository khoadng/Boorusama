// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final hybooruTagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, (BooruConfigAuth, int)>(
  (ref, params) async {
    ref.cacheFor(const Duration(minutes: 5));

    final (config, id) = params;
    final client = ref.watch(hybooruClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data.map(tagDtoToTag).toList();
  },
);

final hybooruTagGroupRepoProvider =
    Provider.family<TagGroupRepository<HybooruPost>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        final params = (config, post.id);
        final tags = await ref.read(hybooruTagsFromIdProvider(params).future);

        return createTagGroupItems(tags);
      },
    );
  },
);

final hybooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(hybooruClientProvider(config));

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
