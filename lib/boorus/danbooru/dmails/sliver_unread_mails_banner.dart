// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../router.dart';
import 'dmails.dart';

//FIXME: Desktop currently doesn't show unread mails
class SliverUnreadMailsBanner extends ConsumerWidget {
  const SliverUnreadMailsBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(danbooruUnreadDmailsProvider(ref.watchConfig)).maybeWhen(
          data: (mails) => mails.isNotEmpty
              ? SliverToBoxAdapter(
                  child: DismissableInfoContainer(
                    content: 'You have ${mails.length} unread mails',
                    mainColor: Colors.blue,
                    actions: [
                      TextButton(
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => goToDmailPage(context),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SliverSizedBox.shrink(),
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}
