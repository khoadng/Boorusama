// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/metatag/types.dart';
import '../../../core/tags/metatag/widgets.dart';
import '../../../core/tags/tag/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'metatags.dart';
import 'parser.dart';

final sankakuMetatagExtractorProvider = Provider<MetatagExtractor>(
  (ref) =>
      DefaultMetatagExtractor(metatags: Set.unmodifiable(kSankakuMetatags)),
);

final sankakuQueryMatcherProvider = Provider<TextMatcher>((ref) {
  final extractor = ref.watch(sankakuMetatagExtractorProvider);
  final words = RegExp(r'\S+');
  return FunctionMatcher(
    finder: (context) {
      final matches = <MatchResult>[];
      for (final word in words.allMatches(context.fullText)) {
        final text = word.group(0)!;
        final prefix = extractor.fromString(text);
        if (prefix == null) continue;
        final end = word.start + text.indexOf(':') + 1;
        matches.add(
          MatchResult(
            start: end - prefix.length - 1,
            end: end,
            text: '$prefix:',
            priority: 0,
          ),
        );
      }
      return matches;
    },
    spanBuilder: (match) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: MetatagContainer(tag: match.text),
    ),
  );
});

final sankakuAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(sankakuClientProvider(config));

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) => client
            .getAutocomplete(query: query.text)
            .then(
              (value) => value
                  .map(
                    tagDtoToAutocompleteData,
                  )
                  .toList(),
            ),
      );
    });

final sankakuTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) {
            if (post case final SankakuPost sankakuPost) {
              return sankakuPost.detailedTags;
            } else {
              return TagExtractor.extractTagsFromGenericPost(post);
            }
          },
        );
      },
    );
