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
    final data = await loadLatestChangelogFromAssets(box);
    final shouldShow = await shouldShowChangelogDialog(
      box,
      data.version,
    );

    if (shouldShow) {
      if (!context.mounted) return;

      final _ = await showDialog(
        context: context,
        routeSettings: const RouteSettings(
          name: 'changelog',
        ),
        builder: (context) => ChangelogDialog(data: data),
      );

      await markChangelogAsSeen(data.version, box);
    }
  }
}

bool isSignificantUpdate(ReleaseVersion? previous, ReleaseVersion? current) {
  if (previous == null || current == null) return false;

  // only check major and minor versions of official releases
  if (previous is Official && current is Official) {
    return previous.version.minor < current.version.minor ||
        previous.version.major < current.version.major;
  }

  return false;
}
