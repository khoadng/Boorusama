// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'users.dart';

class UserDetailsInfoView extends ConsumerWidget {
  const UserDetailsInfoView({
    super.key,
    required this.uid,
    required this.isSelf,
    required this.user,
  });

  final bool isSelf;
  final DanbooruUser user;
  final int uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          UserStatsGroup(user: user),
        ],
      ),
    );
  }
}

class UserStatsGroup extends StatelessWidget {
  const UserStatsGroup({
    super.key,
    required this.user,
  });

  final DanbooruUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.uploadCount,
              title: 'Uploads',
            ),
            const SizedBox(height: 12),
            _StatsButton(
              num: user.favoriteGroupCount,
              title: 'Favgroups',
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.tagEditCount,
              title: 'Tag edits',
            ),
            const SizedBox(height: 12),
            _StatsButton(
              num: user.commentCount,
              title: 'Comments',
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.noteEditCount,
              title: 'Note edits',
            ),
            const SizedBox(height: 12),
            _StatsButton(
              num: user.forumPostCount,
              title: 'Forum posts',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsButton extends StatelessWidget {
  const _StatsButton({
    required this.num,
    required this.title,
  });

  final int num;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          NumberFormat.compact().format(num),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: context.colorScheme.hintColor),
        ),
      ],
    );
  }
}
