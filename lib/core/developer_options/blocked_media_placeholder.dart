// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'l10n.dart';

class BlockedMediaPlaceholder extends StatelessWidget {
  const BlockedMediaPlaceholder({
    super.key,
    this.aspectRatio,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.isVideo = false,
    this.width,
    this.height,
  });

  final double? aspectRatio;
  final BorderRadiusGeometry borderRadius;
  final bool isVideo;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textDirection = Directionality.of(context);
    final l10n = context.t.developerOptions;
    final content = SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CustomPaint(
          painter: _BlockedMediaPainter(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurfaceVariant,
            accentColor: colorScheme.tertiary,
            mediaOffLabel: l10n.mediaLoadingOff,
            developerModeLabel: l10n.developerMode,
            textDirection: textDirection,
            isVideo: isVideo,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );

    return switch (aspectRatio) {
      final ratio? => AspectRatio(aspectRatio: ratio, child: content),
      null => content,
    };
  }
}

class _BlockedMediaPainter extends CustomPainter {
  const _BlockedMediaPainter({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.accentColor,
    required this.mediaOffLabel,
    required this.developerModeLabel,
    required this.textDirection,
    required this.isVideo,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color accentColor;
  final String mediaOffLabel;
  final String developerModeLabel;
  final TextDirection textDirection;
  final bool isVideo;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    _drawStripes(canvas, size);

    final shortestSide = math.min(size.width, size.height);
    if (shortestSide < 18) return;

    final showPrimaryLabel = size.width >= 130 && size.height >= 82;
    final showSecondaryLabel = size.width >= 180 && size.height >= 122;
    final iconSize = (shortestSide * 0.3).clamp(24.0, 52.0);
    final iconCenter = Offset(
      size.width / 2,
      size.height / 2 - (showPrimaryLabel ? 13 : 0),
    );

    _drawMediaIcon(canvas, iconCenter, iconSize);
    if (showPrimaryLabel) {
      _drawCenteredText(
        canvas,
        mediaOffLabel.toUpperCase(),
        top: iconCenter.dy + iconSize * 0.65,
        width: size.width,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      );
    }

    if (showSecondaryLabel) {
      _drawCenteredText(
        canvas,
        developerModeLabel,
        top: iconCenter.dy + iconSize * 0.65 + 18,
        width: size.width,
        style: TextStyle(
          color: foregroundColor.withValues(alpha: 0.7),
          fontSize: 10,
        ),
      );
    }
  }

  void _drawStripes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foregroundColor.withValues(alpha: 0.06)
      ..strokeWidth = 5;

    for (var x = -size.height; x < size.width; x += 18) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  void _drawMediaIcon(Canvas canvas, Offset center, double size) {
    final strokeWidth = (size * 0.07).clamp(1.5, 3.0);
    final outlinePaint = Paint()
      ..color = foregroundColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final iconRect = Rect.fromCenter(
      center: center,
      width: size,
      height: size * 0.72,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(iconRect, Radius.circular(size * 0.1)),
      outlinePaint,
    );

    if (isVideo) {
      final playPath = Path()
        ..moveTo(center.dx - size * 0.09, center.dy - size * 0.14)
        ..lineTo(center.dx + size * 0.17, center.dy)
        ..lineTo(center.dx - size * 0.09, center.dy + size * 0.14)
        ..close();
      canvas.drawPath(
        playPath,
        Paint()..color = foregroundColor.withValues(alpha: 0.8),
      );
    } else {
      final imagePath = Path()
        ..moveTo(iconRect.left + size * 0.12, iconRect.bottom - size * 0.12)
        ..lineTo(center.dx - size * 0.08, center.dy + size * 0.02)
        ..lineTo(center.dx + size * 0.06, center.dy + size * 0.14)
        ..lineTo(center.dx + size * 0.18, center.dy + size * 0.03)
        ..lineTo(iconRect.right - size * 0.1, iconRect.bottom - size * 0.12);
      canvas.drawPath(imagePath, outlinePaint);
      canvas.drawCircle(
        Offset(iconRect.left + size * 0.22, iconRect.top + size * 0.18),
        size * 0.055,
        Paint()..color = foregroundColor.withValues(alpha: 0.8),
      );
    }

    final slashPaint = Paint()
      ..color = accentColor
      ..strokeWidth = strokeWidth * 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(iconRect.left - size * 0.06, iconRect.bottom + size * 0.06),
      Offset(iconRect.right + size * 0.06, iconRect.top - size * 0.06),
      slashPaint,
    );
  }

  void _drawCenteredText(
    Canvas canvas,
    String text, {
    required double top,
    required double width,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: textDirection,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(0, width - 24));

    painter.paint(canvas, Offset((width - painter.width) / 2, top));
  }

  @override
  bool shouldRepaint(_BlockedMediaPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor ||
      accentColor != oldDelegate.accentColor ||
      mediaOffLabel != oldDelegate.mediaOffLabel ||
      developerModeLabel != oldDelegate.developerModeLabel ||
      textDirection != oldDelegate.textDirection ||
      isVideo != oldDelegate.isVideo;
}
