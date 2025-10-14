// Project imports:
import '../../../pool/types.dart';

extension DanbooruPoolX on DanbooruPool {
  bool get isEmpty => id == -1;

  String get _query => 'pool:$id';

  String toSearchQuery() => _query;
}
