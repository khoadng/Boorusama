enum TagType {
  tag(1, 'tag'),
  source(2, 'source'),
  artist(3, 'artist'),
  character(4, 'character');

  static TagType? tryParse(dynamic value) => switch (value) {
    int i => switch (i) {
      1 => TagType.tag,
      2 => TagType.source,
      3 => TagType.artist,
      4 => TagType.character,
      _ => null,
    },
    String s => switch (s.toLowerCase()) {
      '1' || 'tag' => TagType.tag,
      '2' || 'source' => TagType.source,
      '3' || 'artist' => TagType.artist,
      '4' || 'character' => TagType.character,
      _ => null,
    },
    _ => null,
  };

  const TagType(
    this.value,
    this.valueStr,
  );

  final int value;
  final String valueStr;
}
