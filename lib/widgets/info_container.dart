// Flutter imports:
import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    super.key,
    required this.contentBuilder,
    this.title,
  });

  final String? title;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return TemplateContainer(
      borderColor: Theme.of(context).colorScheme.primary,
      icon: Icon(
        Icons.info,
        color: Theme.of(context).colorScheme.primary,
      ),
      titleBackgroundColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.2),
      title: title ?? 'Info',
      titleColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      contentBuilder: contentBuilder,
    );
  }
}

class WarningContainer extends StatelessWidget {
  const WarningContainer({
    super.key,
    required this.contentBuilder,
    this.title,
    this.margin,
  });

  final EdgeInsetsGeometry? margin;
  final String? title;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return TemplateContainer(
      margin: margin,
      borderColor: Theme.of(context).colorScheme.error,
      icon: Icon(
        Icons.warning,
        color: Theme.of(context).colorScheme.error,
      ),
      titleBackgroundColor:
          Theme.of(context).colorScheme.error.withOpacity(0.2),
      title: title,
      titleColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      contentBuilder: contentBuilder,
    );
  }
}

class TemplateContainer extends StatelessWidget {
  const TemplateContainer({
    super.key,
    required this.contentBuilder,
    this.borderColor,
    this.titleBackgroundColor,
    this.title,
    this.titleColor,
    this.icon,
    this.margin,
  });

  final Widget Function(BuildContext context) contentBuilder;
  final Color? borderColor;
  final Color? titleBackgroundColor;
  final String? title;
  final Color? titleColor;
  final Widget? icon;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 40,
            color: titleBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (icon != null) icon!,
                      const SizedBox(width: 8),
                      if (title != null)
                        Text(
                          title!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: contentBuilder(context),
          ),
        ],
      ),
    );
  }
}
