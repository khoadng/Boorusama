// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'user.dart';

typedef UserListFetcher<T extends User> =
    Future<List<T>> Function(
      List<int> ids, {
      CancelToken? cancelToken,
    });

typedef UserByNameFetcher<T extends User> =
    Future<T?> Function(
      String name, {
      CancelToken? cancelToken,
    });

abstract class UserRepository<T extends User> {
  Future<T> getUserById(int id);
  UserListFetcher<T>? get getUsersByIds;
  UserByNameFetcher<T>? get getUserByName;
}

class UserRepositoryBuilder<T extends User> implements UserRepository<T> {
  UserRepositoryBuilder({
    required this.fetchOne,
    this.fetchMany,
    this.fetchByName,
  });

  final Future<T> Function(int id) fetchOne;
  final UserListFetcher<T>? fetchMany;
  final UserByNameFetcher<T>? fetchByName;

  @override
  Future<T> getUserById(int id) => fetchOne(id);

  @override
  UserListFetcher<T>? get getUsersByIds => fetchMany;

  @override
  UserByNameFetcher<T>? get getUserByName => fetchByName;
}
