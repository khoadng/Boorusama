// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/users/widgets.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/clipboard.dart';
import '../../../../../../foundation/info/package_info.dart';
import '../../../../dmails/routes.dart';
import '../../../../posts/uploads/routes.dart';
import '../../../user/providers.dart';
import '../types/user_details.dart';
import '../views/user_details_info_view.dart';
import '../views/user_details_tag_changes.dart';
import '../views/user_details_upload_view.dart';
import '../widgets/danbooru_user_info_box.dart';

class DanbooruUserDetailsPage extends ConsumerWidget {
  const DanbooruUserDetailsPage({
    required this.details,
    super.key,
    this.hasAppBar = true,
    this.isSelf = false,
  });

  final UserDetails details;
  final bool hasAppBar;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = details.id;
    final config = ref.watchConfigAuth;

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
            .watch(danbooruUserDetailsProvider((config, uid)))
            .when(
              data: (userDetails) {
                final user = userDetails.user;
                final previousNames = userDetails.previousNames;

                return UserDetailsTabView(
                  sliverInfoOverview: UserOverviewScaffold(
                    userInfo: DanbooruUserInfoBox(
                      user: UserDetails.fromUser(user),
                    ),
                    action: UserDetailsActionButtons(uid: uid),
                    isSelf: isSelf,
                  ),
                  infoDetails: UserDetailsInfoView(
                    uid: uid,
                    isSelf: isSelf,
                    user: user,
                    previousNames: previousNames,
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
                );
              },
              error: (error, stackTrace) => Center(
                child: Text(context.t.profile.fail_to_load_profile),
              ),
              loading: () => _buildLoading(uid),
            ),
      ),
    );
  }

  Widget _buildLoading(int uid) {
    return UserDetailsViewScaffold(
      sliverInfoOverview: UserOverviewScaffold(
        userInfo: DanbooruUserInfoBox(
          user: details,
          loading: true,
        ),
        action: UserDetailsActionButtons(uid: uid),
        isSelf: isSelf,
      ),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 36,
            ),
            child: SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(),
            ),
          ),
        ],
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
            child: Text(context.t.profile.messages.title),
            onPressed: () => goToDmailPage(ref),
          ),
        ],
      ),
    );
  }
}
