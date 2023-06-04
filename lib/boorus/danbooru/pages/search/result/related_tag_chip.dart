// Flutter imports:
import 'package:flutter/material.dart';

class RelatedTagButton extends StatelessWidget {
  const RelatedTagButton({
    super.key,
    required this.backgroundColor,
    required this.onPressed,
    required this.label,
  });

  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.only(left: 6, right: 2),
          backgroundColor: Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          side: BorderSide(
            color: Theme.of(context).hintColor,
          ),
        ),
        onPressed: onPressed,
        icon: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          child: label,
        ),
        label: const Icon(Icons.add),
      ),
    );
  }
}
