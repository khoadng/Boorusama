// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/dart.dart';

class CommentHeader extends StatelessWidget {
  const CommentHeader({
    super.key,
    required this.authorName,
    required this.authorTitleColor,
    required this.createdAt,
    this.onTap,
  });

  final String authorName;
  final DateTime createdAt;
  final VoidCallback? onTap;
  final Color? authorTitleColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Text(
            authorName.replaceUnderscoreWithSpace(),
            style: TextStyle(
              color: authorTitleColor,
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
