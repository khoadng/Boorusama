// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

class VideoPlayerErrorContainer extends StatelessWidget {
  const VideoPlayerErrorContainer({
    required this.title,
    required this.subtitle,
    required this.onOpenSettings,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title case final t?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                t,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (subtitle case final s?)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                s,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          if (onOpenSettings case final cb?)
            FilledButton(
              onPressed: cb,
              child: Text(
                context.t.settings.open_app_settings,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
