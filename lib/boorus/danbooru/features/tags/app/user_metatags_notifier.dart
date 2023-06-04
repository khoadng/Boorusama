// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'tags_provider.dart';

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
