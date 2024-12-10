// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';
import '../../../../users/user/providers.dart';
import '../../../../users/user/user.dart';

class ForumPostHeader extends StatelessWidget {
  const ForumPostHeader({
    super.key,
    required this.authorName,
    this.authorLevel,
    required this.createdAt,
    this.onTap,
  });

  final String authorName;
  final UserLevel? authorLevel;
  final DateTime createdAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Text(
            authorName.replaceAll('_', ' '),
            style: TextStyle(
              color: DanbooruUserColor.of(context).fromLevel(authorLevel),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          DateFormat('MMM d, yyyy hh:mm a').format(createdAt.toLocal()),
          style: TextStyle(
            color: Theme.of(context).colorScheme.hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
