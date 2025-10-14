// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/types.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import '../posts/providers.dart';
import 'parser.dart';

final animePicturesTagsFromIdProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, int)>(
      (ref, params) async {
        ref.cacheFor(const Duration(minutes: 5));

        final (config, id) = params;

        final postDetails = await ref.read(
          postDetailsProvider((config, id)).future,
        );

        return postDetails.tags
                ?.map((e) => e.tag)
                .nonNulls
                .map(tagDtoToTag)
                .toList() ??
            const <Tag>[];
      },
    );

final animePicturesAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(animePicturesClientProvider(config));

        return AutocompleteRepositoryBuilder(
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
        siteHost: config.url,
        tagCache: ref.watch(tagCacheRepositoryProvider.future),
        sorter: TagSorter.defaults(),
        fetcher: (post, options) {
          return ref.read(
            animePicturesTagsFromIdProvider((config, post.id)).future,
          );
        },
      );
    });
