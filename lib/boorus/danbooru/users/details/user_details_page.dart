// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/failsafe.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../user/providers.dart';
import '../user/users_notifier.dart';
import '_widgets/user_info_box.dart';
import 'user_details_info_view.dart';
import 'user_details_upload_view.dart';

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

class UserDetailsPage extends ConsumerWidget {
  const UserDetailsPage({
    super.key,
    required this.uid,
    this.hasAppBar = true,
    this.isSelf = false,
  });

  final int uid;
  final bool hasAppBar;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('profile.profile').tr(),
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
      ),
      body: SafeArea(
        bottom: false,
        child: ref.watch(danbooruUserProvider(uid)).when(
              data: (user) {
                final tabMap = {
                  'Info': UserDetailsInfoView(
                    uid: uid,
                    isSelf: isSelf,
                    user: user,
                  ),
                  if (user.uploadCount > 0)
                    'Uploads': UserDetailsUploadView(
                      uid: uid,
                      username: user.name,
                      isSelf: isSelf,
                      user: user,
                    ),
                };

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: UserInfoBox(user: user),
                            ),
                            if (isSelf) const SizedBox(height: 12),
                            if (isSelf) UserDetailsActionButtons(uid: uid),
                          ],
                        ),
                      ),
                      SliverFillRemaining(
                        child: DefaultTabController(
                          length: tabMap.length,
                          child: Column(
                            children: [
                              TabBar(
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                isScrollable: true,
                                tabs: [
                                  for (final tab in tabMap.keys)
                                    Tab(text: tab.tr()),
                                ],
                              ),
                              const Divider(
                                thickness: 1,
                                height: 0,
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    for (final tab in tabMap.values) tab,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
    super.key,
    required this.uid,
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
                backgroundColor: context.colorScheme.secondaryContainer,
                foregroundColor: context.colorScheme.onSecondaryContainer,
              ),
              child: const Text('My Uploads'),
              onPressed: () => goToMyUploadsPage(context),
            ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.secondaryContainer,
              foregroundColor: context.colorScheme.onSecondaryContainer,
            ),
            child: const Text('profile.messages').tr(),
            onPressed: () => goToDmailPage(context),
          ),
        ],
      ),
    );
  }
}
