// Project imports:
import 'booru_config.dart';
import 'user_booru_credential.dart';

abstract class BooruConfigRepository {
  Future<BooruConfig?> add(UserBooruCredential credential);
  Future<void> remove(BooruConfig userBooru);
  Future<List<BooruConfig>> getAll();
}
