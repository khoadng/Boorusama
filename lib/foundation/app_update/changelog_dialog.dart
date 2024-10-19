// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/app_update/what_news.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';

extension ChangelogWidgetRefX on WidgetRef {
  Future<void> showChangelogDialogIfNeeded() async {
    final data = await loadLatestChangelogFromAssets();
    final miscBox = read(miscDataBoxProvider);
    final shouldShow = shouldShowChangelogDialog(
      miscBox,
      data.version,
    );

    if (shouldShow) {
      if (!context.mounted) return;

      final _ = await showDialog(
        context: context,
        builder: (context) => ChangelogDialog(data: data),
      );

      await markChangelogAsSeen(data.version, miscBox);
    }
  }
}

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
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
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ).tr(),
                            const SizedBox(width: 8),
                            CompactChip(
                              backgroundColor: context.colorScheme.primary,
                              textColor: context.colorScheme.onPrimary,
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
                                color: context.theme.hintColor,
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
