// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../settings/providers.dart';
import '../../../../theme/utils.dart';
import '../../../../utils/flutter_utils.dart';
import '../pages/favorite_tag_label_details_page.dart';

class FavoriteTagLabelChip extends ConsumerWidget {
  const FavoriteTagLabelChip({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      Theme.of(context).colorScheme.primary,
      ref.watch(settingsProvider),
    );

    return SizedBox(
      height: 28,
      child: RawChip(
        onPressed: () {
          Navigator.of(context).push(
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
              )
            : null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        label: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.7,
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
