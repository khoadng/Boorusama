// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/iap/iap.dart';

class SubscriptionPlanTile extends StatelessWidget {
  const SubscriptionPlanTile({
    required this.package,
    super.key,
    this.selected = false,
    this.onTap,
    this.saveIndicator,
  });

  final Package package;
  final bool selected;
  final void Function()? onTap;
  final Widget? saveIndicator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(16);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: EdgeInsets.all(12 + (selected ? 0 : 2.25)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: borderRadius,
            border: Border.all(
              width: selected ? 2.5 : 0.25,
              color:
                  selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    switch (package.type) {
                      null => '???',
                      PackageType.monthly => 'Monthly',
                      PackageType.annual => 'Yearly',
                    },
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (saveIndicator != null) ...[
                    const SizedBox(width: 8),
                    saveIndicator!,
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: package.product.price,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${package.typeDurationString}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
