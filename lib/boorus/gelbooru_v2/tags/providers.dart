// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final gelbooruV2TagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfigAuth;
    final client = ref.watch(gelbooruV2ClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data.map(mapGelbooruV2TagDtoToTag).toList();
  },
);

final gelbooruV2TagGroupRepoProvider =
    Provider.family<TagGroupRepository<GelbooruV2Post>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post, options) async {
        final tags =
            await ref.read(gelbooruV2TagsFromIdProvider(post.id).future);

        return createTagGroupItems(tags);
      },
    );
  },
);

final gelbooruV2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruV2ClientProvider(config));

  return AutocompleteRepositoryBuilder(
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query.text, limit: 20);

      return dtos
          .map(mapGelbooruV2AutocompleteDtoToData)
          .where((e) => e != AutocompleteData.empty)
          .toList();
    },
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
  );
});
