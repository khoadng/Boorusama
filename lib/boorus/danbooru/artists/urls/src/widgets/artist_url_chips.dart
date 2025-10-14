// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/config_widgets/website_logo.dart';
import '../../../../../../core/posts/sources/types.dart';
import '../../../../../../foundation/url_launcher.dart';

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
                child: ConfigAwareWebsiteLogo(
                  url: source.url,
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
