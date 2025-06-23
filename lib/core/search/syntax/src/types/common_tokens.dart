enum CommonTokenType {
  or,
  openParen,
  closeParen,
}

class CommonTokenData {
  const CommonTokenData({
    required this.type,
    this.level,
    this.isFocused = false,
  });

  final CommonTokenType type;
  final int? level;
  final bool isFocused;

  CommonTokenData copyWith({
    CommonTokenType? type,
    int? level,
    bool? isFocused,
  }) {
    return CommonTokenData(
      type: type ?? this.type,
      level: level ?? this.level,
      isFocused: isFocused ?? this.isFocused,
    );
  }
}

class QueryToken<T> {
  const QueryToken({
    required this.start,
    required this.end,
    required this.text,
    required this.data,
  });

  final int start;
  final int end;
  final String text;
  final T data;
}
