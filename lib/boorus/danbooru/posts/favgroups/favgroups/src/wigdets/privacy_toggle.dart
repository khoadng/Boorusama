// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../../core/configs/ref.dart';
import '../../../../../../../core/widgets/widgets.dart';
import '../../../../../users/user/providers.dart';
import '../../../../../users/user/user.dart';

class PrivacyToggle extends ConsumerWidget {
  const PrivacyToggle({
    required this.isPrivate,
    required this.onChanged,
    super.key,
  });

  final bool isPrivate;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final currentUser = ref.watch(danbooruCurrentUserProvider(config));

    return BooruAnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text('favorite_groups.is_private_group_option').tr(),
        trailing: Switch(
          value: isPrivate,
          onChanged: onChanged,
        ),
      ),
      crossFadeState: currentUser.maybeWhen(
        data: (user) => user != null && isBooruGoldPlusAccount(user.level)
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        orElse: () => CrossFadeState.showFirst,
      ),
      duration: const Duration(milliseconds: 150),
    );
  }
}
