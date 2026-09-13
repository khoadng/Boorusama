import 'package:material_ui/material_ui.dart';

class KurumiSideMenuTile extends StatelessWidget {
  const KurumiSideMenuTile({
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
    return Semantics(
      button: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
      ),
    );
  }
}
