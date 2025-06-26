// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/search/syntax/syntax.dart';
import 'gelbooru_v2_tokens.dart';

class GelbooruV2Styler extends TokenStyler<GelbooruV2TokenData> {
  @override
  InlineSpan styleToken(
    QueryToken<GelbooruV2TokenData> token,
    QueryHighlightStyle style,
  ) {
    return switch (token.data) {
      GelbooruV2CommonToken(:final data) => switch (data.type) {
          CommonTokenType.or => StylingUtils.buildOperatorSpan(
              token.text,
              style.operator,
            ),
          CommonTokenType.openParen ||
          CommonTokenType.closeParen =>
            StylingUtils.buildParenthesisSpan(
              token.text,
              style.groupingColor(data.level),
              data.isFocused,
            ),
        },
      GelbooruV2SpecificToken(:final data) => switch (data.type) {
          GelbooruV2SpecificTokenType.tilde => StylingUtils.buildOperatorSpan(
              token.text,
              style.operator,
            ),
          GelbooruV2SpecificTokenType.tildeOpenParen ||
          GelbooruV2SpecificTokenType.tildeCloseParen =>
            StylingUtils.buildFocusableSpan(
              token.text,
              style.operator,
              data.isFocused,
            ),
        },
    };
  }
}
