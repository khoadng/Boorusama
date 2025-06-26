// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../core/search/syntax/providers.dart';
import '../../../../../core/search/syntax/syntax.dart';
import '../types/gelbooru_parser.dart';
import '../types/gelbooru_styler.dart';
import '../types/gelbooru_tokens.dart';

final gelbooruGrammarProvider =
    Provider<BooruGrammar<GelbooruTokenData>>((ref) {
  return BooruGrammar<GelbooruTokenData>(
    parser: GelbooruParser(),
    styler: GelbooruStyler(),
  );
});

final gelbooruQueryMatcherProvider = Provider<TextMatcher>(
  (ref) {
    return BooruQueryMatcher(
      grammar: ref.watch(gelbooruGrammarProvider),
      style: ref.watch(defaultQueryHighlightStyleProvider),
    );
  },
);
