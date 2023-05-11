// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/ui/boorus/website_logo.dart';
import 'package:boorusama/core/utils.dart';

class SourceSection extends StatelessWidget {
  const SourceSection({
    super.key,
    required this.url,
    this.isIcoUrl = false,
  });

  final String url;
  final bool isIcoUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Text(
            'Source',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () => launchExternalUrlString(url),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).hintColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      WebsiteLogo(
                        url: url,
                        isIcoUrl: isIcoUrl,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: Text(
                          _mapUriToSourceText(Uri.parse(url)),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_outward)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _mapUriToSourceText(Uri uri) {
  return uri.host.replaceAll('www.', '');
}
