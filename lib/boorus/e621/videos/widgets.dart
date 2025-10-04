// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/create/routes.dart';
import '../../../core/posts/details/providers.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/widgets/widgets.dart';
import '../../../foundation/html.dart';
import '../posts/types.dart';

class E621VideoQualitySelector extends ConsumerWidget {
  const E621VideoQualitySelector({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigViewer;
    final params = VideoUrlParam(
      post: post,
      viewer: config,
      auth: ref.watchConfigAuth,
    );
    final currentVideoUrl = ref.watch(
      postDetailsVideoUrlProvider(params),
    );
    final videoUrlNotifier = ref.watch(
      postDetailsVideoUrlProvider(params).notifier,
    );

    return switch (post) {
      final E621Post p => Builder(
        builder: (context) {
          final effectiveQuality = _getVariantFromVideoUrl(currentVideoUrl, p);

          return MobileConfigTile(
            value:
                effectiveQuality?.getLabel(context) ??
                context.t.video_player.video_qualities.auto,
            title: context.t.video_player.video_quality,
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                builder: (_) => E621VideoQualitySheet(
                  qualities: p.videoVariants.values.toList(),
                  currentQuality: effectiveQuality,
                  onChanged: (quality) {
                    if (p.videoVariants[quality]?.url case final url?) {
                      videoUrlNotifier.setUrl(url);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      _ => const SizedBox.shrink(),
    };
  }

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
