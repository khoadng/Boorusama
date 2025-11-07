// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../users/user/providers.dart';

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
      secondChild: BooruSwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(context.t.favorite_groups.is_private_group_option),
        value: isPrivate,
        onChanged: onChanged,
      ),
      crossFadeState: currentUser.maybeWhen(
        data: (user) => user != null && user.level.isGoldPlus
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        orElse: () => CrossFadeState.showFirst,
      ),
      duration: const Duration(milliseconds: 150),
    );
  }
}
