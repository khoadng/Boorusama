// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../theme.dart';
import '../types/bulk_download_session.dart';

class AuthConfigChangedDialog extends ConsumerWidget {
  const AuthConfigChangedDialog({
    required this.session,
    super.key,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionUrl = session.session.auth.siteUrl;
    final currentUrl = ref.watchConfigAuth;
    final hasMismatch = sessionUrl != currentUrl.url;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              context.t.bulk_downloads.auth_changed.profile_mismatch,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            if (hasMismatch) ...[
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                  children: [
                    TextSpan(
                      text: context.t.bulk_downloads.auth_changed.current_site,
                    ),
                    TextSpan(
                      text: currentUrl.url,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                  children: [
                    TextSpan(
                      text: context.t.bulk_downloads.auth_changed.download_site,
                    ),
                    TextSpan(
                      text: sessionUrl,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (hasMismatch)
              Text(
                context.t.bulk_downloads.auth_changed.has_mismatch_warning,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              )
            else
              Text(
                context.t.bulk_downloads.auth_changed.no_mismatch_warning,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 20),
            if (hasMismatch)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    context.t.generic.action.ok,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else ...[
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    context.t.bulk_downloads.auth_changed.kContinue,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    context.t.generic.action.cancel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
