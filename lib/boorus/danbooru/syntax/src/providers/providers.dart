// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../core/search/syntax/providers.dart';
import '../../../../../core/search/syntax/types.dart';
import '../types/danbooru_parser.dart';
import '../types/danbooru_styler.dart';
import '../types/danbooru_tokens.dart';

final danbooruGrammarProvider = Provider<BooruGrammar<DanbooruTokenData>>((
  ref,
) {
  return BooruGrammar<DanbooruTokenData>(
    parser: DanbooruParser(),
    styler: DanbooruStyler(),
  );
});

final danbooruQueryMatcherProvider = Provider<TextMatcher>(
  (ref) {
    return BooruQueryMatcher(
      grammar: ref.watch(danbooruGrammarProvider),
      style: ref.watch(defaultQueryHighlightStyleProvider),
    );
  },
);
