// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/theme.dart';
import '../../../foundation/toast.dart';
import '../../../foundation/url_launcher.dart';
import '../client_provider.dart';

class ApiKeyVerifyDialog extends ConsumerWidget {
  const ApiKeyVerifyDialog({
    required this.login,
    required this.apiKey,
    required this.config,
    super.key,
  });

  final String login;
  final String apiKey;
  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Verify API Credentials'.hc),
      content: const Text(
        'The app will open a browser to test your API credentials by attempting to access your account.\n\n'
        'What to expect:\n'
        "• Working credentials: You'll see a bunch of text\n"
        '• Broken credentials: Error page or nothing loads\n\n'
        "If your credentials are correct but you still can't access stuff, that's a Gelbooru problem, not the app. Contact the Gelbooru admins on their Discord server for help with your account access.",
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.hintColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.generic.action.cancel),
        ),
        TextButton(
          onPressed: () {
            final uri = ref
                .watch(
                  gelbooruClientProvider(config.auth),
                )
                .getTestPostUri(
                  userId: login,
                  apiKey: apiKey,
                );

            if (uri != null) {
              launchExternalUrl(uri);

              Navigator.of(context).pop();
            } else {
              showErrorToast(
                context,
                'Invalid URL: ${config.url}',
              );
            }
          },
          child: Text(context.t.generic.action.verify),
        ),
      ],
    );
  }
}
