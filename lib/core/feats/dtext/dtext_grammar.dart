// Package imports:
import 'package:petitparser/petitparser.dart';

part 'common.dart';
part 'link.dart';
part 'bbcode.dart';
part 'line_break.dart';

class DTextGrammarDefinition extends GrammarDefinition {
  DTextGrammarDefinition({
    required this.tagSearchUrl,
  });

  final String tagSearchUrl;

  @override
  Parser start() => ref0(document);

  Parser document() => (ref0(bbcode) |
          ref0(link) |
          ref1(internalLink, tagSearchUrl) |
          ref0(lineBreak) |
          ref0(normalText))
      .star();

  Parser normalText() => (ref0(bbcode).not() &
          ref0(lineBreak).not() &
          ref1(internalLink, tagSearchUrl).not() &
          ref0(link).not() &
          any())
      .plus()
      .flatten();
}
