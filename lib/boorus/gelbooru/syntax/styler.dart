// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/search/syntax/syntax.dart';
import 'tokens.dart';

class GelbooruStyler extends TokenStyler<GelbooruTokenData> {
  @override
  InlineSpan styleToken(
    QueryToken<GelbooruTokenData> token,
    QueryHighlightStyle style,
  ) {
    return switch (token.data) {
      GelbooruCommonToken(:final data) => switch (data.type) {
        CommonTokenType.or => StylingUtils.buildOperatorSpan(
          token.text,
          style.operator,
        ),
        CommonTokenType.openParen ||
        CommonTokenType.closeParen => StylingUtils.buildParenthesisSpan(
          token.text,
          style.groupingColor(data.level),
          data.isFocused,
        ),
      },
      GelbooruSpecificToken(:final data) => switch (data.type) {
        GelbooruSpecificTokenType.tilde => StylingUtils.buildOperatorSpan(
          token.text,
          style.operator,
        ),
        GelbooruSpecificTokenType.openBrace ||
        GelbooruSpecificTokenType.closeBrace => StylingUtils.buildFocusableSpan(
          token.text,
          style.operator,
          data.isFocused,
        ),
      },
    };
  }
}
