// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../config_widgets/website_logo.dart';
import '../../details/types.dart';
import '../../post/types.dart';
import '../../sources/types.dart';

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

class SourceSection extends ConsumerWidget {
  const SourceSection({
    required this.source,
    super.key,
    this.title,
  });

  final String? title;
  final WebSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Text(
            title ?? context.t.post.detail.source_label,
            style: Kurumi.themeOf(context).textTheme.titleLarge?.copyWith(
              color: Kurumi.themeOf(context).colorScheme.hintColor,
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
              onTap: () => ref
                  .read(externalUrlLauncherProvider)
                  .launch(Uri.parse(source.url)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Kurumi.themeOf(context).colorScheme.hintColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ConfigAwareWebsiteLogo(url: source.url),
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
