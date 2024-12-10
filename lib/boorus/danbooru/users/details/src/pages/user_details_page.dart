// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/foundation/clipboard.dart';
import '../../../../../../core/info/package_info.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../dmails/routes.dart';
import '../../../../posts/uploads/routes.dart';
import '../../../user/providers.dart';
import '../views/user_details_info_view.dart';
import '../views/user_details_upload_view.dart';
import '../widgets/user_info_box.dart';

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
                    color: Theme.of(context).colorScheme.surface,
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
