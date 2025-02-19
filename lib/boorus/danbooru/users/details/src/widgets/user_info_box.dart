// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../../../../core/theme/providers.dart';
import '../../../user/providers.dart';
import '../../../user/user.dart';

class UserInfoBox extends ConsumerWidget {
  const UserInfoBox({
    required this.user,
    super.key,
  });

  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userColor = DanbooruUserColor.of(context);
    final theme = Theme.of(context);
    final colors = ref.watch(booruChipColorsProvider).fromColor(
          userColor.fromUser(user),
        );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.replaceAll('_', ' '),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.brightness.isLight
                      ? userColor.fromUser(user)
                      : colors?.foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(user.joinedDate),
                style: TextStyle(
                  color: theme.colorScheme.hintColor,
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
