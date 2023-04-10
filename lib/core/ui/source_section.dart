// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/boorus/website_logo.dart';
import 'package:boorusama/core/utils.dart';

class SourceSection extends StatelessWidget {
  const SourceSection({
    super.key,
    required this.post,
  });

  final Post post;

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
              onTap: () => launchExternalUrl(Uri.parse(post.source!)),
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
                        url: _getHost(Uri.parse(post.source!)),
                        isIcoUrl: _useIco(Uri.parse(post.source!)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: Text(
                          _mapUriToSourceText(Uri.parse(post.source!)),
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

String _getHost(Uri uri) {
  if (uri.host.contains('artstation.com')) return 'artstation.com';
  if (uri.host.contains('discordapp.com')) return 'discordapp.com';
  if (uri.host.contains('kym-cdn.com')) return 'knowyourmeme.com';
  if (uri.host.contains('images-wixmp')) return 'deviantart.com';
  if (uri.host.contains('fantia.jp')) return 'fantia.jp';
  if (uri.host.contains('hentai-foundry.com')) return 'hentai-foundry.com';
  if (uri.host.contains('exhentai.org')) return 'e-hentai.org';
  if (uri.host.contains('lofter.com')) {
    return 'https://www.lofter.com/favicon.ico';
  }

  return uri.host;
}

bool _useIco(Uri uri) {
  if (uri.host.contains('lofter.com')) return true;
  return false;
}

String _mapUriToSourceText(Uri uri) {
  return uri.host.replaceAll('www.', '');
}
