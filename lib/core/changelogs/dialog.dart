// Dart imports:
import 'dart:math' as math;

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
import '../premiums/providers.dart';
import '../premiums/routes.dart';
import '../premiums/types.dart';
import '../themes/theme/types.dart';
import 'providers.dart';
import 'types.dart';

class ChangelogDialog extends ConsumerWidget {
  const ChangelogDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(changelogDataProvider)
        .when(
          data: (data) => _buildContent(ref, data),
          error: (_, _) => _ChanglogBox(
            child: Text(
              context.t.generic.errors.unknown,
            ),
          ),
          loading: () => const _ChanglogBox(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            ),
          ),
        );
  }

  Widget _buildContent(WidgetRef ref, ChangelogData data) {
    final size = MediaQuery.sizeOf(ref.context);
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: math.min(screenWidth * 0.9, 450),
          maxHeight: math.min(screenHeight * 0.8, 550),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(version: data.version),
                    const Divider(
                      thickness: 1,
                      height: 0,
                    ),
                    _Content(data: data),
                  ],
                ),
              ),
            ),
            if (data.isSignificantUpdate()) ...[
              Builder(
                builder: (context) {
                  final hasPrem =
                      ref.watch(showPremiumFeatsProvider) &&
                      ref.watch(hasPremiumProvider);
                  return !hasPrem
                      ? const _SupportBanner()
                      : const _ThanksBanner();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChanglogBox extends StatelessWidget {
  const _ChanglogBox({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        padding: const EdgeInsets.all(32),
        child: child,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.data,
  });

  final ChangelogData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
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
                top: 4,
                left: 8,
                bottom: 8,
              ),
              child: Text(
                '${context.t.comment.list.last_updated}: ${u.lastUpdated?.fuzzify(locale: Localizations.localeOf(context))}',
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
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.version,
  });

  final ReleaseVersion version;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
                    context.t.app_update.whats_new,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    );
  }
}

class _ThanksBanner extends ConsumerWidget {
  const _ThanksBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                goToPremiumPage(ref);
              },
              icon: const Icon(
                color: Colors.red,
                Symbols.favorite,
                fill: 1,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: context.t.premium.changelog.thanks_for_supporting(
                        brand: kPremiumBrandNameFull,
                      ),
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

class _SupportBanner extends ConsumerWidget {
  const _SupportBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            goToPremiumPage(ref);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    goToPremiumPage(ref);
                  },
                  icon: const Icon(
                    color: Colors.red,
                    Symbols.favorite,
                    fill: 1,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: context.t.premium.changelog.support_reminder,
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
