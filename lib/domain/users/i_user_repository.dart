import 'user.dart';

abstract class IUserRepository {
  Future<List<User>> getUsersByIdStringComma(String idComma);
}
