// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'user_metatags_provider.dart';

class UserMetatagRepository {
  UserMetatagRepository({
    required this.box,
  });

  final Box<String> box;

  Future<void> put(String tag) => box.put(tag, tag);
  Future<void> delete(String tag) => box.delete(tag);

  List<String> getAll() => box.values.toList();
}

class UserMetatagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return repo.getAll();
  }

  UserMetatagRepository get repo => ref.watch(danbooruUserMetatagRepoProvider);

  Future<void> add(String tag) async {
    await repo.put(tag);
    state = repo.getAll();
  }

  Future<void> delete(String tag) async {
    await repo.delete(tag);
    state = repo.getAll();
  }
}
