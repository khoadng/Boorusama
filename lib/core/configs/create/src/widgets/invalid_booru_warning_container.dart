// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../providers/internal_providers.dart';

class InvalidBooruWarningContainer extends ConsumerWidget {
  const InvalidBooruWarningContainer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ref.watch(validateConfigProvider).maybeWhen(
          orElse: () => const SizedBox(),
          data: (value) => value == false
              ? WarningContainer(
                  title: 'Empty results',
                  contentBuilder: (context) => Text(
                    'The app cannot find any posts with this engine. Please try with another one.',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                )
              : const SizedBox(),
          error: (error, st) => Stack(
            children: [
              WarningContainer(
                title: 'Error',
                contentBuilder: (context) => Text(
                  'It seems like the site is not running on the selected engine. Please try with another one.',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
