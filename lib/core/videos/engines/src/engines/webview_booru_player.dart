// Dart imports:
import 'dart:async';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:path/path.dart' as p;
import 'package:kurumi/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/platform.dart';
import '../../../../themes/colors/types.dart';
import '../../../lock/types.dart';
import '../types/booru_player.dart';
import '../types/video_source.dart';

/// WebView-based implementation of BooruPlayer for WEBM files
///
/// This implementation uses WebView with JavaScript to control WEBM video playback.
class WebViewBooruPlayer implements BooruPlayer {
  WebViewBooruPlayer({
    required this.wakelock,
    required this.platform,
    required this.fileSystem,
    String? userAgent,
    Color backgroundColor = Colors.black,
  }) : _userAgent = userAgent,
       _backgroundColor = backgroundColor;

  final Wakelock wakelock;
  final AppPlatform platform;
  final AppFileSystem fileSystem;
  final String? _userAgent;
  final Color _backgroundColor;

  WebViewController? _webViewController;
  Timer? _positionTimer;
  Timer? _positionCheckTimer;

  final _positionController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _bufferingController = StreamController<bool>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  var _isDisposed = false;
  var _isPlaying = false;
  var _hasPlayedOnce = false;

  @override
  final ValueNotifier<bool> firstFrameRendered = ValueNotifier(false);
  var _sourceGeneration = 0;
  var _isPageLoaded = false;
  var _hasPendingPlay = false;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  String? _currentUrl;

  // Page written next to a cached video so the WebView can read the file
  String? _pagePath;

  @override
  bool isPlatformSupported() =>
      platform != AppPlatform.windows && platform != AppPlatform.linux;

  Future<void> _setupWebViewController() async {
    final params = switch (platform.isIOS || platform == AppPlatform.macos) {
      true => WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      ),
      false => const PlatformWebViewControllerCreationParams(),
    };

    final controller = WebViewController.fromPlatformCreationParams(params);
    _webViewController = controller;

