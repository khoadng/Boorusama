part of 'dtext_grammar.dart';

Parser lineBreak() => string(r'\r\n').map((value) => const LineBreakElement());

class LineBreakElement {
  const LineBreakElement();
}
