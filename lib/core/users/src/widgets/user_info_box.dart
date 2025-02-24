// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/theme.dart';

class UserInfoBox extends ConsumerWidget {
  const UserInfoBox({
    required this.username,
    required this.userLevel,
    super.key,
    this.joinedDate,
  });

  final Widget username;
  final DateTime? joinedDate;
  final Widget userLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              username,
              Text(
                joinedDate != null
                    ? DateFormat('yyyy-MM-dd').format(joinedDate!)
                    : 'N/A',
                style: TextStyle(
                  color: colorScheme.hintColor,
                ),
              ),
            ],
          ),
        ),
        userLevel,
      ],
    );
  }
}

class UserInfoNameText extends StatelessWidget {
  const UserInfoNameText({
    required this.name,
    super.key,
    this.color,
  });

  final String name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      name.replaceAll('_', ' '),
      style: theme.textTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
