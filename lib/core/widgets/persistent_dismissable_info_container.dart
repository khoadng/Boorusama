// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../cache/persistent/providers.dart';
import 'dismissable_info_container.dart';

final _dismissedStateProvider = FutureProvider.family<bool, String>((
  ref,
  key,
) async {
  final box = await ref.watch(persistentCacheBoxProvider.future);
  return box.get(key) == 'true';
});

class PersistentDismissableInfoContainer extends ConsumerWidget {
  const PersistentDismissableInfoContainer({
    required this.storageKey,
    required this.content,
    super.key,
    this.mainColor,
    this.actions = const [],
    this.padding,
    this.shouldShow,
    this.onDismiss,
    this.dontShowAgainText,
  });

  final String storageKey;
  final String content;
  final Color? mainColor;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final bool Function()? shouldShow;
  final VoidCallback? onDismiss;
  final String? dontShowAgainText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(_dismissedStateProvider(storageKey))
        .when(
          data: (isDismissed) {
            if (isDismissed || (shouldShow != null && !shouldShow!())) {
              return const SizedBox.shrink();
            }

            return DismissableInfoContainer(
              content: content,
              mainColor: mainColor,
              padding: padding,
              actions: [
                ...actions,
                TextButton(
                  onPressed: ref
                      .watch(persistentCacheBoxProvider)
                      .maybeWhen(
                        data: (box) => () async {
                          await box.put(storageKey, 'true');
                          ref.invalidate(_dismissedStateProvider(storageKey));
                          onDismiss?.call();
                        },
                        orElse: () => null,
                      ),
                  child: Text(
                    dontShowAgainText ?? "Don't show this message again",
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}
