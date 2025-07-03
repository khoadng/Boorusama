// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../widgets/theme_section.dart';

class ThemeConfigsPage extends ConsumerWidget {
  const ThemeConfigsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.themeTyped),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: ThemeSection(
        theme: theme,
        onThemeUpdated: (theme) {
          ref.editNotifier.updateTheme(theme);
          showSimpleSnackBar(
            context: context,
            duration: const Duration(seconds: 3),
            content: const Text(
              'Your theme will be applied when you save this profile',
            ),
          );
        },
      ),
    );
  }
}
