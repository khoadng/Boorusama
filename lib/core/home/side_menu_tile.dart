// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'home_page_controller.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final Widget title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final homeController = InheritedHomePageController.maybeOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Workaround to make the animation smoother
          Future.delayed(
            const Duration(milliseconds: 200),
            () {
              if (context.mounted) {
                homeController?.closeMenu();
              }
            },
          );
          onTap();
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleSmall ?? const TextStyle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                icon,
                const SizedBox(width: 12),
                title,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
