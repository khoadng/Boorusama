// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../downloads/downloader/providers.dart';
import '../../../../downloads/urls/providers.dart';
import '../../../../downloads/urls/types.dart';
import '../../../../widgets/booru_anchor.dart';
import '../../../../widgets/booru_tooltip.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/types.dart';

class DownloadPostButton extends ConsumerStatefulWidget {
  const DownloadPostButton({
    required this.post,
    super.key,
    this.small = false,
  });

  final Post post;
  final bool small;

  @override
  ConsumerState<DownloadPostButton> createState() => _DownloadPostButtonState();
}

class _DownloadPostButtonState extends ConsumerState<DownloadPostButton> {
  final _controller = AnchorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(
      downloadNotifierProvider(
        ref.watch(
          downloadNotifierParamsProvider((
            ref.watchConfigAuth,
            ref.watchConfigDownload,
          )),
        ),
      ).notifier,
    );
    final downloadSources = ref.watch(
      downloadSourceProvider(
        ref.watchConfigAuth,
      ),
    );

    final iconColor = IconTheme.of(context).color ?? Colors.white;
    final sources = downloadSources?.getDownloadSources(context, widget.post);

    return _PopupMenuButton(
      enable: sources?.isNotEmpty ?? false,
      controller: _controller,
      items: [
        ...?sources?.map(
          (e) => BooruPopupMenuItem(
            title: Text(e.name),
            onTap: () {
              notifier.download(
                widget.post,
                overrideUrl: e.url,
              );
            },
          ),
        ),
      ],
      child: BooruTooltip(
        message: context.t.download.download,
        child: !widget.small
            ? IconButton(
                splashRadius: 16,
                onPressed: () {
                  notifier.download(widget.post);
                },
                onLongPress: () {
                  _controller.show();
                },
                icon: _buildIcon(
                  sources,
                  iconColor,
                ),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    notifier.download(widget.post);
                  },
                  onLongPress: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _buildIcon(
                      sources,
                      iconColor,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildIcon(List<DownloadSource>? sources, Color iconColor) =>
      switch (sources) {
        final s? when s.isNotEmpty => CustomPaint(
          size: const Size(24, 24),
          painter: DownloadWithDropdownIconPainter(
            color: iconColor,
          ),
        ),
        _ => const Icon(
          Symbols.download,
        ),
      };
}

class DownloadWithDropdownIconPainter extends CustomPainter {
  const DownloadWithDropdownIconPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    const trayHalfWidth = 8.0;
    const gap = 5.0;
    const chevronWidth = 10.0;
    const totalWidth = trayHalfWidth * 2 + gap + chevronWidth;
    final iconCenterX = centerX - (totalWidth / 2) + trayHalfWidth;

    // Arrow shaft
    final arrowTop = centerY - 8;
    final arrowBottom = centerY + 3;

    canvas.drawLine(
      Offset(iconCenterX, arrowTop),
      Offset(iconCenterX, arrowBottom),
      paint,
    );

    // Arrow head
    const arrowHeadSize = 5.0;
    canvas.drawLine(
      Offset(iconCenterX - arrowHeadSize, arrowBottom - arrowHeadSize),
      Offset(iconCenterX, arrowBottom),
      paint,
    );
    canvas.drawLine(
      Offset(iconCenterX + arrowHeadSize, arrowBottom - arrowHeadSize),
      Offset(iconCenterX, arrowBottom),
      paint,
    );

    // Tray/base (U shape)
    final trayTop = centerY + 5;
    final trayBottom = centerY + 9;

    final trayPath = Path()
      ..moveTo(iconCenterX - trayHalfWidth, trayTop)
      ..lineTo(iconCenterX - trayHalfWidth, trayBottom)
      ..lineTo(iconCenterX + trayHalfWidth, trayBottom)
      ..lineTo(iconCenterX + trayHalfWidth, trayTop);

    canvas.drawPath(trayPath, paint);

    // Dropdown chevron
    final dropdownPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final chevronX = iconCenterX + trayHalfWidth + gap + (chevronWidth / 2);
    const chevronHalfW = 4;
    const chevronH = 2.0;

    canvas.drawLine(
      Offset(chevronX - chevronHalfW, centerY - chevronH),
      Offset(chevronX, centerY + chevronH),
      dropdownPaint,
    );
    canvas.drawLine(
      Offset(chevronX + chevronHalfW, centerY - chevronH),
      Offset(chevronX, centerY + chevronH),
      dropdownPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DownloadWithDropdownIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PopupMenuButton extends ConsumerWidget {
  const _PopupMenuButton({
    required this.items,
    required this.controller,
    required this.enable,
    required this.child,
  });

  final List<Widget> items;
  final Widget child;
  final AnchorController controller;
  final bool enable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enable) {
      return child;
    }

    return BooruAnchor(
      controller: controller,
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                context.t.settings.download.quality,
              ),
            ),
            const SizedBox(
              width: 200,
              child: Divider(),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: min(MediaQuery.widthOf(context), 200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
