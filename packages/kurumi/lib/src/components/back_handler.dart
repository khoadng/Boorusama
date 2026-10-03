import 'package:material_ui/material_ui.dart';

/// Claims the system back button while [enabled], so it closes something
/// transient like a menu instead of reaching the route.
///
/// A blocking [PopScope] would also notify every other [PopScope] on the
/// route, letting them pop the page or show their own dialogs.
class KurumiBackHandler extends StatelessWidget {
  const KurumiBackHandler({
    required this.enabled,
    required this.onBack,
    required this.child,
    super.key,
  });

  final bool enabled;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      switch (Router.maybeOf(context)?.backButtonDispatcher) {
        null => PopScope(
          canPop: !enabled,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && enabled) onBack();
          },
          child: child,
        ),
        _ => BackButtonListener(
          onBackButtonPressed: () async {
            if (!enabled) return false;
            onBack();
            return true;
          },
          child: child,
        ),
      };
}
