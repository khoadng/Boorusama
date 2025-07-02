// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../core/search/syntax/syntax.dart';
import 'tokens.dart';

class GelbooruParser extends QueryParser<GelbooruTokenData> {
  static final _tildeRegex = RegExp('~');
  static final _braceContentRegex = RegExp(r'\{[^}]*\}');

  @override
  List<QueryToken<GelbooruTokenData>> parseQuery(
    String query,
    MatchingContext context,
  ) {
    final tokens = <QueryToken<GelbooruTokenData>>[];

    try {
      tokens
        ..addAll(
          ParsingUtils.parseOrKeywords(
            query,
            const GelbooruCommonToken(
              CommonTokenData(type: CommonTokenType.or),
            ),
          ),
        )
        ..addAll(_parseBraces(query, context.selection.baseOffset))
        ..addAll(
          _parseGroupingParentheses(query, context.selection.baseOffset),
        );
    } catch (e) {
      // Ignore failed tokens, continue with what we have
    }

    return tokens;
  }

  List<QueryToken<GelbooruTokenData>> _parseBraces(
    String query,
    int cursorPos,
  ) {
    final tokens = <QueryToken<GelbooruTokenData>>[];
    final braceContentMatches = _braceContentRegex.allMatches(query);

    for (final match in braceContentMatches) {
      final content = match.group(0)!;
      final start = match.start;
      final end = match.end;

      // Check if cursor is inside this brace pair
      final isFocused = cursorPos > start && cursorPos <= end;

      tokens
        ..add(
          QueryToken(
            start: start,
            end: start + 1,
            text: '{',
            data: GelbooruSpecificToken(
              GelbooruSpecificTokenData(
                type: GelbooruSpecificTokenType.openBrace,
                isFocused: isFocused,
              ),
            ),
          ),
        )
        ..add(
          QueryToken(
            start: end - 1,
            end: end,
            text: '}',
            data: GelbooruSpecificToken(
              GelbooruSpecificTokenData(
                type: GelbooruSpecificTokenType.closeBrace,
                isFocused: isFocused,
              ),
            ),
          ),
        );

      // Parse tildes inside braces
      final braceContent = content.substring(1, content.length - 1);
      final tildeMatches = _tildeRegex.allMatches(braceContent);

      for (final tildeMatch in tildeMatches) {
        tokens.add(
          QueryToken(
            start: start + 1 + tildeMatch.start,
            end: start + 1 + tildeMatch.end,
            text: '~',
            data: GelbooruSpecificToken(
              GelbooruSpecificTokenData(
                type: GelbooruSpecificTokenType.tilde,
                isFocused: isFocused,
              ),
            ),
          ),
        );
      }
    }

    return tokens;
  }

  List<QueryToken<GelbooruTokenData>> _parseGroupingParentheses(
    String query,
    int cursorPos,
  ) {
    // Find brace positions to exclude from grouping parentheses
    final bracePositions = <int>{};
    for (final match in _braceContentRegex.allMatches(query)) {
      for (var i = match.start; i < match.end; i++) {
        bracePositions.add(i);
      }
    }

    final parenPairs = ParsingUtils.findParenthesesPairs(query, bracePositions);
    final focusedPairIndex =
        ParsingUtils.findFocusedPair(parenPairs, cursorPos);
    return ParsingUtils.createParenthesesTokens(
      parenPairs,
      focusedPairIndex,
      (data) => GelbooruCommonToken(data),
    );
  }
}
