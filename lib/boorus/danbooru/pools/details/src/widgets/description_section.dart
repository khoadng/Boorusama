// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../foundation/html.dart';
import '../../../../../../foundation/url_launcher.dart';
import '../../../../../../foundation/utils/html_utils.dart';
import '../../../pool/types.dart';
import '../providers/description_provider.dart';

class PoolDescriptionSection extends ConsumerWidget {
  const PoolDescriptionSection({
    super.key,
    required this.pool,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final params = (config, pool.id);
    final loginDetails = ref.watch(
      booruLoginDetailsProvider(config),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: ref
          .watch(poolDescriptionProvider(params))
          .maybeWhen(
            data: (data) =>
                data.description.isNotEmpty &&
                    hasTextBetweenDiv(data.description)
                ? AppHtml(
                    onLinkTap: !loginDetails.hasStrictSFW
                        ? (url, attributes, element) => _onHtmlLinkTapped(
                            attributes,
                            url,
                            data.descriptionEndpointRefUrl,
                          )
                        : null,
                    data: data.description,
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
    );
  }

  void _onHtmlLinkTapped(
    Map<String, String> attributes,
    String? url,
    String endpoint,
  ) {
    if (url == null) return;

    if (!attributes.containsKey('class')) return;
    final att = attributes['class']!.split(' ').toList();
    if (att.isEmpty) return;
    if (att.contains('dtext-external-link')) {
      launchExternalUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppWebView,
      );
    } else if (att.contains('dtext-wiki-link')) {
      launchExternalUrl(
        Uri.parse('$endpoint$url'),
        mode: LaunchMode.inAppWebView,
      );
      // ignore: no-empty-block
    } else if (att.contains('dtext-post-search-link')) {
      // AppRouter.router.navigateTo(
      //             context,
      //             "/posts/search",
      //             routeSettings: RouteSettings(arguments: [tag.rawName]),
      //           )
    }
  }
}
