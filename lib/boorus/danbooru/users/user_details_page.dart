// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../related_tags/related_tags.dart';
import '../reports/reports.dart';
import '../router.dart';
import 'users.dart';

class DanbooruReportDataParams extends Equatable {
  const DanbooruReportDataParams({
    required this.username,
    required this.tag,
    required this.uploadCount,
  });

  DanbooruReportDataParams.forUser(
    DanbooruUser user,
  )   : username = user.name,
        tag = 'user:${user.name}',
        uploadCount = user.uploadCount;

  DanbooruReportDataParams withDateRange({
    DateTime? from,
    DateTime? to,
  }) {
    return DanbooruReportDataParams(
      username: username,
      tag: tag,
      uploadCount: uploadCount,
    );
  }

  final String username;
  final String tag;
  final int uploadCount;

  @override
  List<Object?> get props => [username, tag, uploadCount];
}

typedef DanbooruCopyrightDataParams = ({
  String username,
  int uploadCount,
});

final userDataProvider = FutureProvider.autoDispose
    .family<List<DanbooruReportDataPoint>, DanbooruReportDataParams>(
        (ref, params) async {
  final tag = params.tag;
  final config = ref.watchConfig;
  final now = DateTime.now();

  final selectedRange = ref.watch(selectedUploadDateRangeSelectorTypeProvider);
  final from = switch (selectedRange) {
    UploadDateRangeSelectorType.last7Days =>
      now.subtract(const Duration(days: 7)),
    UploadDateRangeSelectorType.last30Days =>
      now.subtract(const Duration(days: 30)),
    UploadDateRangeSelectorType.last3Months =>
      now.subtract(const Duration(days: 90)),
    UploadDateRangeSelectorType.last6Months =>
      now.subtract(const Duration(days: 180)),
    UploadDateRangeSelectorType.lastYear =>
      now.subtract(const Duration(days: 365)),
  };

  final data =
      await ref.watch(danbooruPostReportProvider(config)).getPostReports(
    tags: [
      tag,
    ],
    period: DanbooruReportPeriod.day,
    from: from,
    to: DateTime.now(),
  );

  data.sort((a, b) => a.date.compareTo(b.date));

  return data;
});

final userCopyrightDataProvider =
    FutureProvider.family<DanbooruRelatedTag, DanbooruCopyrightDataParams>(
        (ref, params) async {
  final username = params.username;
  final config = ref.watchConfig;
  return ref.watch(danbooruRelatedTagRepProvider(config)).getRelatedTag(
        'user:$username',
        order: RelatedType.frequency,
        category: TagCategory.copyright(),
      );
});

class DanbooruProfilePage extends ConsumerWidget {
  const DanbooruProfilePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
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
