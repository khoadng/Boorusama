// Project imports:
import '../types/common_tokens.dart';

class ParenPair {
  const ParenPair(
    this.openPos,
    this.closePos,
    this.level,
  );

  final int openPos;
  final int closePos;
  final int level;
}

class ParsingUtils {
  static final _orRegex = RegExp(r'\bor\b');

  static List<QueryToken<T>> parseOrKeywords<T>(
    String query,
    T orToken,
  ) {
    final tokens = <QueryToken<T>>[];
    for (final match in _orRegex.allMatches(query)) {
      tokens.add(
        QueryToken(
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          data: orToken,
        ),
      );
    }
    return tokens;
  }

  static int? findFocusedPair(List<ParenPair> pairs, int cursorPos) {
    int? focusedPairIndex;
    for (var i = 0; i < pairs.length; i++) {
      final pair = pairs[i];
      if (cursorPos > pair.openPos && cursorPos <= pair.closePos) {
        if (focusedPairIndex == null ||
            pairs[i].level > pairs[focusedPairIndex].level) {
          focusedPairIndex = i;
        }
      }
    }
    return focusedPairIndex;
  }

  static List<ParenPair> findParenthesesPairs(
    String query,
    Set<int> excludePositions,
  ) {
    final stack = <({int position, int level})>[];
    final parenPairs = <ParenPair>[];
    var currentLevel = 0;

    for (var i = 0; i < query.length; i++) {
      if (excludePositions.contains(i)) continue;

      if (query[i] == '(') {
        stack.add((position: i, level: currentLevel));
        currentLevel++;
      } else if (query[i] == ')' && stack.isNotEmpty) {
        final opening = stack.removeLast();
        currentLevel--;
        parenPairs.add(
          ParenPair(opening.position, i, opening.level),
        );
      }
    }

    return parenPairs;
  }

  static List<QueryToken<T>> createParenthesesTokens<T>(
    List<ParenPair> pairs,
    int? focusedPairIndex,
    T Function(CommonTokenData) createToken,
  ) {
    final tokens = <QueryToken<T>>[];

    for (var i = 0; i < pairs.length; i++) {
      final pair = pairs[i];
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
          data: createToken(openData),
        ),
        QueryToken(
          start: pair.closePos,
          end: pair.closePos + 1,
          text: ')',
          data: createToken(closeData),
        ),
      ]);
    }

    return tokens;
  }
}
