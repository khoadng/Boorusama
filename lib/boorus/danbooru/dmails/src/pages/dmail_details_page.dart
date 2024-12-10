// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/dtext/dtext.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../dtext/dtext.dart';
import '../../../users/creator/providers.dart';
import '../../../users/user/providers.dart';
import '../types/dmail.dart';

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
    final config = ref.watchConfigAuth;
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
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              dmail.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Sender: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  fromUser?.name ?? 'Anon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DanbooruUserColor.of(context)
                            .fromLevel(fromUser?.level),
                      ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Receiver: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  toUser?.name ?? 'Anon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DanbooruUserColor.of(context)
                            .fromLevel(toUser?.level),
                      ),
                ),
              ],
            ),
            Text(
              'Date: ${DateFormat('MMM d, yyyy hh:mm a').format(dmail.createdAt.toLocal())}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
