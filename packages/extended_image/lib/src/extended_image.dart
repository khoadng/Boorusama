import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:extended_image/src/image/raw_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:path/path.dart' as path;
import 'package:retriable/retriable.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart'
    as avif_platform;

import 'dio_extended_image_provider.dart';
import 'utils.dart';

const kDefaultImageCacheDuration = Duration(hours: 1);

bool shouldUseAvif(
  String url, {
  TargetPlatform? platform,
  int? androidVersion,
}) {
  final endsWithAvif = _sanitizedUrl(url).endsWith('.avif');

  return switch (platform) {
    TargetPlatform.android =>
      androidVersion == null || androidVersion > 30 ? false : endsWithAvif,
    TargetPlatform.iOS || TargetPlatform.macOS || null => false,
    _ => endsWithAvif,
  };
}

String _sanitizedUrl(String url) {
  final ext = path.extension(url);
  final indexOfQuestionMark = ext.indexOf('?');

  if (indexOfQuestionMark != -1) {
    final trimmedExt = ext.substring(0, indexOfQuestionMark);

    return url.replaceFirst(ext, trimmedExt);
  } else {
    return url;
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
    this.fit,
    this.alignment = Alignment.center,
    this.gaplessPlayback = false,
    this.borderRadius,
    this.clearMemoryCacheIfFailed = true,
    this.clearMemoryCacheWhenDispose = false,
    this.controller,
    this.placeholderWidget,
    this.errorWidget,
  })  : assert(constraints == null || constraints.debugAssertIsValid()),
        _avif = false,
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
    this.fit,
    this.alignment = Alignment.center,
    this.gaplessPlayback = false,
    this.borderRadius,
    this.clearMemoryCacheIfFailed = true,
    BoxConstraints? constraints,
    CancellationToken? cancelToken,
    Map<String, String>? headers,
    bool cache = true,
    double scale = 1.0,
    this.clearMemoryCacheWhenDispose = false,
    int? cacheWidth,
    int? cacheHeight,
    String? cacheKey,
    bool printError = true,
    double? compressionRatio,
    int? maxBytes,
    bool cacheRawData = false,
    String? imageCacheName,
    Duration? cacheMaxAge,
    FetchStrategyBuilder? fetchStrategy,
    required Dio dio,
    this.controller,
    this.placeholderWidget,
    this.errorWidget,
    TargetPlatform? platform,
    int? androidVersion,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        _avif = shouldUseAvif(
          url,
          platform: platform,
          androidVersion: androidVersion,
        ),
        image = ExtendedResizeImage.resizeIfNeeded(
          provider: shouldUseAvif(
            url,
            platform: platform,
            androidVersion: androidVersion,
          )
              ? CachedNetworkAvifImageProvider(
                  url,
                  scale: scale,
                  headers: headers,
                )
              : DioExtendedNetworkImageProvider(
                  url,
                  dio: dio,
                  scale: scale,
                  headers: headers,
                  cache: cache,
                  cancelToken: cancelToken,
                  cacheKey: cacheKey,
                  printError: printError,
                  cacheRawData: cacheRawData,
                  imageCacheName: imageCacheName,
                  cacheMaxAge: cacheMaxAge ?? kDefaultImageCacheDuration,
                  fetchStrategy: fetchStrategy,
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

  final bool _avif;

  /// when image is removed from the tree permanently, whether clear memory cache
  final bool clearMemoryCacheWhenDispose;

  ///when failed to load image, whether clear memory cache
  ///if true, image will reload in next time.
  final bool clearMemoryCacheIfFailed;

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
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        defaultValue: null));
    properties.add(
        StringProperty('semanticLabel', semanticLabel, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>(
        'this.excludeFromSemantics', excludeFromSemantics));
  }
}

