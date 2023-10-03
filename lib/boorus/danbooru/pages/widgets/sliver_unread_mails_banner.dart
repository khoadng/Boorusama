// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../../feats/dmails/dmails.dart';
import '../../router.dart';

//FIXME: Desktop currently doesn't show unread mails
class SliverUnreadMailsBanner extends ConsumerWidget {
  const SliverUnreadMailsBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadMailAsync =
        ref.watch(danbooruUnreadDmailsProvider(ref.watchConfig));

    return unreadMailAsync.maybeWhen(
      data: (mails) => mails.isNotEmpty
          ? SliverToBoxAdapter(
              child: DismissableInfoContainer(
                content: 'You have ${mails.length} unread mails',
                mainColor: Colors.blue,
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => goToDmailPage(context),
                    child: const Text('View'),
                  ),
                ],
              ),
            )
          : const SliverSizedBox.shrink(),
      orElse: () => const SliverSizedBox.shrink(),
    );
  }
}
