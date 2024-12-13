// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../routers/routers.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/listing_provider.dart';

// Project imports:


class SettingsInteractionBlocker extends ConsumerWidget {
  const SettingsInteractionBlocker({
    super.key,
    this.padding,
    required this.description,
    required this.block,
    required this.child,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool block;
  final Widget description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GrayedOut(
          grayedOut: block,
          child: child,
        ),
        if (block)
          Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FaIcon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.error,
                    size: 14,
                  ),
                ),
                Expanded(
                  child: description,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ListingSettingsInteractionBlocker extends ConsumerWidget {
  const ListingSettingsInteractionBlocker({
    super.key,
    this.padding,
    this.onNavigateAway,
    required this.child,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final void Function()? onNavigateAway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCustomListing = ref.watch(hasCustomListingSettingsProvider);
    final config = ref.watchConfig;

    return SettingsInteractionBlocker(
      padding: padding,
      block: hasCustomListing,
      description: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
          children: [
            const TextSpan(
              text: 'These settings are overridden by custom listing. Go to ',
            ),
            TextSpan(
              text: "Booru's profile",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  goToUpdateBooruConfigPage(
                    context,
                    config: config,
                    initialTab: 'listing',
                  );

                  onNavigateAway?.call();
                },
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const TextSpan(
              text: ' page instead.',
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
