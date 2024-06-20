// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/dmails/dmails.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/users/users.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme_utils.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import '../feats/comments/comments.dart';
import 'widgets/comments/dtext.dart';

class DanbooruDmailDetailsPage extends ConsumerWidget {
  const DanbooruDmailDetailsPage({
    super.key,
    required this.dmail,
    required this.onDmailUnread,
  });

  final Dmail dmail;
  final void Function(BuildContext context, Dmail dmail) onDmailUnread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final fromUser = ref.watch(danbooruCreatorProvider(dmail.fromId));
    final toUser = ref.watch(danbooruCreatorProvider(dmail.toId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Mark as unread
          IconButton(
              icon: const Icon(Symbols.mark_email_unread),
              onPressed: () {
                onDmailUnread(context, dmail);
                Navigator.pop(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              dmail.title,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Sender: ',
                  style: context.textTheme.titleMedium,
                ),
                Text(
                  fromUser?.name ?? 'Anon',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: fromUser?.level.toOnDarkColor(),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Receiver: ',
                  style: context.textTheme.titleMedium,
                ),
                Text(
                  toUser?.name ?? 'Anon',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: toUser?.level.toOnDarkColor(),
                  ),
                ),
              ],
            ),
            Text(
                'Date: ${DateFormat('MMM d, yyyy hh:mm a').format(dmail.createdAt.toLocal())}',
                style: context.textTheme.titleMedium),
            const SizedBox(height: 16),
            Dtext.parse(
              parseDtext(dmail.body),
              '[quote]',
              '[/quote]',
            ),
            const SizedBox(height: 16),
            if (!config.hasStrictSFW)
              FilledButton(
                onPressed: () {
                  launchExternalUrlString('${config.url}dmails/${dmail.id}');
                },
                child: const Text('View in Browser (LOGGED IN REQUIRED))'),
              ),
          ],
        ),
      ),
    );
  }
}
