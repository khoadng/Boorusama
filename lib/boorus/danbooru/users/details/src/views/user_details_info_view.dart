// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../feedbacks/routes.dart';
import '../../../user/user.dart';
import '../widgets/user_details_section_card.dart';

class UserDetailsInfoView extends ConsumerWidget {
  const UserDetailsInfoView({
    required this.uid,
    required this.isSelf,
    required this.user,
    super.key,
  });

  final bool isSelf;
  final DanbooruUser user;
  final int uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFeedback = user.hasFeedbacks;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          UserDetailsSectionCard.text(
            title: 'Activity',
            child: UserStatsGroup(user: user),
          ),
          const SizedBox(height: 24),
          UserDetailsSectionCard(
            title: InkWell(
              onTap: hasFeedback
                  ? () => goToUserFeedbackPage(ref, user.id)
                  : null,
              child: Row(
                children: [
                  Text(
                    'Feedbacks'.hc,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasFeedback) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Symbols.arrow_forward_ios,
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
            child: UserFeedbacksGroup(user: user),
          ),
        ],
      ),
    );
  }
}

class UserFeedbacksGroup extends StatelessWidget {
  const UserFeedbacksGroup({
    required this.user,
    super.key,
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
              num: user.positiveFeedbackCount,
              title: 'Positive',
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.neutralFeedbackCount,
              title: 'Neutral',
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.negativeFeedbackCount,
              title: 'Negative',
            ),
          ],
        ),
      ],
    );
  }
}

class UserStatsGroup extends StatelessWidget {
  const UserStatsGroup({
    required this.user,
    super.key,
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
          style: TextStyle(color: Theme.of(context).colorScheme.hintColor),
        ),
      ],
    );
  }
}
