// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../configs/config/providers.dart';
import '../../../../tags/categories/providers.dart';
import '../../../../themes/colors/providers.dart';
import '../../../../themes/colors/types.dart';
import 'raw_tag_chip.dart';

class TagChip extends ConsumerWidget {
  const TagChip({
    required this.text,
    required this.auth,
    super.key,
    this.category,
    this.postCount,
    this.onTap,
    this.maxWidth,
    this.fallbackColor,
    this.colorOverride,
    this.transformText = false,
    this.showPostCount = true,
  });

  final String text;
  final String? category;
  final int? postCount;
  final BooruConfigAuth auth;
  final VoidCallback? onTap;
  final double? maxWidth;
  final Color? fallbackColor;
  final Color? colorOverride;
  final bool transformText;
  final bool showPostCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = _resolveColors(ref);
    final displayText = transformText
        ? text.toLowerCase().replaceAll('_', ' ')
        : text;
    final loginDetails = ref.watch(booruLoginDetailsProvider(auth));

    final subtitle = _buildSubtitle(loginDetails);

    return RawTagChip(
      text: displayText,
      subtitle: subtitle,
      onTap: onTap,
      maxWidth: maxWidth,
      backgroundColor: colors?.backgroundColor,
      foregroundColor: colors?.foregroundColor,
      borderColor: colors?.borderColor,
    );
  }

  ChipColors? _resolveColors(WidgetRef ref) {
    // Priority: colorOverride → category → fallbackColor
    if (colorOverride != null) {
      return ref.watch(booruChipColorsProvider).fromColor(colorOverride);
    }

    if (category != null) {
      return ref.watch(
        chipColorsFromTagStringProvider((auth, category!)),
      );
    }

    return ref.watch(booruChipColorsProvider).fromColor(fallbackColor);
  }

  String? _buildSubtitle(BooruLoginDetails loginDetails) {
    if (!showPostCount ||
        loginDetails.hasStrictSFW ||
        postCount == null ||
        postCount! <= 0) {
      return null;
    }

    return NumberFormat.compact().format(postCount);
  }
}

class AutoCategoryTagChip extends ConsumerWidget {
  const AutoCategoryTagChip({
    required this.text,
    required this.auth,
    super.key,
    this.onTap,
    this.maxWidth,
    this.fallbackColor,
    this.colorOverride,
    this.transformText = true,
  });

  final String text;
  final BooruConfigAuth auth;
  final VoidCallback? onTap;
  final double? maxWidth;
  final Color? fallbackColor;
  final Color? colorOverride;
  final bool transformText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(booruTagTypeProvider((auth, text))).valueOrNull;

    return TagChip(
      text: text,
      auth: auth,
      category: category,
      onTap: onTap,
      maxWidth: maxWidth,
      fallbackColor: fallbackColor,
      colorOverride: colorOverride,
      transformText: transformText,
      showPostCount: false, // Auto category lookup doesn't provide post count
    );
  }
}
