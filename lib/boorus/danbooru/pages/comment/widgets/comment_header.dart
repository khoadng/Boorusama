// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/users/users.dart';
import 'package:boorusama/core/ui/user_level_colors.dart';

class CommentHeader extends StatelessWidget {
  const CommentHeader({
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
              color: authorLevel != null
                  ? Color(getUserHexColor(authorLevel!))
                  : null,
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
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
