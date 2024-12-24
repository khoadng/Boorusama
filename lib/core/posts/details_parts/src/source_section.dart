// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/url_launcher.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../../details/details.dart';
import '../../post/post.dart';
import '../../sources/source.dart';

class DefaultInheritedSourceSection<T extends Post> extends StatelessWidget {
  const DefaultInheritedSourceSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<T>(context);

    return SliverToBoxAdapter(
      child: post.source.whenWeb(
        (source) => SourceSection(
          source: source,
        ),
        () => const SizedBox.shrink(),
      ),
    );
  }
}

class SourceSection extends StatelessWidget {
  const SourceSection({
    required this.source,
    super.key,
    this.title,
  });

  final String? title;
  final WebSource source;

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
            title ?? 'post.detail.source_label'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
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
              onTap: () => launchExternalUrlString(source.url),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      WebsiteLogo(url: source.faviconUrl),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: Text(
                          _mapUriToSourceText(Uri.parse(source.sourceHost)),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Symbols.arrow_outward),
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
