// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../images/booru_image.dart';

class DefaultNoteEditImage extends ConsumerWidget {
  const DefaultNoteEditImage({
    super.key,
    required this.auth,
    required this.imageUrl,
    required this.constraints,
  });

  final BooruConfigAuth auth;
  final String imageUrl;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruImage(
      config: auth,
      borderRadius: BorderRadius.zero,
      imageUrl: imageUrl,
      imageWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
      imageHeight: constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : null,
      fit: BoxFit.contain,
    );
  }
}
