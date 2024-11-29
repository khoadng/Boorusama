// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/functional.dart';

final danbooruClientProvider =
    Provider.family<DanbooruClient, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return DanbooruClient(
    dio: dio,
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
  );
});

final danbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      persistentStaleDuration: const Duration(days: 1),
      autocomplete: (query) async {
        final dtos = await client.autocomplete(query: query);

        return dtos
            .map((e) {
              try {
                if (AutocompleteData.isTagType(e.type)) {
                  return AutocompleteData(
                    type: e.type,
                    label: e.label!,
                    value: e.value!,
                    category: e.category?.toString(),
                    postCount: e.postCount,
                    antecedent: e.antecedent,
                  );
                } else if (e.type == AutocompleteData.pool) {
                  return AutocompleteData(
                    type: e.type,
                    label: e.label!,
                    value: e.value!,
                    category: e.category,
                    postCount: e.postCount,
                  );
                } else if (e.type == AutocompleteData.user) {
                  return AutocompleteData(
                    type: e.type,
                    label: e.label!,
                    value: e.value!,
                    level: e.level,
                  );
                } else {
                  return AutocompleteData(label: e.label!, value: e.value!);
                }
              } catch (err) {
                return AutocompleteData.empty;
              }
            })
            .where((e) => e != AutocompleteData.empty)
            .toList();
      });
});

final danbooruTagListProvider = NotifierProviderFamily<
    DanbooruTagListNotifier,
    IMap<int, DanbooruTagDetails>,
    BooruConfigAuth>(DanbooruTagListNotifier.new);

class DanbooruTagListNotifier
    extends FamilyNotifier<IMap<int, DanbooruTagDetails>, BooruConfigAuth> {
  @override
  IMap<int, DanbooruTagDetails> build(BooruConfigAuth arg) {
    return <int, DanbooruTagDetails>{}.lock;
  }

  Future<void> setTags(
    int postId, {
    List<String>? addedTags,
    List<String>? removedTags,
    Rating? rating,
  }) async {
    if (addedTags == null && removedTags == null && rating == null) {
      return;
    }
    final tags = [
      ...addedTags ?? <String>[],
      ...removedTags?.map((e) => '-$e') ?? <String>[],
      if (rating != null) 'rating:${rating.name}',
    ];

    final client = ref.read(danbooruClientProvider(arg));

    final post = await client
        .putTags(postId: postId, tags: tags)
        .then(postDtoToPostNoMetadata);

    ref.read(loggerProvider).logI(
        'Tag Edit',
        [
          if (addedTags != null && addedTags.isNotEmpty) 'Added: $addedTags',
          if (removedTags != null && removedTags.isNotEmpty)
            'Removed: $removedTags',
          if (rating != null) 'Rating changed: ${rating.name}',
        ].join(', '));

    state = state.add(postId, post);
  }

  void removeTags(List<int> postIds) {
    state = state.removeWhere((key, value) => postIds.contains(key));
  }
}

final metatagsProvider = Provider<Set<Metatag>>(
  (ref) => ref.watch(tagInfoProvider).metatags,
  dependencies: [tagInfoProvider],
);
