// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/widgets/widgets.dart';

class SliverAppAnnouncementBanner extends StatelessWidget {
  const SliverAppAnnouncementBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: AppAnnouncementBanner(),
    );
  }
}

class AppAnnouncementBanner extends ConsumerStatefulWidget {
  const AppAnnouncementBanner({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnnouncementBannerState();
}

class _AnnouncementBannerState extends ConsumerState<AppAnnouncementBanner> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(announcementProvider).maybeWhen(
          data: (announcement) => announcement.trimRight().isNotEmpty
              ? DismissableInfoContainer(
                  content: announcement,
                  forceShow: true,
                  mainColor: Colors.orange[600],
                )
              : const SizedBox.shrink(),
          orElse: () => const SizedBox.shrink(),
        );
  }
}
