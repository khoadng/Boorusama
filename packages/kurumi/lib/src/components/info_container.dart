import 'package:material_ui/material_ui.dart';

class KurumiInfoContainer extends StatelessWidget {
  const KurumiInfoContainer({
    required this.contentBuilder,
    super.key,
    this.title,
    this.actions,
  });

  final String? title;
  final Widget Function(BuildContext context) contentBuilder;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return KurumiTemplateContainer(
      borderColor: Theme.of(context).colorScheme.primary,
      icon: Icon(
        Icons.info,
        color: Theme.of(context).colorScheme.primary,
      ),
      titleBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
      title: title ?? 'Info',
      titleColor: Theme.of(context).colorScheme.onSurface,
      contentBuilder: contentBuilder,
      actions: actions,
    );
  }
}

class KurumiWarningContainer extends StatelessWidget {
  const KurumiWarningContainer({
    required this.contentBuilder,
    super.key,
    this.title,
    this.margin,
    this.actions,
  });

  final EdgeInsetsGeometry? margin;
  final String? title;
  final Widget Function(BuildContext context) contentBuilder;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return KurumiTemplateContainer(
      margin: margin,
      borderColor: Theme.of(context).colorScheme.error,
      icon: Icon(
        Icons.warning,
        color: Theme.of(context).colorScheme.error,
      ),
      titleBackgroundColor: Theme.of(
        context,
      ).colorScheme.error.withValues(alpha: 0.2),
      title: title,
      titleColor: Theme.of(context).colorScheme.onSurface,
      contentBuilder: contentBuilder,
      actions: actions,
    );
  }
}

class KurumiTemplateContainer extends StatefulWidget {
  const KurumiTemplateContainer({
    required this.contentBuilder,
    super.key,
    this.borderColor,
    this.titleBackgroundColor,
    this.title,
    this.titleColor,
    this.icon,
    this.margin,
    this.initiallyExpanded = true,
    this.actions,
  });

  final Widget Function(BuildContext context) contentBuilder;
  final Color? borderColor;
  final Color? titleBackgroundColor;
  final String? title;
  final Color? titleColor;
  final Widget? icon;
  final EdgeInsetsGeometry? margin;
  final bool initiallyExpanded;
  final List<Widget>? actions;

  @override
  State<KurumiTemplateContainer> createState() =>
      _KurumiTemplateContainerState();
}

class _KurumiTemplateContainerState extends State<KurumiTemplateContainer> {
  late bool isExpanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: widget.borderColor != null
            ? Border.all(
                color: widget.borderColor!,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 40,
            color: widget.titleBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (widget.icon != null) widget.icon!,
                      const SizedBox(width: 8),
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.titleColor,
                          ),
                        ),
                      const Spacer(),
                      // Keep the existing expand/collapse interaction while
                      // exposing the same action to assistive technology.
                      Semantics(
                        button: true,
                        expanded: isExpanded,
                        label: widget.title,
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: ExcludeSemantics(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Icon(
                                !isExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: widget.contentBuilder(context),
            ),
            if (widget.actions case final actions?)
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                child: Row(
                  children: actions,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
