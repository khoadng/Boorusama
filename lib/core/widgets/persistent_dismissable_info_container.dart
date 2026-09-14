// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../cache/persistent/providers.dart';
import 'dismissable_info_container.dart';

final dismissedStateProvider = FutureProvider.family<bool, String>((ref, key) {
  final store = ref.watch(persistentCacheStoreProvider);
  return store.get(key) == 'true';
});

Future<void> dismissPersistently(WidgetRef ref, String storageKey) async {
  await ref.read(persistentCacheStoreProvider).put(storageKey, 'true');
  ref.invalidate(dismissedStateProvider(storageKey));
}

class PersistentDismissalWrapper extends ConsumerWidget {
  const PersistentDismissalWrapper({
    required this.storageKey,
    required this.child,
    super.key,
    this.shouldShow,
  });

  final String storageKey;
  final Widget child;
  final bool Function()? shouldShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(dismissedStateProvider(storageKey))
        .when(
          data: (isDismissed) {
            if (isDismissed || (shouldShow != null && !shouldShow!())) {
              return const SizedBox.shrink();
            }
            return child;
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}

class PersistentDismissableInfoContainer extends ConsumerWidget {
  const PersistentDismissableInfoContainer({
    required this.storageKey,
    required this.content,
    super.key,
    this.mainColor,
    this.actions = const [],
    this.padding,
    this.buttonsPadding,
    this.shouldShow,
    this.onDismiss,
    this.onLinkTap,
  });

  final String storageKey;
  final String content;
  final Color? mainColor;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? buttonsPadding;
  final bool Function()? shouldShow;
  final VoidCallback? onDismiss;
  final OnTap? onLinkTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PersistentDismissalWrapper(
      storageKey: storageKey,
      shouldShow: shouldShow,
      child: DismissableInfoContainer(
        content: content,
        mainColor: mainColor,
        padding: padding,
        buttonsPadding: buttonsPadding,
        onLinkTap: onLinkTap,
        actions: [
          ...actions,
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Kurumi.themeOf(context).colorScheme.onSurface,
            ),
            onPressed: () async {
              await dismissPersistently(ref, storageKey);
              onDismiss?.call();
            },
            child: Text(
              context.t.reminder.dont_show_again,
            ),
          ),
        ],
      ),
    );
  }
}
