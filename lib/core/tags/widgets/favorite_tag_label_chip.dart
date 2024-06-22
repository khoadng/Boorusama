// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'favorite_tag_label_details_page.dart';

class FavoriteTagLabelChip extends ConsumerWidget {
  const FavoriteTagLabelChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      context.colorScheme.primary,
      ref.watch(settingsProvider),
    );

    return SizedBox(
      height: 28,
      child: RawChip(
        onPressed: () {
          context.navigator.push(
            CupertinoPageRoute(
              builder: (context) => FavoriteTagLabelDetailsPage(
                label: label,
              ),
            ),
          );
        },
        padding: kPreferredLayout.isMobile
            ? const EdgeInsets.all(4)
            : EdgeInsets.zero,
        visualDensity: const ShrinkVisualDensity(),
        backgroundColor: colors?.backgroundColor,
        side: colors != null
            ? BorderSide(
                color: colors.borderColor,
                width: 1,
              )
            : null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        label: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.screenWidth * 0.7,
          ),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: colors?.foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
