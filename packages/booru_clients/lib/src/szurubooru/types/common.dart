sealed class SzurubooruVersion {
  const SzurubooruVersion();

  static SzurubooruVersion? maybeFrom(dynamic value) => switch (value) {
    int v => IntVersion(v),
    String v => StringVersion(v),
    _ => null,
  };
}

final class IntVersion extends SzurubooruVersion {
  const IntVersion(this.value);

  final int value;
}

final class StringVersion extends SzurubooruVersion {
  const StringVersion(this.value);

  final String value;
}
