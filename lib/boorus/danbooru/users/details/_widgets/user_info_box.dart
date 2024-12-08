// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/level/colors.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/core/theme/utils.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import '../../user/user.dart';

class UserInfoBox extends ConsumerWidget {
  const UserInfoBox({
    super.key,
    required this.user,
  });

  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      user.level.toColor(context),
      ref.watch(settingsProvider),
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.replaceAll('_', ' '),
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.isLight
                      ? user.level.toColor(context)
                      : colors?.foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(user.joinedDate),
                style: TextStyle(
                  color: context.colorScheme.hintColor,
                ),
              ),
            ],
          ),
        ),
        Chip(
          label: Text(
            user.level.name.sentenceCase,
            style: TextStyle(
              color: colors?.foregroundColor,
            ),
          ),
          backgroundColor: colors?.backgroundColor,
        ),
      ],
    );
  }
}
