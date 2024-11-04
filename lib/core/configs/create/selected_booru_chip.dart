// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme.dart';

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    super.key,
    required this.booruType,
    required this.url,
  });

  final BooruType booruType;
  final String url;

  @override
  Widget build(BuildContext context) {
    final source = PostSource.from(url);

    return ListTile(
      minVerticalPadding: 0,
      horizontalTitleGap: 12,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      leading: BooruLogo.fromBooruType(booruType, url),
      title: Text(
        source.whenWeb(
          (source) => source.uri.host,
          () => url,
        ),
        style: context.textTheme.titleLarge,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('using ${booruType.stringify()}'),
    );
  }
}
