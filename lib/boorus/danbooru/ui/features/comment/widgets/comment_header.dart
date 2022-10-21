// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class CommentHeader extends StatelessWidget {
  const CommentHeader({
    super.key,
    required this.authorName,
    this.authorLevel,
    required this.createdAt,
  });

  final String authorName;
  final UserLevel? authorLevel;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        Text(
          authorName.replaceAll('_', ' '),
          style: TextStyle(
            color: authorLevel != null ? Color(authorLevel!.hexColor) : null,
            fontSize: 15,
            fontWeight: FontWeight.w500,
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
