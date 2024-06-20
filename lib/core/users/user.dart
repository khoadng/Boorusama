abstract class User {
  int get id;
  // String get name;
  // String get levelString;
}

typedef UserListFetcher<T extends User> = Future<List<T>> Function(
    List<int> ids);

abstract class UserRepository<T extends User> {
  Future<T> getUserById(int id);
  UserListFetcher<T>? get getUsersByIds;
}

class UserRepositoryBuilder<T extends User> implements UserRepository<T> {
  UserRepositoryBuilder({
    required this.fetchOne,
    this.fetchMany,
  });

  final Future<T> Function(int id) fetchOne;
  final UserListFetcher<T>? fetchMany;

  @override
  Future<T> getUserById(int id) => fetchOne(id);

  @override
  UserListFetcher<T>? get getUsersByIds => fetchMany;
}
