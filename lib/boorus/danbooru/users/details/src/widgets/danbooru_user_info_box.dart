// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../../../../core/theme/providers.dart';
import '../../../../../../core/users/widgets.dart';
import '../../../user/providers.dart';
import '../../../user/user.dart';

class DanbooruUserInfoBox extends ConsumerWidget {
  const DanbooruUserInfoBox({
    required this.user,
    super.key,
  });

  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userColor = DanbooruUserColor.of(context);
    final theme = Theme.of(context);
    final colors = ref
        .watch(booruChipColorsProvider)
        .fromColor(
          userColor.fromUser(user),
        );

    return UserInfoBox(
      username: UserInfoNameText(
        name: user.name,
        color: theme.brightness.isLight
            ? userColor.fromUser(user)
            : colors?.foregroundColor,
      ),
      userLevel: Chip(
        label: Text(
          user.level.name.sentenceCase,
          style: TextStyle(
            color: colors?.foregroundColor,
          ),
        ),
        backgroundColor: colors?.backgroundColor,
      ),
      joinedDate: user.joinedDate,
    );
  }
}
