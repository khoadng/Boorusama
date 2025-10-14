// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final eshuushuuAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(eshuushuuClientProvider(config));

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) async {
          final type = TagType.tryParse(query.category) ?? TagType.tag;
          final tags = await client.getAutocomplete(
            query: query.text.toLowerCase(),
            type: type,
          );

          return tags
              .map((e) => autocompleteDtoToAutocompleteData(e, type))
              .toList();
        },
      );
    });

final eshuushuuTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) {
            if (post case final EshuushuuPost eshuushuuPost) {
              return [
                ...?eshuushuuPost.artist?.map(
                  (e) => Tag.noCount(name: e, category: TagCategory.artist()),
                ),
                ...?eshuushuuPost.characters?.map(
                  (e) =>
                      Tag.noCount(name: e, category: TagCategory.character()),
                ),
                ...?eshuushuuPost.sourceTags?.map(
                  (e) =>
                      Tag.noCount(name: e, category: TagCategory.copyright()),
                ),
                ...?eshuushuuPost.generalTags?.map(
                  (e) => Tag.noCount(name: e, category: TagCategory.general()),
                ),
              ];
            } else {
              return TagExtractor.extractTagsFromGenericPost(post);
            }
          },
        );
      },
    );
