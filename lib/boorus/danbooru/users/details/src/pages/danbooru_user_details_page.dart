// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/users/widgets.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/clipboard.dart';
import '../../../../../../foundation/info/package_info.dart';
import '../../../../dmails/routes.dart';
import '../../../../posts/uploads/routes.dart';
import '../../../user/providers.dart';
import '../views/user_details_info_view.dart';
import '../views/user_details_tag_changes.dart';
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
            0: Text(context.t.profile.copy_user_id),
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
        child: ref
            .watch(danbooruUserProvider(uid))
            .when(
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
                uploads: user.hasUploads
                    ? UserDetailsUploadView(
                        uid: uid,
                        username: user.name,
                        isSelf: isSelf,
                        user: user,
                      )
                    : null,
                tagChanges: user.hasEdits
                    ? UserDetailsTagChanges(
                        uid: uid,
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
              ),
              child: Text('My Uploads'.hc),
              onPressed: () => goToMyUploadsPage(ref),
            ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
            ),
            child: Text(context.t.profile.messages),
            onPressed: () => goToDmailPage(ref),
          ),
        ],
      ),
    );
  }
}
