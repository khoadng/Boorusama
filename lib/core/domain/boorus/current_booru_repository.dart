// Project imports:
import 'user_booru.dart';

abstract class CurrentUserBooruRepository {
  Future<UserBooru?> get();
}
