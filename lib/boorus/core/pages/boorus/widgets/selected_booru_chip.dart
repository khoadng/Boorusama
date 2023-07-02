// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/utils/flutter_utils.dart';

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    super.key,
    required this.booru,
  });

  final Booru booru;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PostSource.from(booru.url).whenWeb(
            (source) => BooruLogo(source: source),
            () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Text(
            booru.booruType.stringify(),
            style: context.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
