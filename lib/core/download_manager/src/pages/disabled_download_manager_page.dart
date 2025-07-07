// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: const Text('Downloads'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Download manager is disabled',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'You are using the legacy downloader. Please enable the new downloader in the settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  openDownloadSettingsPage(ref);
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
