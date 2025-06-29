// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../tags/tag/providers.dart';
import '../../post/post.dart';

final danbooruTagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, (BooruConfigAuth, DanbooruPost)>(
        (ref, params) async {
  final config = params.$1;
  final post = params.$2;

  final tagGroupRepo = ref.watch(danbooruTagGroupRepoProvider(config));

  return tagGroupRepo.getTagGroups(post);
});
