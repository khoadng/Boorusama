// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'grammar_interface.dart';
import 'query_highlight_style.dart';

class BooruQueryMatcher extends FunctionMatcher {
  BooruQueryMatcher({
    required BooruGrammar grammar,
    required this.style,
    super.priority,
    super.options,
  }) : _grammar = grammar,
       super(
         finder: (context) => _parseToMatchResults(grammar, context),
         spanBuilder: (candidate) => _buildSpan(grammar, candidate, style),
       );

  final BooruGrammar _grammar;
  final QueryHighlightStyle style;

  static List<MatchResult> _parseToMatchResults(
    BooruGrammar grammar,
    MatchingContext context,
  ) {
    final tokens = grammar.parser.parseQuery(context.fullText, context);
    return tokens
        .map(
          (token) => MatchResult(
            start: token.start,
            end: token.end,
            text: token.text,
            priority: 0,
            data: {'token': token, 'allTokens': tokens},
          ),
        )
        .toList();
  }

  static InlineSpan _buildSpan(
    BooruGrammar grammar,
    MatchCandidate candidate,
    QueryHighlightStyle style,
  ) {
    final token = candidate.data['token'];
    return grammar.styler.styleToken(token, style);
  }

  @override
  TextSelection adjustSelection(
    TextSelection selection,
    MatchingContext context,
  ) {
    final cursorBehavior = _grammar.cursorBehavior;
    if (cursorBehavior == null) return selection;

    final tokens = _grammar.parser.parseQuery(context.fullText, context);
    return cursorBehavior.adjustSelection(selection, context, tokens);
  }
}
