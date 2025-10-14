// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../providers/unread_provider.dart';
import '../routes/route_utils.dart';

class SliverUnreadMailsBanner extends ConsumerWidget {
  const SliverUnreadMailsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(danbooruUnreadDmailsProvider(ref.watchConfigAuth))
        .maybeWhen(
          data: (ids) => ids.isNotEmpty
              ? SliverToBoxAdapter(
                  child: DismissableInfoContainer(
                    content: context.t.profile.messages.unread_message_notice(
                      n: ids.length,
                    ),
                    mainColor: Colors.blue,
                    actions: [
                      TextButton(
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () =>
                            goToDmailPage(ref, folder: DmailFolderType.unread),
                        child: Text(
                          context.t.generic.action.view,
                          style: const TextStyle(
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
