// Project imports:
import '../../../core/search/syntax/types.dart';

enum GelbooruSpecificTokenType {
  tilde,
  openBrace,
  closeBrace,
}

class GelbooruSpecificTokenData {
  const GelbooruSpecificTokenData({
    required this.type,
    this.level,
    this.isFocused = false,
  });

  final GelbooruSpecificTokenType type;
  final int? level;
  final bool isFocused;

  GelbooruSpecificTokenData copyWith({
    GelbooruSpecificTokenType? type,
    int? level,
    bool? isFocused,
  }) {
    return GelbooruSpecificTokenData(
      type: type ?? this.type,
      level: level ?? this.level,
      isFocused: isFocused ?? this.isFocused,
    );
  }
}

sealed class GelbooruTokenData {
  const GelbooruTokenData();
}

class GelbooruCommonToken extends GelbooruTokenData {
  const GelbooruCommonToken(this.data);
  final CommonTokenData data;
}

class GelbooruSpecificToken extends GelbooruTokenData {
  const GelbooruSpecificToken(this.data);
  final GelbooruSpecificTokenData data;
}
