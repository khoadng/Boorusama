sealed class SankakuId {
  const SankakuId();

  static SankakuId? maybeFrom(dynamic value) => switch (value) {
    int() => IntId(value),
    String() => StringId(value),
    IntId() || StringId() => value,
    _ => null,
  };
}

final class IntId extends SankakuId {
  const IntId(this.value);

  final int value;
}

final class StringId extends SankakuId {
  const StringId(this.value);

  final String value;
}
