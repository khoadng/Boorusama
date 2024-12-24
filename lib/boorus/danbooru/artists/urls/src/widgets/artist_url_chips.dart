// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/foundation/url_launcher.dart';
import '../../../../../../core/posts/sources/source.dart';
import '../../../../../../core/widgets/widgets.dart';

class DanbooruArtistUrlChips extends StatelessWidget {
  const DanbooruArtistUrlChips({
    required this.artistUrls,
    super.key,
    this.alignment,
  });

  final List<String> artistUrls;
  final WrapAlignment? alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: alignment ?? WrapAlignment.center,
      children: [
        for (final url in artistUrls)
          PostSource.from(url).whenWeb(
            (source) => Tooltip(
              message: source.url,
              child: InkWell(
                onTap: () => launchExternalUrlString(source.url),
                child: WebsiteLogo(
                  url: source.faviconUrl,
                  size: 24,
                ),
              ),
            ),
            () => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
