// Flutter imports:
import 'package:flutter/material.dart';

class UserDetailsSectionCard extends StatelessWidget {
  const UserDetailsSectionCard({
    required this.child,
    required this.title,
    super.key,
  });

  factory UserDetailsSectionCard.text({
    required Widget child,
    required String title,
    Key? key,
  }) =>
      UserDetailsSectionCard(
        key: key,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: child,
      );

  final Widget child;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
