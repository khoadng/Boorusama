// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/failsafe.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../user/providers.dart';
import 'user_details_page.dart';

class DanbooruProfilePage extends ConsumerWidget {
  const DanbooruProfilePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final userId = ref.watch(danbooruCurrentUserProvider(config)).maybeWhen(
          data: (user) => user?.id,
          orElse: () => null,
        );
    final username = config.login;

    if (userId == null || username == null || username.isEmpty) {
      return const UnauthorizedPage();
    }

    return UserDetailsPage(
      uid: userId,
      hasAppBar: hasAppBar,
      isSelf: true,
    );
  }
}
