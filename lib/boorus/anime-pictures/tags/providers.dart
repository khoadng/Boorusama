// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import '../posts/providers.dart';
import '../posts/types.dart';
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

final animePictureTagGroupRepoProvider =
    Provider.family<TagGroupRepository<AnimePicturesPost>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        final postDetails =
            await ref.read(postDetailsProvider((config, post.id)).future);

        final tagGroups = <TagGroupItem>[
          for (final c in AnimePicturesTagType.values)
            animePicturesTagTypeToTagGroupItem(
              c,
              postDetails: postDetails,
            ),
        ]..sort((a, b) => a.order.compareTo(b.order));

        final filtered = tagGroups.where((e) => e.tags.isNotEmpty).toList();

        return filtered;
      },
    );
  },
);
