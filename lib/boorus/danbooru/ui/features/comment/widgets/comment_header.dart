import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentHeader extends StatelessWidget {
  const CommentHeader({
    Key? key,
    required this.authorName,
    this.authorLevel,
    required this.createdAt,
  }) : super(key: key);

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
