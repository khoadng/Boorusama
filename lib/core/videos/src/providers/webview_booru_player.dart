// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Project imports:
import '../../../../foundation/utils/color_utils.dart';
import '../../../../foundation/utils/object_utils.dart';
import '../../../widgets/widgets.dart';
import '../types/booru_player.dart';

/// WebView-based implementation of BooruPlayer for WEBM files
///
/// This implementation uses WebView with JavaScript to control WEBM video playback.
class WebViewBooruPlayer implements BooruPlayer {
  WebViewBooruPlayer({
    String? userAgent,
    Color backgroundColor = Colors.black,
  }) : _userAgent = userAgent,
       _backgroundColor = backgroundColor;

  final String? _userAgent;
  final Color _backgroundColor;

  WebViewController? _webViewController;
  Timer? _positionTimer;
  Timer? _positionCheckTimer;

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  bool _isDisposed = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  String? _currentUrl;

  @override
  Future<void> initialize(String url, {Map<String, String>? headers}) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    _currentUrl = url;

    _webViewController = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams(),
    );
    await _webViewController!.setUserAgent(_userAgent);
    await _webViewController!.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _webViewController!.setBackgroundColor(_backgroundColor);

    if (_webViewController!.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(false);
      await (_webViewController!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    final html = _urlToHtml(
      url,
      backgroundColor: _backgroundColor,
      muted: false, // Will be set via setVolume
    );

    await _webViewController!.loadHtmlString(html);

    // Start position monitoring timer
    _startPositionTimer();
  }

  void _onPositionChanged(double current, double total) {
    if (_isDisposed) return;

    _currentPosition = Duration(milliseconds: (current * 1000).toInt());
    _currentDuration = Duration(milliseconds: (total * 1000).toInt());

    _positionController.add(_currentPosition);
    _durationController.add(_currentDuration);
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
    try {
      final currentTime = await _webViewController!
          .runJavaScriptReturningResult(
            'document.getElementById("video").currentTime;',
          );
      final duration = await _webViewController!.runJavaScriptReturningResult(
        'document.getElementById("video").duration;',
      );

      final current = currentTime.toDoubleOrNull() ?? 0;
      final total = duration.toDoubleOrNull() ?? 0;

      _onPositionChanged(current, total);
    } catch (e) {
      // Ignore errors during position updates
    }
  }

  String _urlToHtml(
    String url, {
    Color backgroundColor = Colors.black,
    bool? muted,
  }) {
    final colorText = backgroundColor.hexWithoutAlpha;
    final mutedText = muted == true ? 'muted' : '';
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
  <video id="video" allowfullscreen width="100%" height="100%" style="background-color:$colorText;" $mutedText loop poster="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7">
    <source src="$url#t=0.01" type="video/webm" />
  </video>
</body>
</html>''';
  }

  @override
  Future<void> play() async {
    if (_isDisposed || _webViewController == null) return;

    await _webViewController!.runJavaScript(
      'document.getElementById("video").play();',
    );
    _isPlaying = true;
    _playingController.add(true);
  }

  @override
  Future<void> pause() async {
    if (_isDisposed || _webViewController == null) return;

    await _webViewController!.runJavaScript(
      'document.getElementById("video").pause();',
    );
    _isPlaying = false;
    _playingController.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed || _webViewController == null) return;

    final seconds = position.inSeconds.toDouble();
    await _webViewController!.runJavaScript(
      'document.getElementById("video").currentTime = $seconds;',
    );
    _currentPosition = position;
    _positionController.add(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_isDisposed || _webViewController == null) return;

    // Convert 0.0-1.0 range to boolean muted state for WebView
    final muted = volume == 0.0;
    await _webViewController!.runJavaScript(
      'document.getElementById("video").muted = $muted;',
    );
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (_isDisposed || _webViewController == null) return;

    await _webViewController!.runJavaScript(
      'document.getElementById("video").playbackRate = $speed;',
    );
  }

  @override
  Future<void> setLooping(bool loop) async {
    if (_isDisposed || _webViewController == null) return;

    await _webViewController!.runJavaScript(
      'document.getElementById("video").loop = $loop;',
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

    return BooruHero(
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

    _positionCheckTimer?.cancel();
    _positionTimer?.cancel();
    // WebViewController doesn't need explicit disposal

    _positionController.close();
    _playingController.close();
    _bufferingController.close();
    _durationController.close();
  }
}
