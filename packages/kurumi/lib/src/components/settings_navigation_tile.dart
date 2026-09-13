import 'package:material_ui/material_ui.dart';

class KurumiSettingsEntryTile extends StatelessWidget {
  const KurumiSettingsEntryTile({
    required this.title,
    required this.leading,
    super.key,
    this.onTap,
    this.showLeading = true,
    this.subtitle,
    this.selected = false,
    this.dense = false,
  });

  final bool showLeading;
  final String title;
  final VoidCallback? onTap;
  final Widget leading;
  final String? subtitle;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: selected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        child: Material(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: dense
                    ? 4
                    : subtitle != null
                    ? 6
                    : 10,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: showLeading ? 4 : 6,
              ),
              child: Row(
                children: [
                  if (showLeading)
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 32,
                      ),
                      margin: const EdgeInsets.only(
                        left: 4,
                      ),
                      child: leading,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: selected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer
                                : null,
                          ),
                        ),
                        if (subtitle != null) ...[
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
