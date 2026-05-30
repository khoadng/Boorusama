enum DTextTokenType {
  text,
  newline,
  openTag,
  closeTag,
  link,
  wikiLink,
  postSearchLink,
  idLink,
  mention,
  entity,
  eof,
}

class DTextToken {
  const DTextToken({
    required this.type,
    required this.lexeme,
    required this.offset,
  });

  final DTextTokenType type;
  final String lexeme;
  final int offset;

  @override
  String toString() => 'DTextToken($type, "$lexeme", $offset)';
}
