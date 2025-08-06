// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../settings/routes.dart';
import '../../../theme.dart';

class DisabledDownloadManagerPage extends ConsumerWidget {
  const DisabledDownloadManagerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.download.downloads),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.t.download.download_manager_disabled,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'You are using the legacy downloader. Please enable the new downloader in the settings.'
                    .hc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  openDownloadSettingsPage(ref);
                },
                child: Text(context.t.download.open_settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