class _ExtendedImageState extends State<ExtendedImage>
    with WidgetsBindingObserver {
  late final _controller = widget.controller ?? ExtendedImageController();

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

    final constraints = widget.constraints;
    final withConstraints = constraints != null
        ? ConstrainedBox(
            constraints: constraints,
            child: current,
          )
        : current;

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
  void didChangeDependencies() {
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
      if (widget._avif) {
        final avifFfi = avif_platform.FlutterAvifPlatform.api;
        avifFfi.disposeDecoder(key: oldWidget.image.hashCode.toString());
      }

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

  Widget _getCompletedWidget() {
    return _InheritedImageOptions(
      options: _ImageOptions(
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        borderRadius: widget.borderRadius,
      ),
      child: ValueListenableBuilder(
        valueListenable: _controller.imageInfo,
        builder: (_, info, child) => _InheritedImageInfo(
          imageInfo: info,
          child: child!,
        ),
        child: const _RawImage(),
      ),
    );
  }

  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _imageStreamListener = ImageStreamListener(
        _handleImageFrame,
        onError: _loadFailed,
        onChunk: (event) {
          _controller.updateBytesLoaded(
            event.cumulativeBytesLoaded,
            event.expectedTotalBytes,
          );
        },
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

    if (_imageStream?.completer != null &&
        (_imageStream!.completer! is AvifImageStreamCompleter) &&
        !(_imageStream!.completer! as AvifImageStreamCompleter)
            .getHasListeners() &&
        !PaintingBinding.instance.imageCache.containsKey(widget.image)) {
      final avifFfi = avif_platform.FlutterAvifPlatform.api;
      avifFfi.disposeDecoder(key: widget.image.hashCode.toString());
    }
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

class _ImageOptions extends Equatable {
  const _ImageOptions({
    this.width,
    this.height,
    this.fit,
    this.alignment,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;
  final BorderRadius? borderRadius;

  @override
  List<Object?> get props => [
        width,
        height,
        fit,
        alignment,
        borderRadius,
      ];
}

class ExtendedImageController extends ChangeNotifier {
  ExtendedImageController({
    this.initialLoadState = LoadState.loading,
  });

  final LoadState initialLoadState;
  late final loadState = ValueNotifier(initialLoadState);
  late final imageInfo = ValueNotifier<ImageInfo?>(null);
  late final progress = ValueNotifier<double?>(null);

  final _cumulativeBytesLoaded = ValueNotifier<int?>(null);
  final _expectedTotalBytes = ValueNotifier<int?>(null);

  int? get cumulativeBytesLoaded => _cumulativeBytesLoaded.value;
  int? get expectedTotalBytes => _expectedTotalBytes.value;

  void updateBytesLoaded(int loaded, int? total) {
    _cumulativeBytesLoaded.value = loaded;
    _expectedTotalBytes.value = total;

    if (total != null && total > 0) {
      progress.value = loaded / total;
    }
  }

  void changeLoadState(LoadState state) {
    loadState.value = state;
    if (state != LoadState.loading) {
      _cumulativeBytesLoaded.value = null;
      _expectedTotalBytes.value = null;
      progress.value = null;
    }
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
    progress.dispose();
    _cumulativeBytesLoaded.dispose();
    _expectedTotalBytes.dispose();
    super.dispose();
  }
}

class _InheritedImageInfo extends InheritedWidget {
  const _InheritedImageInfo({
    required this.imageInfo,
    required super.child,
  });

  final ImageInfo? imageInfo;

  static ImageInfo? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_InheritedImageInfo>();

    return result?.imageInfo;
  }

  @override
  bool updateShouldNotify(_InheritedImageInfo oldWidget) {
    return imageInfo != oldWidget.imageInfo;
  }
}

class _InheritedImageOptions extends InheritedWidget {
  const _InheritedImageOptions({
    required this.options,
    required super.child,
  });

  final _ImageOptions options;

  static _ImageOptions of(BuildContext context) {
    final _InheritedImageOptions? result =
        context.dependOnInheritedWidgetOfExactType<_InheritedImageOptions>();

    if (result == null) {
      throw FlutterError(
          '_ImageOptions.of() called with a context that does not contain an _ImageOptions.\n'
          'No _ImageOptions ancestor could be found starting from the context that was passed to _ImageOptions.of(). '
          'This can happen because you do not have a _ImageOptions widget above the Image widget building your image.\n'
          'The context used was:\n'
          '  $context');
    }

    return result.options;
  }

  @override
  bool updateShouldNotify(_InheritedImageOptions oldWidget) {
    return options != oldWidget.options;
  }
}

class _RawImage extends StatelessWidget {
  const _RawImage();

  @override
  Widget build(BuildContext context) {
    final options = _InheritedImageOptions.of(context);
    final imageInfo = _InheritedImageInfo.of(context);

    _print(
      'raw image build: ${imageInfo?.image.width}x${imageInfo?.image.height} hashcode: ${imageInfo?.image.hashCode}, scale: ${imageInfo?.scale}, options: $options',
    );

    return ExtendedRawImage(
      // Do not clone the image, because RawImage is a stateless wrapper.
      // The image will be disposed by this state object when it is not needed
      // anymore, such as when it is unmounted or when the image stream pushes
      // a new image.
      image: imageInfo?.image,
      debugImageLabel: imageInfo?.debugLabel,
      width: options.width,
      height: options.height,
      scale: imageInfo?.scale ?? 1.0,
      fit: options.fit,
      alignment: options.alignment ?? Alignment.center,
      borderRadius: options.borderRadius,
    );
  }
}

void _print(String message) {
  if (kDebugMode) {
    // debugPrint('[ExtendedImage] $message');
  }
}
