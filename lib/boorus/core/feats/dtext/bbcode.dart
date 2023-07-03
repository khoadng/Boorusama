part of 'dtext_grammar.dart';

Parser taggedElement(String tag) => (string('[$tag') &
        ref0(attribute).optional() &
        string(']') &
        (string('[/$tag]').not() & any()).star().flatten() &
        string('[/$tag]'))
    .map((value) => BBCode(tag, value[3], value[1]));

Parser attribute() => (char('=') & (char(']').not() & any()).star().flatten())
    .map((value) => value[1]);

Parser bbcode() =>
    ref1(taggedElement, 'b') |
    ref1(taggedElement, 'i') |
    ref1(taggedElement, 'u') |
    ref1(taggedElement, 's') |
    ref1(taggedElement, 'spoiler') |
    ref1(taggedElement, 'expand') |
    ref1(taggedElement, 'quote');

enum BBCodeTagType {
  bold,
  italic,
  underline,
  strikethrough,
  spoiler,
  expand,
  quote,
}

class BBCode {
  BBCode(
    this.tag,
    this.text,
    this.attributes,
  );
  final String tag;
  final String text;
  final String? attributes;

  BBCodeTagType get type => switch (tag) {
        'b' => BBCodeTagType.bold,
        'i' => BBCodeTagType.italic,
        'u' => BBCodeTagType.underline,
        's' => BBCodeTagType.strikethrough,
        'spoiler' => BBCodeTagType.spoiler,
        'expand' => BBCodeTagType.expand,
        'quote' => BBCodeTagType.quote,
        _ => throw Exception('Unknown tag type: $tag')
      };
}
