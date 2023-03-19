// Project imports:
import 'booru.dart';

abstract class CurrentBooruRepository {
  Future<Booru> getCurrentBooru();
}
