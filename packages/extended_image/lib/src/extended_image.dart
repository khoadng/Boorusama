import 'dart:async';

import 'package:dio/dio.dart';
import 'package:extended_image/src/image/raw_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';

import 'dio_extended_image_provider.dart';
import 'utils.dart';

const kDefaultImageCacheDuration = Duration(days: 2);

class ExtendedImageController extends ChangeNotifier {
  ExtendedImageController(
    this.initialLoadState, {
    this.initialInvertColors = false,
  });

  final LoadState initialLoadState;
  final bool initialInvertColors;
  late final loadState = ValueNotifier(initialLoadState);
  late final invertColors = ValueNotifier(initialInvertColors);
  late final imageInfo = ValueNotifier<ImageInfo?>(null);

  void changeLoadState(LoadState state) {
    loadState.value = state;
  }

  void changeInvertColors(bool invert) {
    invertColors.value = invert;
  }

  void clearImage() {
    final oldImageInfo = imageInfo.value;

    SchedulerBinding.instance
        .addPostFrameCallback((_) => oldImageInfo?.dispose());

    imageInfo.value = null;
  }

  void replaceImage({required ImageInfo info}) {
    final oldImageInfo = imageInfo.value;

    if (oldImageInfo?.scale == info.scale &&
        oldImageInfo?.isCloneOf(info) == true &&
        oldImageInfo?.debugLabel == info.debugLabel) {
      // Same image, no need to replace
      return;
    }

    if (oldImageInfo != null) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => oldImageInfo.dispose());
    }

    imageInfo.value = info;
  }

  @override
  void dispose() {
    clearImage();
    loadState.dispose();
    invertColors.dispose();

    super.dispose();
  }
}

/// extended image base on official
/// [Image]
class ExtendedImage extends StatefulWidget {
  ExtendedImage({
    super.key,
    required this.image,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    BoxConstraints? constraints,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.shape,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.clearMemoryCacheIfFailed = true,
    this.clearMemoryCacheWhenDispose = false,
    this.extendedImageGestureKey,
    this.isAntiAlias = false,
    this.layoutInsets = EdgeInsets.zero,
    this.controller,
    this.placeholderWidget,
    this.errorWidget,
  })  : assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints;

