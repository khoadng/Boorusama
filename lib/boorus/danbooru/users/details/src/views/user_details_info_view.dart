// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/themes/theme/types.dart';
import '../../../feedbacks/routes.dart';
import '../../../user/types.dart';
import '../widgets/user_details_section_card.dart';

class UserDetailsInfoView extends ConsumerWidget {
  const UserDetailsInfoView({
    required this.uid,
    required this.isSelf,
    required this.user,
    required this.previousNames,
    super.key,
  });

  final bool isSelf;
  final DanbooruUser user;
  final int uid;
  final List<String> previousNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFeedback = user.hasFeedbacks;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                const SizedBox(height: 12),
                UserDetailsSectionCard.text(
                  title: context.t.profile.activity.title,
                  child: UserStatsGroup(user: user),
                ),
                const SizedBox(height: 24),
                _buildFeedbacks(hasFeedback, ref),
                if (previousNames.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildPrevNames(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbacks(
    bool hasFeedback,
    WidgetRef ref,
  ) {
    final context = ref.context;

    return UserDetailsSectionCard(
      title: InkWell(
        onTap: hasFeedback ? () => goToUserFeedbackPage(ref, user.id) : null,
        child: Row(
          children: [
            Text(
              context.t.profile.feedback.title,
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
    );
  }

  Widget _buildPrevNames(BuildContext context) {
    return UserDetailsSectionCard.text(
      title: context.t.profile.previous_names,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              children: previousNames
                  .map(
                    (e) => Chip(
                      label: Text(e.replaceAll('_', ' ')),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
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
              title: context.t.profile.feedback.positive,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.neutralFeedbackCount,
              title: context.t.profile.feedback.neutral,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.negativeFeedbackCount,
              title: context.t.profile.feedback.negative,
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
              title: context.t.profile.activity.uploads,
            ),
            const SizedBox(height: 12),
            _StatsButton(
              num: user.favoriteGroupCount,
              title: context.t.profile.activity.favgroups,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.tagEditCount,
              title: context.t.profile.activity.tag_edits,
            ),
            const SizedBox(height: 12),
            _StatsButton(
              num: user.commentCount,
              title: context.t.profile.activity.comments,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatsButton(
              num: user.noteEditCount,
              title: context.t.profile.activity.note_edits,
            ),
            const SizedBox(height: 12),
            _StatsButton(
              num: user.forumPostCount,
              title: context.t.profile.activity.forum_posts,
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
