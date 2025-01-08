// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/display.dart';

final postGridSideBarVisibleProvider = StateProvider<bool>((ref) {
  return false;
});

class PostGridConfigRegion extends ConsumerWidget {
  const PostGridConfigRegion({
    super.key,
    required this.blacklistHeader,
    required this.postController,
    required this.child,
  });

  final Widget child;
  final Widget blacklistHeader;
  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrientationLayoutBuilder(
          portrait: (context) => const SizedBox.shrink(),
          landscape: (context) => ResponsiveLayoutBuilder(
            phone: (context) => const SizedBox.shrink(),
            pc: (context) => const SizedBox.shrink(),
          ),
        ),
        OrientationLayoutBuilder(
          portrait: (context) => const SizedBox.shrink(),
          landscape: (context) => ResponsiveLayoutBuilder(
            phone: (context) => const SizedBox.shrink(),
            pc: (context) => const DesktopPostConfigRevealer(),
          ),
        ),
        Expanded(
          child: child,
        ),
      ],
    );
  }
}

class DesktopPostConfigRevealer extends ConsumerWidget {
  const DesktopPostConfigRevealer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              ref.read(postGridSideBarVisibleProvider.notifier).state =
                  !ref.read(postGridSideBarVisibleProvider.notifier).state;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
