// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    super.key,
    required this.booruType,
    required this.url,
    this.isUnknown = false,
  });

  final String url;
  final BooruType booruType;
  final bool isUnknown;

  @override
  Widget build(BuildContext context) {
    final source = PostSource.from(url);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          source.whenWeb(
            (source) => BooruLogo(source: source),
            () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Text(
            isUnknown
                ? source.whenWeb(
                    (source) => source.uri.host,
                    () => url,
                  )
                : booruType.stringify(),
            style: context.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
