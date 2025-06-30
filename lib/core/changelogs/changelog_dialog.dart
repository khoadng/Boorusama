// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../core/widgets/widgets.dart';
import '../premiums/premiums.dart';
import '../premiums/providers.dart';
import '../premiums/routes.dart';
import '../theme.dart';
import 'utils.dart';
import 'what_news.dart';

class ChangelogDialog extends ConsumerWidget {
  const ChangelogDialog({
    required this.data,
    super.key,
  });

  final ChangelogData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = data.version;
    final colorScheme = Theme.of(context).colorScheme;
    final significantUpdate =
        isSignificantUpdate(data.previousVersion, data.version);
    final hasPrem =
        ref.watch(showPremiumFeatsProvider) && ref.watch(hasPremiumProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: Row(
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
                            const SizedBox(width: 8),
                            CompactChip(
                              backgroundColor: colorScheme.primary,
                              textColor: colorScheme.onPrimary,
                              label: version.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      splashRadius: 18,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
                height: 0,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    bottom: 12,
                    top: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      switch (data.version) {
                        final Prereleased u => Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              bottom: 4,
                            ),
                            child: Text(
                              '${'comment.list.last_updated'.tr()}: ${u.lastUpdated?.fuzzify(locale: Localizations.localeOf(context))}',
                              style: TextStyle(
                                color: colorScheme.hintColor,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        _ => const SizedBox.shrink(),
                      },
                      SingleChildScrollView(
                        child: Row(
                          children: [
                            Expanded(
                              child: MarkdownBody(
                                data: data.content,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (significantUpdate) ...[
                const SizedBox(height: 8),
                Divider(
                  thickness: 2,
                  endIndent: 32,
                  indent: 32,
                  height: 8,
                  color: colorScheme.primary,
                ),
                if (!hasPrem) const _SupportBanner() else const _ThanksBanner(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThanksBanner extends StatelessWidget {
  const _ThanksBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 4,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                goToPremiumPage(context);
              },
              icon: const Icon(
                color: Colors.red,
                Symbols.favorite,
                fill: 1,
              ),
            ),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Thank you for supporting the development of this app by subscribing to $kPremiumBrandNameFull!',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportBanner extends StatelessWidget {
  const _SupportBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 4,
        ),
        child: InkWell(
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          onTap: () {
            goToPremiumPage(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    goToPremiumPage(context);
                  },
                  icon: const Icon(
                    color: Colors.red,
                    Symbols.favorite,
                    fill: 1,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "If you're enjoying these updates, consider supporting my work to keep the improvements coming.",
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
