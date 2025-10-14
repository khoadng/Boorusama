// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/search/syntax/types.dart';
import 'danbooru_tokens.dart';

class DanbooruStyler extends TokenStyler<DanbooruTokenData> {
  @override
  InlineSpan styleToken(
    QueryToken<DanbooruTokenData> token,
    QueryHighlightStyle style,
  ) {
    return switch (token.data) {
      DanbooruCommonToken(:final data) => switch (data.type) {
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
      DanbooruSpecificToken(:final data) => switch (data.type) {
        DanbooruSpecificTokenType.tag => TextSpan(
          text: token.text,
          style: TextStyle(
            color: style.defaultColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      },
    };
  }
}
