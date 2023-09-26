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
  });

  final String url;
  final BooruType booruType;

  @override
  Widget build(BuildContext context) {
    final source = PostSource.from(url);

    return ListTile(
      minVerticalPadding: 0,
      horizontalTitleGap: 4,
      visualDensity: VisualDensity.compact,
      leading: source.whenWeb(
        (source) => BooruLogo(source: source),
        () => const SizedBox.shrink(),
      ),
      title: Text(
        source.whenWeb(
          (source) => source.uri.host,
          () => url,
        ),
        style: context.textTheme.titleLarge,
      ),
      subtitle: Text('using ${booruType.stringify()}'),
    );
  }
}
