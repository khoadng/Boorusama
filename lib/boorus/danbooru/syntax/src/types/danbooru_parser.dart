// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../core/search/syntax/syntax.dart';
import 'danbooru_tokens.dart';

class DanbooruParser extends QueryParser<DanbooruTokenData> {
  static final _tagRegex = RegExp(r'[a-zA-Z0-9_]+_\([^)]*\)');

  @override
  List<QueryToken<DanbooruTokenData>> parseQuery(
    String query,
    MatchingContext context,
  ) {
    final tokens = <QueryToken<DanbooruTokenData>>[];

    try {
      tokens
        ..addAll(
          ParsingUtils.parseOrKeywords(
            query,
            const DanbooruCommonToken(
              CommonTokenData(type: CommonTokenType.or),
            ),
          ),
        )
        ..addAll(_parseParentheses(query, context.selection.baseOffset));
    } catch (e) {
      // Ignore failed tokens, continue with what we have
    }

    return tokens;
  }

  List<QueryToken<DanbooruTokenData>> _parseParentheses(
    String query,
    int cursorPos,
  ) {
    // Find tag parentheses to exclude from grouping
    final tagParenPositions = <int>{};
    for (final match in _tagRegex.allMatches(query)) {
      final tagText = match.group(0)!;
      final separatorIndex = tagText.indexOf('_(');
      if (separatorIndex != -1) {
        final parenStart = match.start + separatorIndex + 1;
        final parenEnd = match.end - 1;
        tagParenPositions.addAll([parenStart, parenEnd]);
      }
    }

    final parenPairs = ParsingUtils.findParenthesesPairs(
      query,
      tagParenPositions,
    );

    final focusedPairIndex = ParsingUtils.findFocusedPair(
      parenPairs,
      cursorPos,
    );

    return ParsingUtils.createParenthesesTokens(
      parenPairs,
      focusedPairIndex,
      (data) => DanbooruCommonToken(data),
    );
  }
}
