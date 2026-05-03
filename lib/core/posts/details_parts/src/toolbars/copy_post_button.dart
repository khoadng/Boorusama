// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../../foundation/animations/constants.dart';
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/display.dart';
import '../../../../../foundation/toast.dart';
import '../../../../configs/config/types.dart';
import '../../../../images/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../details/providers.dart';
import '../../../post/providers.dart';
import '../../../post/types.dart';
import '../../../sources/types.dart';

class CopyPostButton extends ConsumerWidget {
  const CopyPostButton({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;
  final BooruConfigViewer configViewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.content_copy),
      tooltip: context.t.post.action.copy,
      onPressed: () => showPostCopySheet(
        context,
        post: post,
        config: config,
        configViewer: configViewer,
      ),
    );
  }
}

Future<void> showPostCopySheet(
  BuildContext context, {
  required Post post,
  required BooruConfigAuth config,
  required BooruConfigViewer configViewer,
}) {
  return showAdaptiveBottomSheet<void>(
    context,
    settings: const RouteSettings(name: 'post_copy'),
    builder: (context) => PostCopySheet(
      post: post,
      config: config,
      configViewer: configViewer,
    ),
    backgroundColor: Colors.transparent,
  );
}

enum _CopySegment {
  media,
  links,
}

class PostCopySheet extends ConsumerStatefulWidget {
  const PostCopySheet({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;
  final BooruConfigViewer configViewer;

  @override
  ConsumerState<PostCopySheet> createState() => _PostCopySheetState();
}

class _PostCopySheetState extends ConsumerState<PostCopySheet> {
  _CopySegment _segment = _CopySegment.media;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomPadding, left: 4, right: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.t.post.action.copy,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              BooruSegmentedButton<_CopySegment>(
                initialValue: _segment,
                segments: {
                  _CopySegment.media: context.t.post.action.media,
                  _CopySegment.links: context.t.post.action.links,
                },
                onChanged: (value) => setState(() => _segment = value),
              ),
              const SizedBox(height: 12),
              switch (_segment) {
                _CopySegment.media => _MediaCopyOptions(
                  key: const ValueKey('media'),
                  post: widget.post,
                  config: widget.config,
                  configViewer: widget.configViewer,
                ),
                _CopySegment.links => _LinkCopyOptions(
                  key: const ValueKey('links'),
                  post: widget.post,
                  config: widget.config,
                  configViewer: widget.configViewer,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaCopyOptions extends ConsumerWidget {
  const _MediaCopyOptions({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;
  final BooruConfigViewer configViewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaUrlResolver = ref.watch(mediaUrlResolverProvider(config));
    final mediaUrl = mediaUrlResolver.resolveMediaUrl(post, configViewer);
    final originalUrl = _originalUrlFor(post);

    return _CopyOptionList(
      children: [
        _CopyOptionTile(
          icon: Icons.image,
          title: context.t.post.action.copy_image,
          subtitle: context.t.post.action.copy_image_description,
          onTap: () => _copyImage(context, ref, mediaUrl),
        ),
        _CopyOptionTile(
          icon: Icons.description,
          title: context.t.post.action.copy_file_name,
          subtitle:
              _fileNameFromUrl(originalUrl ?? mediaUrl) ??
              context.t.post.action.unavailable,
          enabled: _fileNameFromUrl(originalUrl ?? mediaUrl) != null,
          onTap: () => _copyText(
            context,
            _fileNameFromUrl(originalUrl ?? mediaUrl),
          ),
        ),
      ],
    );
  }
}

class _LinkCopyOptions extends ConsumerWidget {
  const _LinkCopyOptions({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;
  final BooruConfigViewer configViewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(config));
    final booruLink = postLinkGenerator.getLink(post);
    final mediaUrl = ref
        .watch(mediaUrlResolverProvider(config))
        .resolveMediaUrl(post, configViewer);
    final sourceUrl = switch (post.source) {
      final WebSource source => source.uri.toString(),
      _ => null,
    };
    final originalUrl = _originalUrlFor(post);

    return _CopyOptionList(
      children: [
        _CopyOptionTile(
          icon: Icons.travel_explore,
          title: context.t.post.action.copy_post_link,
          subtitle: booruLink.isNotEmpty
              ? booruLink
              : context.t.post.action.unavailable,
          enabled: booruLink.isNotEmpty,
          onTap: () => _copyText(context, booruLink),
        ),
        _CopyOptionTile(
          icon: Icons.public,
          title: context.t.post.action.copy_source_link,
          subtitle: sourceUrl ?? context.t.post.action.unavailable,
          enabled: sourceUrl != null,
          onTap: () => _copyText(context, sourceUrl),
        ),
        if (originalUrl case final String url?)
          _CopyOptionTile(
            icon: Icons.link,
            title: context.t.post.action.copy_image_link,
            subtitle: url,
            enabled: url.isNotEmpty,
            onTap: () => _copyText(context, url),
          )
        else
          _CopyOptionTile(
            icon: Icons.image,
            title: context.t.post.action.copy_image_link,
            subtitle: mediaUrl,
            enabled: mediaUrl.isNotEmpty,
            onTap: () => _copyText(context, mediaUrl),
          ),
        _CopyOptionTile(
          icon: Icons.numbers,
          title: context.t.post.action.copy_post_id,
          subtitle: post.id.toString(),
          onTap: () => _copyText(context, post.id.toString()),
        ),
      ],
    );
  }
}

class _CopyOptionList extends StatelessWidget {
  const _CopyOptionList({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, child) in children.indexed) ...[
          child,
          if (index < children.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _CopyOptionTile extends StatelessWidget {
  const _CopyOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foregroundColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final subtitleColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface.withValues(alpha: 0.32);

    return Material(
      color: enabled
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: foregroundColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.content_copy,
                size: 20,
                color: subtitleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _copyImage(
  BuildContext context,
  WidgetRef ref,
  String mediaUrl,
) async {
  if (mediaUrl.isEmpty) {
    _showError(context, context.t.post.action.failed_to_get_image_url);
    return;
  }

  final bytes = await ref.read(
    defaultCachedImageFileProvider(mediaUrl).future,
  );

  if (bytes == null) {
    if (!context.mounted) return;
    _showError(context, context.t.post.action.failed_to_get_image_bytes);
    return;
  }

  try {
    await AppClipboard.copyImageBytes(bytes);
    if (context.mounted) {
      _showCopiedToast();
    }
  } on Exception catch (e) {
    if (context.mounted) {
      _showError(context, context.t.post.action.failed_to_copy_image(e: e));
    }
  }
}

Future<void> _copyText(BuildContext context, String? value) async {
  if (value == null || value.isEmpty) return;

  await AppClipboard.copy(value);

  if (context.mounted) {
    _showCopiedToast();
  }
}

void _showCopiedToast() {
  showToast(
    'Copied',
    position: ToastPosition.bottom,
    textPadding: const EdgeInsets.all(8),
    duration: AppDurations.shortToast,
  );
}

void _showError(BuildContext context, String message) {
  showErrorToast(
    context,
    message,
    duration: AppDurations.longToast,
  );
}

String? _originalUrlFor(Post post) {
  final url = post.isVideo ? post.videoUrl : post.originalImageUrl;

  return url.isNotEmpty ? url : null;
}

String? _fileNameFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);
  final pathSegments = uri?.pathSegments;
  final fileName = pathSegments == null || pathSegments.isEmpty
      ? null
      : pathSegments.last;

  return fileName != null && fileName.isNotEmpty ? fileName : null;
}
