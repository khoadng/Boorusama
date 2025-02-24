// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/foundation/clipboard.dart';
import '../../../../../../core/info/package_info.dart';
import '../../../../../../core/users/widgets.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../dmails/routes.dart';
import '../../../../posts/uploads/routes.dart';
import '../../../user/providers.dart';
import '../views/user_details_info_view.dart';
import '../views/user_details_upload_view.dart';
import '../widgets/danbooru_user_info_box.dart';

class DanbooruUserDetailsPage extends ConsumerWidget {
  const DanbooruUserDetailsPage({
    required this.uid,
    super.key,
    this.hasAppBar = true,
    this.isSelf = false,
  });

  final int uid;
  final bool hasAppBar;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UserDetailsPage(
      actions: [
        BooruPopupMenuButton(
          itemBuilder: {
            0: const Text('profile.copy_user_id').tr(),
          },
          onSelected: (value) {
            if (value == 0) {
              AppClipboard.copy(uid.toString());
            }
          },
        ),
      ],
      body: SafeArea(
        bottom: false,
        child: ref.watch(danbooruUserProvider(uid)).when(
              data: (user) => UserDetailsTabView(
                sliverInfoOverview: UserOverviewScaffold(
                  userInfo: DanbooruUserInfoBox(user: user),
                  action: UserDetailsActionButtons(uid: uid),
                  isSelf: isSelf,
                ),
                infoDetails: UserDetailsInfoView(
                  uid: uid,
                  isSelf: isSelf,
                  user: user,
                ),
                uploads: user.uploadCount > 0
                    ? UserDetailsUploadView(
                        uid: uid,
                        username: user.name,
                        isSelf: isSelf,
                        user: user,
                      )
                    : null,
              ),
              error: (error, stackTrace) => const Center(
                child: Text('Fail to load profile'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
      ),
    );
  }
}

class UserDetailsActionButtons extends ConsumerWidget {
  const UserDetailsActionButtons({
    required this.uid,
    super.key,
  });

  final int uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        children: [
          if (ref.watch(isDevEnvironmentProvider))
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              child: const Text('My Uploads'),
              onPressed: () => goToMyUploadsPage(context),
            ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            child: const Text('profile.messages').tr(),
            onPressed: () => goToDmailPage(context),
          ),
        ],
      ),
    );
  }
}
