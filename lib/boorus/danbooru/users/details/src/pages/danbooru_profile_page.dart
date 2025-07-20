// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/auth/widgets.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../user/providers.dart';
import '../types/user_details.dart';
import 'danbooru_user_details_page.dart';

class DanbooruProfilePage extends ConsumerWidget {
  const DanbooruProfilePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final user = ref
        .watch(danbooruCurrentUserProvider(config))
        .maybeWhen(
          data: (user) => user,
          orElse: () => null,
        );
    final username = config.login;
    final userId = user?.id;
    final userLevel = user?.level;

    if (userId == null || username == null || username.isEmpty) {
      return const UnauthorizedPage();
    }

    return DanbooruUserDetailsPage(
      details: UserDetails(
        id: userId,
        name: username,
        level: userLevel,
      ),
      hasAppBar: hasAppBar,
      isSelf: true,
    );
  }
}
