// Project imports:
import 'user_booru.dart';
import 'user_booru_credential.dart';

abstract class UserBooruRepository {
  Future<UserBooru?> add(UserBooruCredential credential);
  Future<void> remove(UserBooru userBooru);
  Future<List<UserBooru>> getAll();
}
