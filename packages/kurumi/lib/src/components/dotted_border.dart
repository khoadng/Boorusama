import 'package:material_ui/material_ui.dart';

class KurumiDottedBorder extends StatelessWidget {
  KurumiDottedBorder({
    required this.child,
    super.key,
    this.color = Colors.black,
    this.gradient,
    this.strokeWidth = 1,
    this.borderType = KurumiBorderType.rect,
    this.dashPattern = const [3, 1],
    this.padding = const EdgeInsets.all(2),
    this.borderPadding = EdgeInsets.zero,
    this.radius = Radius.zero,
    this.strokeCap = StrokeCap.butt,
    this.customPath,
    this.stackFit = StackFit.loose,
  }) {
    assert(_isValidDashPattern(dashPattern), 'Invalid dash pattern');
  }

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets borderPadding;
  final double strokeWidth;
  final Color color;
  final Gradient? gradient;
  final List<double> dashPattern;
  final KurumiBorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final KurumiPathBuilder? customPath;
  final StackFit stackFit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: stackFit,
      children: <Widget>[
        Padding(
          padding: padding,
          child: child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: KurumiDashedPainter(
                padding: borderPadding,
                strokeWidth: strokeWidth,
                radius: radius,
                color: color,
                gradient: gradient,
                borderType: borderType,
                dashPattern: dashPattern,
                customPath: customPath,
                strokeCap: strokeCap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum KurumiBorderType { circle, rrect, rect, oval }

typedef KurumiPathBuilder = Path Function(Size);

class KurumiDashedPainter extends CustomPainter {
  KurumiDashedPainter({
    this.strokeWidth = 2,
    this.dashPattern = const <double>[3, 1],
    this.color = Colors.black,
    this.gradient,
    this.borderType = KurumiBorderType.rect,
    this.radius = Radius.zero,
    this.strokeCap = StrokeCap.butt,
    this.customPath,
    this.padding = EdgeInsets.zero,
  }) : assert(_isValidDashPattern(dashPattern), 'Invalid dash pattern');

  final double strokeWidth;
  final List<double> dashPattern;
  final Color color;
  final Gradient? gradient;
  final KurumiBorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final KurumiPathBuilder? customPath;
  final EdgeInsets padding;

  @override
  void paint(Canvas canvas, Size size) {
    Size sz;
    if (padding == EdgeInsets.zero) {
      sz = size;
    } else {
      canvas.translate(padding.left, padding.top);
      sz = Size(
        size.width - padding.horizontal,
        size.height - padding.vertical,
      );
    }

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    if (gradient != null) {
      final rect = Offset.zero & sz;
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = color;
    }

    final path = customPath != null
        ? _dashPath(customPath!(sz), dashPattern)
        : _getPath(sz);

    canvas.drawPath(path, paint);
  }

  Path _getPath(Size size) => _dashPath(
    switch (borderType) {
      KurumiBorderType.circle => _getCirclePath(size),
      KurumiBorderType.rrect => _getRRectPath(size, radius),
      KurumiBorderType.rect => _getRectPath(size),
      KurumiBorderType.oval => _getOvalPath(size),
    },
    dashPattern,
  );

  Path _getCirclePath(Size size) {
    final w = size.width;
    final h = size.height;
    final s = size.shortestSide;

    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w > s ? (w - s) / 2 : 0,
          h > s ? (h - s) / 2 : 0,
          s,
          s,
        ),
        Radius.circular(s / 2),
      ),
    );
  }

  Path _getRRectPath(Size size, Radius radius) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
        radius,
      ),
    );
  }

  Path _getRectPath(Size size) {
    return Path()..addRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );
  }

  Path _getOvalPath(Size size) {
    return Path()..addOval(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );
  }

  @override
  bool shouldRepaint(KurumiDashedPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.padding != padding ||
        oldDelegate.borderType != borderType;
  }
}

bool _isValidDashPattern(List<double> pattern) =>
    pattern.isNotEmpty &&
    pattern.every((interval) => interval >= 0) &&
    pattern.any((interval) => interval > 0);

Path _dashPath(Path source, List<double> pattern) {
  final destination = Path();

  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    var intervalIndex = 0;
    var draw = true;

    while (distance < metric.length) {
      final interval = pattern[intervalIndex];
      if (draw && interval > 0) {
        destination.addPath(
          metric.extractPath(distance, distance + interval),
          Offset.zero,
        );
      }

      distance += interval;
      intervalIndex = (intervalIndex + 1) % pattern.length;
      draw = !draw;
    }
  }

  return destination;
}

class KurumiDottedBorderButton extends StatelessWidget {
  const KurumiDottedBorderButton({
    required this.title,
    super.key,
    this.onTap,
    this.borderColor,
  });

  final VoidCallback? onTap;
  final String title;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: title,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: KurumiDottedBorder(
            color: borderColor ?? Theme.of(context).colorScheme.outline,
            radius: const Radius.circular(12),
            dashPattern: const [8, 4],
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
