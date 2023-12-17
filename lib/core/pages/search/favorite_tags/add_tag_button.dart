// Flutter imports:
import 'package:flutter/material.dart';

class AddTagButton extends StatelessWidget {
  const AddTagButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Material(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(
            Icons.add,
            size: 28,
          ),
        ),
      ),
    );
  }
}
