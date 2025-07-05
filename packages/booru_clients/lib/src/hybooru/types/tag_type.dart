enum TagType {
  general(0),
  artist(1),
  copyright(3),
  character(4),
  meta(5),
  // Hybooru specific types
  creator(6),
  medium(7),
  series(8),
  studio(9),
  system(10),
  person(11),
  rating(12),
  fm(13);

  const TagType(this.value);

  final int value;

  static TagType fromValue(int value) {
    return TagType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TagType.general,
    );
  }

  static TagType fromNamespace(String namespace) {
    return switch (namespace.toLowerCase()) {
      'artist' => TagType.artist,
      'copyright' => TagType.copyright,
      'character' => TagType.character,
      'meta' || 'metadata' => TagType.meta,
      'creator' => TagType.creator,
      'medium' => TagType.medium,
      'series' => TagType.series,
      'studio' => TagType.studio,
      'system' => TagType.system,
      'person' => TagType.person,
      'rating' => TagType.rating,
      'fm' => TagType.fm,
      _ => TagType.general,
    };
  }
}
