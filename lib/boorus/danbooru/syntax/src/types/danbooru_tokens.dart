// Project imports:
import '../../../../../core/search/syntax/types.dart';

enum DanbooruSpecificTokenType {
  tag,
}

class DanbooruSpecificTokenData {
  const DanbooruSpecificTokenData({
    required this.type,
  });

  final DanbooruSpecificTokenType type;
}

sealed class DanbooruTokenData {
  const DanbooruTokenData();
}

class DanbooruCommonToken extends DanbooruTokenData {
  const DanbooruCommonToken(this.data);
  final CommonTokenData data;
}

class DanbooruSpecificToken extends DanbooruTokenData {
  const DanbooruSpecificToken(this.data);
  final DanbooruSpecificTokenData data;
}
