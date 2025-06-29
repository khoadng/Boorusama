// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../posts/post/post.dart';
import '../../categories/providers.dart';
import 'tag_group_item.dart';
import 'tag_repository.dart';

class EmptyTagGroupRepository implements TagGroupRepository {
  const EmptyTagGroupRepository();

  @override
  Future<List<TagGroupItem>> getTagGroups(Post post) async {
    return [];
  }
}

class TagGroupRepositoryBuilder<T extends Post>
    implements TagGroupRepository<T> {
  TagGroupRepositoryBuilder({
    required this.loadGroups,
    required this.ref,
  });

  final Ref ref;
  final Future<List<TagGroupItem>> Function(T post) loadGroups;

  @override
  Future<List<TagGroupItem>> getTagGroups(
    T post,
  ) async {
    final booruTagTypeStore = await ref.read(booruTagTypeStoreProvider.future);
    final config = ref.readConfig;

    final groups = await loadGroups(post);

    final tags = groups.expand((e) => e.tags).toList();

    await booruTagTypeStore.saveTagIfNotExist(config.url, tags);

    return groups;
  }
}