  ExtendedImage.network(
    String url, {
    super.key,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.shape,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.clearMemoryCacheIfFailed = true,
    BoxConstraints? constraints,
    CancellationToken? cancelToken,
    int retries = 3,
    Duration? timeLimit,
    Map<String, String>? headers,
    bool cache = true,
    double scale = 1.0,
    Duration timeRetry = const Duration(milliseconds: 100),
    this.clearMemoryCacheWhenDispose = false,
    this.extendedImageGestureKey,
    int? cacheWidth,
    int? cacheHeight,
    this.isAntiAlias = false,
    String? cacheKey,
    bool printError = true,
    double? compressionRatio,
    int? maxBytes,
    bool cacheRawData = false,
    String? imageCacheName,
    Duration? cacheMaxAge,
    this.layoutInsets = EdgeInsets.zero,
    required Dio dio,
    this.controller,
    this.placeholderWidget,
    this.errorWidget,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        image = ExtendedResizeImage.resizeIfNeeded(
          provider: DioExtendedNetworkImageProvider(
            url,
            dio: dio,
            scale: scale,
            headers: headers,
            cache: cache,
            cancelToken: cancelToken,
            retries: retries,
            timeRetry: timeRetry,
            timeLimit: timeLimit,
            cacheKey: cacheKey,
            printError: printError,
            cacheRawData: cacheRawData,
            imageCacheName: imageCacheName,
            cacheMaxAge: cacheMaxAge ?? kDefaultImageCacheDuration,
          ),
          compressionRatio: compressionRatio,
          maxBytes: maxBytes,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          cacheRawData: cacheRawData,
          imageCacheName: imageCacheName,
        ),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        assert(constraints == null || constraints.debugAssertIsValid()),
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0);

  /// key of ExtendedImageGesture
  final Key? extendedImageGestureKey;

  /// when image is removed from the tree permanently, whether clear memory cache
  final bool clearMemoryCacheWhenDispose;

  ///when failed to load image, whether clear memory cache
  ///if true, image will reload in next time.
  final bool clearMemoryCacheIfFailed;

  /// {@macro flutter.clipper.clipBehavior}
  final Clip clipBehavior;

  /// The shape to fill the background [color], [gradient], and [image] into and
  /// to cast as the [boxShadow].
  ///
  /// If this is [BoxShape.circle] then [borderRadius] is ignored.
  ///
  /// The [shape] cannot be interpolated; animating between two [BoxDecoration]s
  /// with different [shape]s will result in a discontinuity in the rendering.
  /// To interpolate between two shapes, consider using [ShapeDecoration] and
  /// different [ShapeBorder]s; in particular, [CircleBorder] instead of
  /// [BoxShape.circle] and [RoundedRectangleBorder] instead of
  /// [BoxShape.rectangle].
  final BoxShape? shape;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to boxes with rectangular shapes; ignored if [shape] is not
  /// [BoxShape.rectangle].
  final BorderRadius? borderRadius;

  /// The image to display.
  final ImageProvider image;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? height;

  final BoxConstraints? constraints;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color? color;

  /// If non-null, the value from the [Animation] is multiplied with the opacity
  /// of each image pixel before painting onto the canvas.
  ///
  /// This is more efficient than using [FadeTransition] to change the opacity
  /// of an image, since this avoids creating a new composited layer. Composited
  /// layers may double memory usage as the image is painted onto an offscreen
  /// render target.
  ///
  /// See also:
  ///
  ///  * [AlwaysStoppedAnimation], which allows you to create an [Animation]
  ///    from a single opacity value.
  final Animation<double>? opacity;

  /// Used to set the [FilterQuality] of the image.
  ///
  /// Use the [FilterQuality.low] quality setting to scale the image with
  /// bilinear interpolation, or the [FilterQuality.none] which corresponds
  /// to nearest-neighbor.
  final FilterQuality filterQuality;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode? colorBlendMode;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect? centerSlice;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the 'normal' painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes. The default value is false.
  ///
  /// ## Design discussion
  ///
  /// ### Why is the default value of [gaplessPlayback] false?
  ///
  /// Having the default value of [gaplessPlayback] be false helps prevent
  /// situations where stale or misleading information might be presented.
  /// Consider the following case:
  ///
  /// We have constructed a 'Person' widget that displays an avatar [Image] of
  /// the currently loaded person along with their name. We could request for a
  /// new person to be loaded into the widget at any time. Suppose we have a
  /// person currently loaded and the widget loads a new person. What happens
  /// if the [Image] fails to load?
  ///
  /// * Option A ([gaplessPlayback] = false): The new person's name is coupled
  /// with a blank image.
  ///
  /// * Option B ([gaplessPlayback] = true): The widget displays the avatar of
  /// the previous person and the name of the newly loaded person.
  ///
  /// This is why the default value is false. Most of the time, when you change
  /// the image provider you're not just changing the image, you're removing the
  /// old widget and adding a new one and not expecting them to have any
  /// relationship. With [gaplessPlayback] on you might accidentally break this
  /// expectation and re-use the old widget.
  final bool gaplessPlayback;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and
  /// VoiceOver on iOS.
  final String? semanticLabel;

  /// Whether to exclude this image from semantics.
  ///
  /// Useful for images which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;

  /// Insets to apply before laying out the image.
  ///
  /// The image will still be painted in the full area.
  final EdgeInsets layoutInsets;

  final ExtendedImageController? controller;

  final Widget? placeholderWidget;
  final Widget? errorWidget;

  @override
  State<ExtendedImage> createState() => _ExtendedImageState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('image', image));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(DiagnosticsProperty<Animation<double>?>('opacity', opacity,
        defaultValue: null));
    properties.add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
        defaultValue: null));
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        defaultValue: null));
    properties.add(EnumProperty<ImageRepeat>('repeat', repeat,
        defaultValue: ImageRepeat.noRepeat));
    properties.add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
        defaultValue: null));
    properties.add(FlagProperty('matchTextDirection',
        value: matchTextDirection, ifTrue: 'match text direction'));
    properties.add(
        StringProperty('semanticLabel', semanticLabel, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>(
        'this.excludeFromSemantics', excludeFromSemantics));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
    properties
        .add(DiagnosticsProperty<EdgeInsets>('layoutInsets', layoutInsets));
  }
}

