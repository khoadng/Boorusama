import 'package:material_ui/material_ui.dart';

class KurumiHoverAwareContainer extends StatefulWidget {
  const KurumiHoverAwareContainer({
    required this.child,
    super.key,
    this.borderRadius,
  });

  final Widget child;
  final BorderRadius? borderRadius;

  @override
  State<KurumiHoverAwareContainer> createState() =>
      _KurumiHoverAwareContainerState();
}

class _KurumiHoverAwareContainerState extends State<KurumiHoverAwareContainer> {
  var isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isHovered
              ? Theme.of(context).colorScheme.surfaceContainer
              : Colors.transparent,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
        ),
        child: widget.child,
      ),
    );
  }
}
