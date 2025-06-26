// Project imports:
import '../../../../../core/search/syntax/syntax.dart';

enum GelbooruV2SpecificTokenType {
  tilde,
  tildeOpenParen,
  tildeCloseParen,
}

class GelbooruV2SpecificTokenData {
  const GelbooruV2SpecificTokenData({
    required this.type,
    this.level,
    this.isFocused = false,
  });

  final GelbooruV2SpecificTokenType type;
  final int? level;
  final bool isFocused;

  GelbooruV2SpecificTokenData copyWith({
    GelbooruV2SpecificTokenType? type,
    int? level,
    bool? isFocused,
  }) {
    return GelbooruV2SpecificTokenData(
      type: type ?? this.type,
      level: level ?? this.level,
      isFocused: isFocused ?? this.isFocused,
    );
  }
}

sealed class GelbooruV2TokenData {
  const GelbooruV2TokenData();
}

class GelbooruV2CommonToken extends GelbooruV2TokenData {
  const GelbooruV2CommonToken(this.data);
  final CommonTokenData data;
}

class GelbooruV2SpecificToken extends GelbooruV2TokenData {
  const GelbooruV2SpecificToken(this.data);
  final GelbooruV2SpecificTokenData data;
}
