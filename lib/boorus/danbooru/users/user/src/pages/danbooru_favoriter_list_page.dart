// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/theme.dart';
import '../../../../danbooru_provider.dart';
import '../../providers.dart';
import 'user_list_page.dart';

class DanbooruFavoriterListPage extends ConsumerWidget {
  const DanbooruFavoriterListPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final client = ref.watch(danbooruClientProvider(config));
    final userRepo = ref.watch(danbooruUserRepoProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text('Users who favorited'),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: 'Only public favorites are shown.',
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 3),
              child: Icon(
                Icons.info,
                size: 18,
                color: Theme.of(context).colorScheme.hintColor,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          DanbooruSliverUserListPage(
            fetchUsers: (page) async {
              final votes =
                  await client.getFavorites(postId: postId, page: page);
              final userIds = votes.map((e) => e.userId).toList();
              final users = await userRepo.getUsersByIds(userIds);
              return users;
            },
          ),
        ],
      ),
    );
  }
}
