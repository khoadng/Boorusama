sealed class SankakuId {
  const SankakuId();

  static SankakuId? maybeFrom(dynamic value) => switch (value) {
    int() => IntId(value),
    String() => StringId(value),
    IntId() || StringId() => value,
    _ => null,
  };

  String get valueString => switch (this) {
    IntId(:final value) => value.toString(),
    StringId(:final value) => value,
  };
}

final class IntId extends SankakuId {
  const IntId(this.value);

  final int value;

  @override
  bool operator ==(Object other) => other is IntId && other.value == value;

  @override
  int get hashCode => Object.hash(IntId, value);
}

final class StringId extends SankakuId {
  const StringId(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is StringId && other.value == value;

  @override
  int get hashCode => Object.hash(StringId, value);
}
