// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../core/search/syntax/providers.dart';
import '../../../core/search/syntax/syntax.dart';
import 'parser.dart';
import 'styler.dart';
import 'tokens.dart';

final gelbooruV2GrammarProvider =
    Provider<BooruGrammar<GelbooruV2TokenData>>((ref) {
  return BooruGrammar<GelbooruV2TokenData>(
    parser: GelbooruV2Parser(),
    styler: GelbooruV2Styler(),
  );
});

final gelbooruV2QueryMatcherProvider = Provider<TextMatcher>(
  (ref) {
    return BooruQueryMatcher(
      grammar: ref.watch(gelbooruV2GrammarProvider),
      style: ref.watch(defaultQueryHighlightStyleProvider),
    );
  },
);
