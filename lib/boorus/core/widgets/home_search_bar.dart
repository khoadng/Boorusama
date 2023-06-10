// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/foundation/app_update/app_update.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'booru_search_bar.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({
    super.key,
    this.onMenuTap,
    this.onTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruSearchBar(
      enabled: false,
      trailing: ref.watch(appUpdateStatusProvider).maybeWhen(
            data: (status) => switch (status) {
              UpdateAvailable d => IconButton(
                  splashRadius: 12,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.arrowUp,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'app_update.update_available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ).tr(),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _VersionChangeVisualizedText(status: d),
                                ],
                              ),
                              const Divider(thickness: 1.5),
                              Row(
                                children: [
                                  Text(
                                    'app_update.whats_new',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ).tr(),
                                ],
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: SingleChildScrollView(
                                    child: Row(
                                      children: [
                                        MarkdownBody(
                                          data: d.releaseNotes,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('app_update.later').tr(),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      launchExternalUrlString(d.storeUrl);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('app_update.update').tr(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              _ => const SizedBox.shrink(),
            },
            orElse: () => const SizedBox.shrink(),
          ),
      leading: onMenuTap != null
          ? IconButton(
              splashRadius: 16,
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _VersionChangeVisualizedText extends StatelessWidget {
  const _VersionChangeVisualizedText({
    required this.status,
  });

  final UpdateAvailable status;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: status.currentVersion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).hintColor,
                ),
          ),
          const TextSpan(text: '  ➞  '),
          TextSpan(
            text: status.storeVersion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ),
    );
  }
}
