// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'changelog_dialog.dart';
import 'what_news.dart';

extension ChangelogWidgetRefX on WidgetRef {
  Future<void> showChangelogDialogIfNeeded(Box<String> box) async {
    final data = await loadLatestChangelogFromAssets();
    final shouldShow = shouldShowChangelogDialog(
      box,
      data.version,
    );

    if (shouldShow) {
      if (!context.mounted) return;

      final _ = await showDialog(
        context: context,
        builder: (context) => ChangelogDialog(data: data),
      );

      await markChangelogAsSeen(data.version, box);
    }
  }
}
