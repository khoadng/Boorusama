// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'common_tokens.dart';
import 'query_highlight_style.dart';

abstract class QueryParser<T> {
  List<QueryToken<T>> parseQuery(String query, MatchingContext context);
}

abstract class TokenStyler<T> {
  InlineSpan styleToken(QueryToken<T> token, QueryHighlightStyle style);
}

abstract class CursorBehavior<T> {
  TextSelection adjustSelection(
    TextSelection selection,
    MatchingContext context,
    List<QueryToken<T>> tokens,
  );
}

class BooruGrammar<T> {
  BooruGrammar({
    required this.parser,
    required this.styler,
    this.cursorBehavior,
  });

  final QueryParser<T> parser;
  final TokenStyler<T> styler;
  final CursorBehavior<T>? cursorBehavior;
}
