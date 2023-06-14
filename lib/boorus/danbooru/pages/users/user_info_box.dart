// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/user_level_colors.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';

class UserInfoBox extends StatelessWidget {
  const UserInfoBox({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: user.level.toColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Chip(
              label: Text(user.level.name.sentenceCase),
              visualDensity: const VisualDensity(vertical: -4),
              backgroundColor: user.level.toColor(),
            ),
          ],
        ),
        Text(
          DateFormat('yyyy-MM-dd').format(user.joinedDate),
          style: TextStyle(
            color: context.theme.hintColor,
          ),
        ),
      ],
    );
  }
}