class _ExtendedImageState extends State<ExtendedImage>
    with WidgetsBindingObserver {
  late final _controller =
      widget.controller ?? ExtendedImageController(LoadState.loading);

  ImageStream? _imageStream;
  bool _isListeningToStream = false;
  late DisposableBuildContext<State<ExtendedImage>> _scrollAwareContext;
  ImageStreamCompleterHandle? _completerHandle;

  ImageStreamListener? _imageStreamListener;

  @override
  Widget build(BuildContext context) {
    final current = ValueListenableBuilder(
      valueListenable: _controller.loadState,
      builder: (_, state, __) => switch (state) {
        LoadState.loading => widget.placeholderWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withValues(alpha: 0.5),
                borderRadius: widget.borderRadius,
              ),
              child: const SizedBox.shrink(),
            ),
        LoadState.completed => _getCompletedWidget(),
        LoadState.failed => widget.errorWidget ??
            Container(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => reLoadImage(),
                child: const Text('Failed to load image'),
              ),
            ),
      },
    );

    final borderRadius = widget.borderRadius;
    final withShape = switch (widget.shape) {
      BoxShape.circle => ClipOval(
          clipBehavior: widget.clipBehavior,
          child: current,
        ),
      _ => borderRadius != null
          ? ClipRRect(
              borderRadius: borderRadius,
              clipBehavior: widget.clipBehavior,
              child: current,
            )
          : current,
    };

    final constraints = widget.constraints;
    final withConstraints = constraints != null
        ? ConstrainedBox(
            constraints: constraints,
            child: withShape,
          )
        : withShape;

    return widget.excludeFromSemantics
        ? withConstraints
        : Semantics(
            container: widget.semanticLabel != null,
            image: true,
            label: widget.semanticLabel ?? '',
            child: withConstraints,
          );
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    _updateInvertColors();
  }

  @override
  void didChangeDependencies() {
    _updateInvertColors();
    _resolveImage();

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream(keepStreamAlive: true);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ExtendedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isListeningToStream) {
      final ImageStreamListener oldListener = _getListener();
      _imageStream!.addListener(_getListener(recreateListener: true));
      _imageStream!.removeListener(oldListener);
    }
    if (widget.image != oldWidget.image) {
      _resolveImage();
    }
  }

  @override
  void dispose() {
    assert(_imageStream != null);

    if (widget.controller == null) {
      _controller.dispose();
    }

    WidgetsBinding.instance.removeObserver(this);
    _stopListeningToStream();
    _completerHandle?.dispose();
    _scrollAwareContext.dispose();
    if (widget.clearMemoryCacheWhenDispose) {
      widget.image
          .obtainCacheStatus(configuration: ImageConfiguration.empty)
          .then((ImageCacheStatus? value) {
        if (value?.keepAlive ?? false) {
          widget.image.evict();
        }
      });
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollAwareContext = DisposableBuildContext<State<ExtendedImage>>(this);
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void reLoadImage() {
    _resolveImage(true);
  }

  Widget _buildExtendedRawImage() {
    return ValueListenableBuilder(
      valueListenable: _controller.invertColors,
      builder: (_, invertColors, __) => ValueListenableBuilder(
        valueListenable: _controller.imageInfo,
        builder: (_, imageInfo, __) => ExtendedRawImage(
          // Do not clone the image, because RawImage is a stateless wrapper.
          // The image will be disposed by this state object when it is not needed
          // anymore, such as when it is unmounted or when the image stream pushes
          // a new image.
          image: imageInfo?.image,
          debugImageLabel: imageInfo?.debugLabel,
          width: widget.width,
          height: widget.height,
          scale: imageInfo?.scale ?? 1.0,
          color: widget.color,
          opacity: widget.opacity,
          colorBlendMode: widget.colorBlendMode,
          fit: widget.fit,
          alignment: widget.alignment,
          repeat: widget.repeat,
          centerSlice: widget.centerSlice,
          matchTextDirection: widget.matchTextDirection,
          invertColors: invertColors,
          isAntiAlias: widget.isAntiAlias,
          filterQuality: widget.filterQuality,
          layoutInsets: widget.layoutInsets,
        ),
      ),
    );
  }

  Widget _getCompletedWidget() {
    return _buildExtendedRawImage();
  }

  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _imageStreamListener = ImageStreamListener(
        _handleImageFrame,
        onError: _loadFailed,
      );
    }
    return _imageStreamListener!;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    _controller.replaceImage(info: imageInfo);
    _controller.changeLoadState(LoadState.completed);
  }

  void _listenToStream() {
    if (_isListeningToStream) {
      return;
    }
    _imageStream!.addListener(_getListener());
    _completerHandle?.dispose();
    _completerHandle = null;
    _isListeningToStream = true;
  }

  void _loadFailed(dynamic exception, StackTrace? stackTrace) {
    _controller.changeLoadState(LoadState.failed);

    if (widget.clearMemoryCacheIfFailed) {
      scheduleMicrotask(() {
        widget.image.evict();
        // PaintingBinding.instance.imageCache.evict(key);
      });
    }
  }

  void _resolveImage([bool rebuild = false]) {
    if (rebuild) {
      widget.image.evict();
    }

    final ScrollAwareImageProvider provider = ScrollAwareImageProvider<Object>(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );

    final ImageStream newStream = provider.resolve(
        createLocalImageConfiguration(context,
            size: widget.width != null && widget.height != null
                ? Size(widget.width!, widget.height!)
                : null));

    if (_controller.imageInfo.value != null &&
        !rebuild &&
        _imageStream?.key == newStream.key) {
      _controller.changeLoadState(LoadState.completed);
    }

    _updateSourceStream(newStream, rebuild: rebuild);
  }

  /// Stops listening to the image stream, if this state object has attached a
  /// listener.
  ///
  /// If the listener from this state is the last listener on the stream, the
  /// stream will be disposed. To keep the stream alive, set `keepStreamAlive`
  /// to true, which create [ImageStreamCompleterHandle] to keep the completer
  /// alive and is compatible with the [TickerMode] being off.
  void _stopListeningToStream({bool keepStreamAlive = false}) {
    if (!_isListeningToStream) {
      return;
    }
    if (keepStreamAlive &&
        _completerHandle == null &&
        _imageStream?.completer != null) {
      _completerHandle = _imageStream!.completer!.keepAlive();
    }
    _imageStream!.removeListener(_getListener());
    _isListeningToStream = false;
  }

  void _updateInvertColors() {
    final invertColors = MediaQuery.maybeInvertColorsOf(context) ??
        SemanticsBinding.instance.accessibilityFeatures.invertColors;
    _controller.changeInvertColors(invertColors);
  }

  void _updateSourceStream(ImageStream newStream, {bool rebuild = false}) {
    if (_imageStream?.key == newStream.key) {
      return;
    }

    if (_isListeningToStream) {
      _imageStream?.removeListener(_getListener());
    }

    if (!widget.gaplessPlayback || rebuild) {
      _controller.clearImage();
      _controller.changeLoadState(LoadState.loading);
    }

    _imageStream = newStream;
    if (_isListeningToStream) {
      _imageStream!.addListener(_getListener());
    }
  }
}
