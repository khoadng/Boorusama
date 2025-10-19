// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/create/routes.dart';
import '../../../core/posts/details/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/videos/player/widgets.dart';
import '../../../foundation/html.dart';
import '../../../foundation/platform.dart';
import '../posts/types.dart';

E621VideoVariantType? _getVariantFromVideoUrl(String? url, E621Post post) =>
    switch (url) {
      final String url when url.isNotEmpty => () {
        for (final entry in post.videoVariants.entries) {
          if (entry.value.url == url) {
            return entry.key;
          }
        }
        return null;
      }(),
      _ => null,
    };

class E621VideoQualitySelector extends ConsumerWidget {
  const E621VideoQualitySelector({
    super.key,
    required this.post,
    this.onPushPage,
    this.onPopPage,
  });

  final Post post;
  final void Function(Widget page)? onPushPage;
  final void Function()? onPopPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (post) {
      final E621Post p => () {
        final config = ref.watchConfigViewer;
        final params = VideoUrlParam(
          post: p,
          viewer: config,
          auth: ref.watchConfigAuth,
        );
        final currentVideoUrl = ref.watch(
          postDetailsVideoUrlProvider(params),
        );
        final videoUrlNotifier = ref.watch(
          postDetailsVideoUrlProvider(params).notifier,
        );
        final effectiveQuality = _getVariantFromVideoUrl(currentVideoUrl, p);
        final qualityLabel =
            effectiveQuality?.getLabel(context) ??
            context.t.video_player.video_qualities.auto;

        void onQualityChanged(E621VideoVariantType quality) {
          if (p.videoVariants[quality]?.url case final url?) {
            videoUrlNotifier.setUrl(url);
          }
        }

        return isDesktopPlatform() && onPushPage != null
            ? _DesktopE621VideoQualitySelector(
                post: p,
                qualityLabel: qualityLabel,
                effectiveQuality: effectiveQuality,
                onQualityChanged: onQualityChanged,
                onPushPage: onPushPage!,
                onPopPage: onPopPage!,
              )
            : _MobileE621VideoQualitySelector(
                post: p,
                qualityLabel: qualityLabel,
                effectiveQuality: effectiveQuality,
                onQualityChanged: onQualityChanged,
              );
      }(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _DesktopE621VideoQualitySelector extends StatelessWidget {
  const _DesktopE621VideoQualitySelector({
    required this.post,
    required this.qualityLabel,
    required this.effectiveQuality,
    required this.onQualityChanged,
    required this.onPushPage,
    required this.onPopPage,
  });

  final E621Post post;
  final String qualityLabel;
  final E621VideoVariantType? effectiveQuality;
  final void Function(E621VideoVariantType quality) onQualityChanged;
  final void Function(Widget page) onPushPage;
  final void Function() onPopPage;

  @override
  Widget build(BuildContext context) {
    return DesktopVideoOptionTile(
      icon: Symbols.video_settings,
      title: context.t.video_player.video_quality,
      value: qualityLabel,
      onTap: () => onPushPage(
        _DesktopE621VideoQualitySheet(
          qualities: post.videoVariants.values.toList(),
          currentQuality: effectiveQuality,
          onBack: onPopPage,
          onChanged: (quality) {
            onQualityChanged(quality);
            onPopPage();
          },
        ),
      ),
    );
  }
}

class _MobileE621VideoQualitySelector extends StatelessWidget {
  const _MobileE621VideoQualitySelector({
    required this.post,
    required this.qualityLabel,
    required this.effectiveQuality,
    required this.onQualityChanged,
  });

  final E621Post post;
  final String qualityLabel;
  final E621VideoVariantType? effectiveQuality;
  final void Function(E621VideoVariantType quality) onQualityChanged;

  @override
  Widget build(BuildContext context) {
    return MobileConfigTile(
      value: qualityLabel,
      title: context.t.video_player.video_quality,
      onTap: () {
        Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          builder: (_) => E621VideoQualitySheet(
            qualities: post.videoVariants.values.toList(),
            currentQuality: effectiveQuality,
            onChanged: onQualityChanged,
          ),
        );
      },
    );
  }
}

class _DesktopE621VideoQualitySheet extends StatelessWidget {
  const _DesktopE621VideoQualitySheet({
    required this.qualities,
    required this.currentQuality,
    required this.onBack,
    required this.onChanged,
  });

  final List<E621VideoVariant> qualities;
  final E621VideoVariantType? currentQuality;
  final void Function() onBack;
  final void Function(E621VideoVariantType quality) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopVideoOptionTile(
          icon: Symbols.arrow_back,
          title: context.t.video_player.video_quality,
          onTap: onBack,
        ),
        const Divider(height: 1),
        ...qualities.map(
          (variant) => _DesktopE621QualityOptionTile(
            variant: variant,
            isSelected: variant.type == currentQuality,
            onTap: () => onChanged(variant.type),
          ),
        ),
      ],
    );
  }
}

class _DesktopE621QualityOptionTile extends StatefulWidget {
  const _DesktopE621QualityOptionTile({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  final E621VideoVariant variant;
  final bool isSelected;
  final void Function() onTap;

  @override
  State<_DesktopE621QualityOptionTile> createState() =>
      _DesktopE621QualityOptionTileState();
}

class _DesktopE621QualityOptionTileState
    extends State<_DesktopE621QualityOptionTile> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered
            ? colorScheme.onSurface.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: widget.isSelected
                      ? Icon(
                          Symbols.check,
                          size: 20,
                          color: colorScheme.onSurface,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.variant.type.getLabel(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _buildSubtitle(widget.variant),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(E621VideoVariant quality) => [
    ?quality.format?.toUpperCase(),
    '${quality.width}x${quality.height}',
    ?Filesize.tryParse(quality.size),
    '${quality.fps.toStringAsFixed(0)} FPS',
  ].join(' • ');
}

class E621VideoQualitySheet extends StatelessWidget {
  const E621VideoQualitySheet({
    required this.currentQuality,
    required this.onChanged,
    required this.qualities,
    super.key,
  });

  final E621VideoVariantType? currentQuality;
  final void Function(E621VideoVariantType quality) onChanged;
  final List<E621VideoVariant> qualities;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...qualities.map(
                (e) => ListTile(
                  minTileHeight: 66,
                  title: Text(e.type.getLabel(context)),
                  subtitle: Text(_buildSubtitle(e)),
                  trailing: currentQuality == e.type
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    onChanged(e.type);
                  },
                ),
              ),
              const Divider(
                indent: 12,
                endIndent: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Consumer(
                  builder: (_, ref, _) {
                    final config = ref.watchConfig;
                    return AppHtml(
                      style: {
                        'a': Style(
                          color: Theme.of(context).colorScheme.primary,
                          textDecoration: TextDecoration.none,
                        ),
                      },
                      data: context.t.video_player.current_video_quality_disclaimer(
                        video_profile_path:
                            '${context.t.settings.booru_settings.booru_settings} > ${context.t.settings.image_viewer.image_viewer} > ${context.t.video_player.video_quality}',
                      ),
                      onLinkTap: (url, attributes, element) {
                        if (url == 'booru-profiles') {
                          Navigator.of(context).pop();
                          goToUpdateBooruConfigPage(
                            ref,
                            config: config,
                            initialTab: 'viewer',
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(E621VideoVariant quality) => [
    ?quality.format?.toUpperCase(),
    '${quality.width}x${quality.height}',
    ?Filesize.tryParse(quality.size),
    '${quality.fps.toStringAsFixed(0)} FPS',
  ].join(' • ');
}
