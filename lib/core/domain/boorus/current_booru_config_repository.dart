// Project imports:
import 'booru_config.dart';

abstract class CurrentBooruConfigRepository {
  Future<BooruConfig?> get();
}
