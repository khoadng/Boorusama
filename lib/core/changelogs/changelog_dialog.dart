// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/widgets/widgets.dart';
import '../theme.dart';
import 'what_news.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({
    super.key,
    required this.data,
  });

  final ChangelogData data;

  @override
  Widget build(BuildContext context) {
    final version = data.version;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: Row(
                          children: [
                            Text(
                              'app_update.whats_new',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ).tr(),
                            const SizedBox(width: 8),
                            CompactChip(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              textColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              label: version.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      splashRadius: 18,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
                height: 0,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    bottom: 12,
                    top: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      switch (data.version) {
                        final Unreleased u => Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              bottom: 4,
                            ),
                            child: Text(
                              '${'comment.list.last_updated'.tr()}: ${u.lastUpdated?.fuzzify(locale: Localizations.localeOf(context))}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.hintColor,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        _ => const SizedBox.shrink(),
                      },
                      SingleChildScrollView(
                        child: Row(
                          children: [
                            Expanded(
                              child: MarkdownBody(
                                data: data.content,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
