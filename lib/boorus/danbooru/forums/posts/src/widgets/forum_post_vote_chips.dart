// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../users/creator/providers.dart';
import '../../../../users/user/providers.dart';
import '../types/forum_post_vote.dart';
import 'forum_vote_chip.dart';

class DanbooruForumVoteChips extends ConsumerWidget {
  const DanbooruForumVoteChips({
    required this.votes,
    super.key,
  });

  final List<DanbooruForumPostVote> votes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: votes
          .map(
            (e) => ForumVoteChip(
              icon: switch (e.type) {
                DanbooruForumPostVoteType.upvote => Icon(
                    Symbols.arrow_upward,
                    color: _iconColor(e.type),
                  ),
                DanbooruForumPostVoteType.downvote => Icon(
                    Symbols.arrow_downward,
                    color: _iconColor(e.type),
                  ),
                DanbooruForumPostVoteType.unsure => Container(
                    margin: const EdgeInsets.all(4),
                    child: FaIcon(
                      FontAwesomeIcons.faceMeh,
                      size: 16,
                      color: _iconColor(e.type),
                    ),
                  ),
              },
              color: _color(e.type),
              borderColor: _borderColor(e.type),
              label: Builder(
                builder: (context) {
                  final creator =
                      ref.watch(danbooruCreatorProvider(e.creatorId));

                  return Text(
                    creator?.name.replaceAll('_', ' ') ?? 'User',
                    style: TextStyle(
                      color: DanbooruUserColor.of(context)
                          .fromLevel(creator?.level),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

Color _color(DanbooruForumPostVoteType type) => switch (type) {
      DanbooruForumPostVoteType.upvote => const Color(0xff01370a),
      DanbooruForumPostVoteType.downvote => const Color(0xff5c1212),
      DanbooruForumPostVoteType.unsure => const Color(0xff382c00),
    };

Color _borderColor(DanbooruForumPostVoteType type) => switch (type) {
      DanbooruForumPostVoteType.upvote => const Color(0xff016f19),
      DanbooruForumPostVoteType.downvote => const Color(0xffc10105),
      DanbooruForumPostVoteType.unsure => const Color(0xff675403),
    };

Color _iconColor(DanbooruForumPostVoteType type) => switch (type) {
      DanbooruForumPostVoteType.upvote => const Color(0xff01aa2d),
      DanbooruForumPostVoteType.downvote => const Color(0xffff5b5a),
      DanbooruForumPostVoteType.unsure => const Color(0xffdac278),
    };
