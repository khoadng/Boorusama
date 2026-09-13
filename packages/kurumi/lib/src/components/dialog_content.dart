import 'package:material_ui/material_ui.dart';

/// The existing wide-content dialog frame used by long-form app dialogs.
class KurumiDialogContent extends StatelessWidget {
  const KurumiDialogContent({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}
