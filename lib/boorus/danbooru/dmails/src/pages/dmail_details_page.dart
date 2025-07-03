// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
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
    required this.dmail,
    required this.onDmailUnread,
    super.key,
  });

  final Dmail dmail;
  final void Function(BuildContext context, Dmail dmail) onDmailUnread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final fromUser = ref.watch(danbooruCreatorProvider(dmail.fromId));
    final toUser = ref.watch(danbooruCreatorProvider(dmail.toId));
    final theme = Theme.of(context);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dmail.title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Sender: ',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    fromUser?.name ?? 'Anon',
                    style: theme.textTheme.titleMedium?.copyWith(
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
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    toUser?.name ?? 'Anon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: DanbooruUserColor.of(context)
                          .fromLevel(toUser?.level),
                    ),
                  ),
                ],
              ),
              Text(
                'Date: ${DateFormat('MMM d, yyyy hh:mm a').format(dmail.createdAt.toLocal())}',
                style: theme.textTheme.titleMedium,
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
      ),
    );
  }
}