    await Future.wait([
      controller.setUserAgent(_userAgent),
      controller.setVerticalScrollBarEnabled(false),
      controller.setHorizontalScrollBarEnabled(false),
      controller.setOverScrollMode(WebViewOverScrollMode.never),
      controller.setJavaScriptMode(JavaScriptMode.unrestricted),
      controller.addJavaScriptChannel(
        'FirstVideoFrame',
        onMessageReceived: (message) {
          if (!_isDisposed && message.message == '$_sourceGeneration') {
            firstFrameRendered.value = true;
          }
        },
      ),
      // Skip setBackgroundColor on macOS due to unimplemented opaque property
      if (platform != AppPlatform.macos)
        controller.setBackgroundColor(_backgroundColor),
      if (controller.platform
          case final AndroidWebViewController androidController) ...[
        AndroidWebViewController.enableDebugging(false),
        androidController.setMediaPlaybackRequiresUserGesture(false),
      ],
    ]);
  }

  Future<void> _loadVideo(VideoSource source, bool autoplay) async {
    final controller = _webViewController;
    if (controller == null) return;
    _sourceGeneration++;
    firstFrameRendered.value = false;

    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          _onPageLoadComplete(autoplay);
        },
        onWebResourceError: (error) {
          // Fallback: mark as loaded even on error to prevent hanging
          if (!_isPageLoaded) {
            _onPageLoadComplete(autoplay);
          }
        },
      ),
    );

    final html = _videoHtml(
      source,
      backgroundColor: _backgroundColor,
      muted: false, // Will be set via setVolume
      autoplay: autoplay,
    );

    switch (source) {
      case StreamingVideoSource():
        await _deletePage();
        if (controller.platform case final AndroidWebViewController android) {
          await android.setAllowFileAccess(false);
        }
        await controller.loadHtmlString(html);
      case CachedVideoSource(:final filePath):
        await _loadCachedPage(controller, html, filePath);
    }

    // Fallback: if page doesn't trigger onPageFinished within 2 seconds,
    // assume it's loaded (common issue with loadHtmlString on some platforms)
    Timer(const Duration(seconds: 2), () {
      if (!_isPageLoaded) {
        _onPageLoadComplete(autoplay);
      }
    });
  }

  // WebViews only read local files from a page that is itself a local file,
  // so the page is written beside the video and read access is limited to
  // the video's directory.
  Future<void> _loadCachedPage(
    WebViewController controller,
    String html,
    String videoPath,
  ) async {
    final videoDir = p.dirname(videoPath);
    final pagePath = p.join(
      videoDir,
      _kPageDirName,
      'player_${identityHashCode(this)}.html',
    );

    final pageDir = p.dirname(pagePath);

    // Pages from a previous run are left behind when the app is killed
    if (!_stalePagesPruned) {
      _stalePagesPruned = true;
      if (await fileSystem.directoryExists(pageDir)) {
        await fileSystem.deleteDirectory(pageDir, recursive: true);
      }
    }

    await fileSystem.createDirectory(pageDir, recursive: true);
    await fileSystem.writeString(pagePath, html);
    _pagePath = pagePath;

    switch (controller.platform) {
      case final WebKitWebViewController webKit:
        await webKit.loadFileWithParams(
          WebKitLoadFileParams(
            absoluteFilePath: pagePath,
            readAccessPath: videoDir,
          ),
        );
      case _:
        await controller.loadFile(pagePath);
    }
  }

  Future<void> _deletePage() async {
    final pagePath = _pagePath;
    if (pagePath == null) return;

    _pagePath = null;
    await fileSystem.deleteFileIfExists(pagePath);
  }

  void _resetState() {
    _hasPlayedOnce = false;
    _isPageLoaded = false;
    _hasPendingPlay = false;
    _currentPosition = Duration.zero;
    _currentDuration = Duration.zero;
  }

  @override
  Future<void> initialize(
    VideoSource source, {
    VideoConfig? config,
  }) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    _currentUrl = source.url;
    await _setupWebViewController();
    await _loadVideo(source, config?.autoplay ?? false);
  }

  @override
  Future<void> switchUrl(
    VideoSource source, {
    VideoConfig? config,
  }) async {
    if (_isDisposed || _webViewController == null) return;

    if (_currentUrl == source.url) return;

    await pause();
    await setVolume(0);

    _currentUrl = source.url;
    _resetState();
    await _loadVideo(source, config?.autoplay ?? false);
  }

  Future<dynamic> _runJavaScriptSafely(
    String script, {
    bool returningResult = false,
    String? errorContext,
  }) async {
    if (_webViewController == null || !_isPageLoaded) return null;

    try {
      if (returningResult) {
        return await _webViewController!.runJavaScriptReturningResult(script);
      } else {
        return await _webViewController!.runJavaScript(script);
      }
    } catch (e) {
      final context = errorContext ?? 'JavaScript execution';
      debugPrint('WebViewBooruPlayer: $context failed - $e');
      return null;
    }
  }

  double _parseToDouble(dynamic value) => switch (value) {
    null => 0.0,
    final double d when d.isNaN || d.isInfinite => 0.0,
    final double d => d,
    final int i => i.toDouble(),
    final String s => double.tryParse(s) ?? 0.0,
    _ => 0.0,
  };

  void _onPageLoadComplete(bool autoplay) {
    if (_isDisposed || _isPageLoaded) return;

    _isPageLoaded = true;
    // Start position monitoring only after page is loaded
    _startPositionTimer();

    // Handle autoplay or pending play request
    if (autoplay || _hasPendingPlay) {
      _hasPendingPlay = false;
      // Use a small delay to ensure the video element is fully ready
      Timer(const Duration(milliseconds: 100), () {
        if (!_isDisposed) {
          play(); // This will properly set the state and call JavaScript
        }
      });
    }
  }

  void _onPositionChanged(double current, double total) {
    if (_isDisposed) return;

    _currentPosition = Duration(milliseconds: (current * 1000).toInt());
    _currentDuration = Duration(milliseconds: (total * 1000).toInt());

    _addToStream(_positionController, _currentPosition);
    _addToStream(_durationController, _currentDuration);
  }

  void _addToStream<T>(StreamController<T> controller, T value) {
    if (controller.isClosed) return;
    controller.add(value);
  }

  void _startPositionTimer() {
    _positionCheckTimer?.cancel();
    _positionCheckTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      if (_isDisposed || _webViewController == null) {
        timer.cancel();
        return;
      }

      if (_isPlaying) {
        _updatePosition();
      }
    });
  }

  Future<void> _updatePosition() async {
    if (!_isPageLoaded) return;

    final currentTime = await _runJavaScriptSafely(
      'document.getElementById("video").currentTime;',
      returningResult: true,
      errorContext: 'Getting current time',
    );
    final duration = await _runJavaScriptSafely(
      'document.getElementById("video").duration;',
      returningResult: true,
      errorContext: 'Getting duration',
    );

    final current = _parseToDouble(currentTime);
    final total = _parseToDouble(duration);

    _onPositionChanged(current, total);
  }

  String _videoHtml(
    VideoSource source, {
    Color backgroundColor = Colors.black,
    bool? muted,
    bool autoplay = false,
  }) {
    final url = source.url;
    final colorText = backgroundColor.hexWithoutAlpha;
    final mutedText = (muted ?? false) ? 'muted' : '';
    // Can't really autoplay in WebView, user gesture needed (except on Android maybe)
    final autoplayValue =
        (_webViewController?.platform is AndroidWebViewController)
        ? autoplay
        : false;
    final autoplayText = autoplayValue ? 'autoplay' : '';
    final videoType = source.mimeType;

    return '''
<!DOCTYPE html>
<html>
<head>
<style>
  body {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
    background-color: $colorText;
  }
  video {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
  }
</style>
</head>
<body>
  <video id="video" allowfullscreen playsinline width="100%" height="100%" style="background-color:$colorText;" $mutedText $autoplayText loop poster="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7">
    <source src="$url#t=0.01" type="$videoType" />
  </video>
  <script>
    document.getElementById('video').requestVideoFrameCallback(function() {
      FirstVideoFrame.postMessage('$_sourceGeneration');
    });
  </script>
</body>
</html>''';
  }

  @override
  Future<void> play() async {
    if (_isDisposed || _webViewController == null) return;

    // If page not loaded yet, queue the play request
    if (!_isPageLoaded) {
      _hasPendingPlay = true;
      return;
    }

    await _runJavaScriptSafely(
      'document.getElementById("video").play();',
      errorContext: 'Playing video',
    );
    _isPlaying = true;
    wakelock.enable();
    if (!_hasPlayedOnce) {
      _hasPlayedOnce = true;
    }

    _addToStream(_playingController, true);
  }

  @override
  Future<void> pause() async {
    if (_isDisposed || _webViewController == null || !_isPageLoaded) return;

    await _runJavaScriptSafely(
      'document.getElementById("video").pause();',
      errorContext: 'Pausing video',
    );
    _isPlaying = false;
    wakelock.disable();
    _addToStream(_playingController, false);
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed || _webViewController == null || !_isPageLoaded) return;

    final seconds = position.inSeconds.toDouble();
    await _runJavaScriptSafely(
      'document.getElementById("video").currentTime = $seconds;',
      errorContext: 'Seeking to position ${position.inSeconds}s',
    );
    _currentPosition = position;

    _addToStream(_positionController, position);
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_isDisposed || _webViewController == null || !_isPageLoaded) return;

    // Convert 0.0-1.0 range to boolean muted state for WebView
    final muted = volume == 0.0;
    await _runJavaScriptSafely(
      'document.getElementById("video").muted = $muted;',
      errorContext: 'Setting volume (muted: $muted)',
    );
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (_isDisposed || _webViewController == null || !_isPageLoaded) return;

    await _runJavaScriptSafely(
      'document.getElementById("video").playbackRate = $speed;',
      errorContext: 'Setting playback speed to $speed',
    );
  }

  @override
  Future<void> setLooping(bool loop) async {
    if (_isDisposed || _webViewController == null || !_isPageLoaded) return;

    await _runJavaScriptSafely(
      'document.getElementById("video").loop = $loop;',
      errorContext: 'Setting loop to $loop',
    );
  }

  @override
  bool get isPlaying => _isDisposed ? false : _isPlaying;

  @override
  Duration get position => _isDisposed ? Duration.zero : _currentPosition;

  @override
  Duration get duration => _isDisposed ? Duration.zero : _currentDuration;

  @override
  double get aspectRatio {
    // WebView doesn't provide easy access to video dimensions,
    // so we return a reasonable default
    return 16.0 / 9.0;
  }

  @override
  int? get width => null; // Not available in WebView implementation

  @override
  int? get height => null; // Not available in WebView implementation

  @override
  bool get isBuffering => false; // WebView doesn't expose buffering state easily

  @override
  bool get hasPlayedOnce => _hasPlayedOnce;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<bool> get bufferingStream => _bufferingController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Widget buildPlayerWidget(BuildContext context) {
    if (_isDisposed || _webViewController == null || _currentUrl == null) {
      return const SizedBox.shrink();
    }

    return KurumiHero(
      tag: null,
      child: ColoredBox(
        color: _backgroundColor,
        child: IgnorePointer(
          child: WebViewWidget(
            controller: _webViewController!,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    firstFrameRendered.dispose();

    wakelock.disable();

    _positionCheckTimer?.cancel();
    _positionTimer?.cancel();
    // https://github.com/flutter/flutter/issues/119616
    // Workaround to stop video from continuing to play in background on Apple devices
    if (isApple()) {
      _webViewController?.loadRequest(Uri.parse('about:blank'));
    }

    _positionController.close();
    _playingController.close();
    _bufferingController.close();
    _durationController.close();

    unawaited(_deletePage());
  }
}

const _kPageDirName = 'webview';

var _stalePagesPruned = false;
