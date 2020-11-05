import 'user.dart';

abstract class IUserRepository {
  Future<List<User>> getUsersByIdStringComma(String idComma);
  Future<User> getUserById(int id);
}
