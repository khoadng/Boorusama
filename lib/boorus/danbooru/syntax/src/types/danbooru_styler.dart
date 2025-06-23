// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/search/syntax/src/types/common_tokens.dart';
import '../../../../../core/search/syntax/src/types/grammar_interface.dart';
import '../../../../../core/search/syntax/src/types/query_highlight_style.dart';
import 'danbooru_tokens.dart';

class DanbooruStyler extends TokenStyler<DanbooruTokenData> {
  @override
  InlineSpan styleToken(
    QueryToken<DanbooruTokenData> token,
    QueryHighlightStyle style,
  ) {
    return switch (token.data) {
      DanbooruCommonToken(:final data) => switch (data.type) {
          CommonTokenType.or => TextSpan(
              text: token.text,
              style: TextStyle(
                color: style.operator,
                fontWeight: FontWeight.bold,
              ),
            ),
          CommonTokenType.openParen ||
          CommonTokenType.closeParen =>
            _buildParenthesisSpan(token, style, data),
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

  TextSpan _buildParenthesisSpan(
    QueryToken<DanbooruTokenData> token,
    QueryHighlightStyle style,
    CommonTokenData data,
  ) {
    final color = style.groupingColor(data.level!);

    return TextSpan(
      text: token.text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        backgroundColor: data.isFocused ? color.withValues(alpha: 0.1) : null,
        shadows: data.isFocused
            ? [
                Shadow(color: color, offset: const Offset(-0.5, 0)),
                Shadow(color: color, offset: const Offset(0.5, 0)),
                Shadow(color: color, offset: const Offset(0, -0.5)),
                Shadow(color: color, offset: const Offset(0, 0.5)),
              ]
            : null,
      ),
    );
  }
}
