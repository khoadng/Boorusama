// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/dtext/dtext.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../configs/providers.dart';
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
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
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
                    '${context.t.profile.messages.sender}: ',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    fromUser?.name ?? 'Anon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: DanbooruUserColor.of(
                        context,
                      ).fromLevel(fromUser?.level),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${context.t.profile.messages.recipient}: ',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    toUser?.name ?? 'Anon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: DanbooruUserColor.of(
                        context,
                      ).fromLevel(toUser?.level),
                    ),
                  ),
                ],
              ),
              Text(
                '${context.t.profile.messages.date}: ${DateFormat('MMM d, yyyy hh:mm a').format(dmail.createdAt.toLocal())}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Dtext.parse(
                parseDtext(dmail.body),
                '[quote]',
                '[/quote]',
              ),
              const SizedBox(height: 16),
              if (!loginDetails.hasStrictSFW)
                FilledButton(
                  onPressed: () {
                    launchExternalUrlString('${config.url}dmails/${dmail.id}');
                  },
                  child: Text(
                    '${context.t.post.action.view_in_browser} (LOGGED IN REQUIRED)',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
