// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/users/colors.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';

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
              color: authorLevel?.toColor(context),
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
            color: context.colorScheme.hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
