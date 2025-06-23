// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../core/search/syntax/src/types/common_tokens.dart';
import '../../../../../core/search/syntax/src/types/grammar_interface.dart';
import 'danbooru_tokens.dart';

class DanbooruParser extends QueryParser<DanbooruTokenData> {
  static final _orRegex = RegExp(r'\bor\b');
  static final _tagRegex = RegExp(r'[a-zA-Z0-9_]+_\([^)]*\)');

  @override
  List<QueryToken<DanbooruTokenData>> parseQuery(
    String query,
    MatchingContext context,
  ) {
    final tokens = <QueryToken<DanbooruTokenData>>[];

    try {
      // Parse OR keywords
      for (final match in _orRegex.allMatches(query)) {
        tokens.add(
          QueryToken(
            start: match.start,
            end: match.end,
            text: match.group(0)!,
            data: const DanbooruCommonToken(
              CommonTokenData(type: CommonTokenType.or),
            ),
          ),
        );
      }

      // Parse parentheses with focus detection
      tokens.addAll(_parseParentheses(query, context.selection.baseOffset));
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

    // Find grouping parentheses pairs
    final stack = <({int position, int level})>[];
    final parenPairs = <({int openPos, int closePos, int level})>[];
    var currentLevel = 0;

    for (var i = 0; i < query.length; i++) {
      if (query[i] == '(' && !tagParenPositions.contains(i)) {
        stack.add((position: i, level: currentLevel));
        currentLevel++;
      } else if (query[i] == ')' &&
          !tagParenPositions.contains(i) &&
          stack.isNotEmpty) {
        final opening = stack.removeLast();
        currentLevel--;
        parenPairs.add(
          (
            openPos: opening.position,
            closePos: i,
            level: opening.level,
          ),
        );
      }
    }

    // Find focused pair (innermost containing cursor)
    int? focusedPairIndex;
    for (var i = 0; i < parenPairs.length; i++) {
      final pair = parenPairs[i];
      if (cursorPos > pair.openPos && cursorPos <= pair.closePos) {
        if (focusedPairIndex == null ||
            parenPairs[i].level > parenPairs[focusedPairIndex].level) {
          focusedPairIndex = i;
        }
      }
    }

    // Create tokens
    final tokens = <QueryToken<DanbooruTokenData>>[];
    for (var i = 0; i < parenPairs.length; i++) {
      final pair = parenPairs[i];
      final isFocused = i == focusedPairIndex;
      final openData = CommonTokenData(
        type: CommonTokenType.openParen,
        level: pair.level,
        isFocused: isFocused,
      );
      final closeData = openData.copyWith(type: CommonTokenType.closeParen);

      tokens.addAll([
        QueryToken(
          start: pair.openPos,
          end: pair.openPos + 1,
          text: '(',
          data: DanbooruCommonToken(openData),
        ),
        QueryToken(
          start: pair.closePos,
          end: pair.closePos + 1,
          text: ')',
          data: DanbooruCommonToken(closeData),
        ),
      ]);
    }

    return tokens;
  }
}
