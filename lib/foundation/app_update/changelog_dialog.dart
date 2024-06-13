// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/app_update/what_news.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

extension ChangelogWidgetRefX on WidgetRef {
  Future<void> showChangelogDialogIfNeeded() async {
    final data = await loadLatestChangelogFromAssets();
    final packageInfo = read(packageInfoProvider);
    final miscBox = read(miscDataBoxProvider);
    final shouldShow = await shouldShowChangelogDialog(
      packageInfo,
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
        horizontal: 20,
        vertical: 24,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
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
                    const Spacer(),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 4,
                  ),
                  child: SingleChildScrollView(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
