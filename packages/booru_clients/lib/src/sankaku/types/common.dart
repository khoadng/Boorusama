sealed class SankakuId {
  const SankakuId();

  static SankakuId? maybeFrom(dynamic value) {
    if (value is int) {
      return IntId(value);
    } else if (value is String) {
      return StringId(value);
    } else {
      return null;
    }
  }
}

final class IntId extends SankakuId {
  const IntId(this.value);

  final int value;
}

final class StringId extends SankakuId {
  const StringId(this.value);

  final String value;
}
