// Project imports:
import '../../../pool/pool.dart';

extension DanbooruPoolX on DanbooruPool {
  bool get isEmpty => id == -1;

  String get _query => 'pool:$id';

  String toSearchQuery() => _query;
}
