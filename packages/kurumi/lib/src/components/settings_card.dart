import 'package:material_ui/material_ui.dart';

enum KurumiSettingsCardSurface {
  standard,
  high,
}

class KurumiSettingsCard extends StatelessWidget {
  const KurumiSettingsCard({
    required this.child,
    super.key,
    this.onTap,
    this.margin,
    this.padding,
    this.title,
    this.trailing,
    this.surface = KurumiSettingsCardSurface.standard,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final Widget? trailing;
  final KurumiSettingsCardSurface surface;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = this.title;

    return Container(
      margin:
          margin ??
          const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            KurumiSettingsCardTitle(
              title: title,
              trailing: trailing,
            ),
          Semantics(
            button: onTap != null,
            enabled: onTap != null,
            onTap: onTap,
            child: Material(
              color: switch (surface) {
                KurumiSettingsCardSurface.standard =>
                  colorScheme.surfaceContainer,
                KurumiSettingsCardSurface.high =>
                  colorScheme.surfaceContainerHigh,
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: onTap,
                child: Container(
                  padding:
                      padding ??
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KurumiSettingsCardTitle extends StatelessWidget {
  const KurumiSettingsCardTitle({
    required this.title,
    super.key,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w800,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
