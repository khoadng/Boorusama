// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../core/search/syntax/types.dart';
import 'tokens.dart';

class GelbooruV2Parser extends QueryParser<GelbooruV2TokenData> {
  static final _tildeOperationRegex = RegExp(r'\(\s+[^)]*~[^)]*\s+\)');
  static final _tildeRegex = RegExp('~');

  @override
  List<QueryToken<GelbooruV2TokenData>> parseQuery(
    String query,
    MatchingContext context,
  ) {
    final tokens = <QueryToken<GelbooruV2TokenData>>[];

    try {
      tokens
        ..addAll(
          ParsingUtils.parseOrKeywords(
            query,
            const GelbooruV2CommonToken(
              CommonTokenData(type: CommonTokenType.or),
            ),
          ),
        )
        ..addAll(_parseTildeOperations(query, context.selection.baseOffset))
        ..addAll(
          _parseGroupingParentheses(query, context.selection.baseOffset),
        );
    } catch (e) {
      // Ignore failed tokens, continue with what we have
    }

    return tokens;
  }

  List<QueryToken<GelbooruV2TokenData>> _parseTildeOperations(
    String query,
    int cursorPos,
  ) {
    final tokens = <QueryToken<GelbooruV2TokenData>>[];
    final tildeOperationMatches = _tildeOperationRegex.allMatches(query);

    for (final match in tildeOperationMatches) {
      final content = match.group(0)!;
      final start = match.start;
      final end = match.end;

      // Check if cursor is inside this tilde operation
      final isFocused = cursorPos > start && cursorPos <= end;

      tokens
        ..add(
          QueryToken(
            start: start,
            end: start + 1,
            text: '(',
            data: GelbooruV2SpecificToken(
              GelbooruV2SpecificTokenData(
                type: GelbooruV2SpecificTokenType.tildeOpenParen,
                isFocused: isFocused,
              ),
            ),
          ),
        )
        ..add(
          QueryToken(
            start: end - 1,
            end: end,
            text: ')',
            data: GelbooruV2SpecificToken(
              GelbooruV2SpecificTokenData(
                type: GelbooruV2SpecificTokenType.tildeCloseParen,
                isFocused: isFocused,
              ),
            ),
          ),
        );

      // Parse tildes inside the operation
      final operationContent = content.substring(1, content.length - 1);
      final tildeMatches = _tildeRegex.allMatches(operationContent);

      for (final tildeMatch in tildeMatches) {
        tokens.add(
          QueryToken(
            start: start + 1 + tildeMatch.start,
            end: start + 1 + tildeMatch.end,
            text: '~',
            data: GelbooruV2SpecificToken(
              GelbooruV2SpecificTokenData(
                type: GelbooruV2SpecificTokenType.tilde,
                isFocused: isFocused,
              ),
            ),
          ),
        );
      }
    }

    return tokens;
  }

  List<QueryToken<GelbooruV2TokenData>> _parseGroupingParentheses(
    String query,
    int cursorPos,
  ) {
    // Find tilde operation positions to exclude from grouping parentheses
    final tildeOperationPositions = <int>{};
    for (final match in _tildeOperationRegex.allMatches(query)) {
      for (var i = match.start; i < match.end; i++) {
        tildeOperationPositions.add(i);
      }
    }

    final parenPairs = ParsingUtils.findParenthesesPairs(
      query,
      tildeOperationPositions,
    );

    final focusedPairIndex = ParsingUtils.findFocusedPair(
      parenPairs,
      cursorPos,
    );

    return ParsingUtils.createParenthesesTokens(
      parenPairs,
      focusedPairIndex,
      (data) => GelbooruV2CommonToken(data),
    );
  }
}
