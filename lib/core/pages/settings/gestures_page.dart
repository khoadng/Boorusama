// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/settings/widgets/settings_header.dart';
import 'package:boorusama/core/pages/settings/widgets/settings_tile.dart';
import 'package:boorusama/widgets/widgets.dart';

class GesturesPage extends ConsumerWidget {
  const GesturesPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('Gestures'),
        ),
        body: child,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SettingsHeader(label: 'Image viewer'),
              SettingsTile<PostDetailsAction>(
                title: const Text('Swipe image down'),
                selectedOption: settings.postDetailsSwipeDownAction,
                items: PostDetailsAction.values,
                onChanged: (value) => ref.updateSettings(
                    settings.copyWith(postDetailsSwipeDownAction: value)),
                optionBuilder: (value) => Text(
                  switch (value) {
                    PostDetailsAction.goBack => 'Go back',
                    PostDetailsAction.download => 'Download',
                    PostDetailsAction.share => 'Share',
                    PostDetailsAction.toggleBookmark => 'Toggle bookmark',
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
