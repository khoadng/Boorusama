// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/widgets/widgets.dart';
import '../data/providers.dart';
import '../routes/route_utils.dart';

class SliverUnreadMailsBanner extends ConsumerWidget {
  const SliverUnreadMailsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(danbooruUnreadDmailsProvider(ref.watchConfigAuth))
        .maybeWhen(
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