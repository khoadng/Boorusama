// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/toast.dart';

const kCloudflareClearanceKey = 'cf_clearance';
const kCloudflareChallengeTrace = 'cf_chl';

const kDefaultCloudflareChallengeTriggerStatus = {
  403,
};

class CloudflareChallengeInterceptor extends Interceptor {
  CloudflareChallengeInterceptor({
    required String storagePath,
    required this.context,
    this.triggerOnStatus = kDefaultCloudflareChallengeTriggerStatus,
  }) : cookieJar = PersistCookieJar(
          storage: FileStorage(storagePath),
        );

  var _userAgent = '';
  late final PersistCookieJar cookieJar;
  var _block = false;
  var _disable = false;
  final BuildContext context;
  final Set<int> triggerOnStatus;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_disable) {
      return super.onRequest(options, handler);
    }

    try {
      final cookies = await cookieJar.loadForRequest(options.uri);

      if (cookies.isNotEmpty && cookies.hasClearance) {
        if (_userAgent.isEmpty) {
          final webviewController = WebViewController();
          final ua = await webviewController.getUserAgent();
          if (ua == null) {
            _disable = true;
            return super.onRequest(options, handler);
          }

          _userAgent = ua;
        }

        options.headers.addAll({
          AppHttpHeaders.cookieHeader: cookies.cookieString,
          AppHttpHeaders.userAgentHeader: _userAgent,
        });
      }
    } catch (e) {
      _disable = true;
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_disable) {
      return handler.next(err);
    }

    final statusCode = err.response?.statusCode;
    if (triggerOnStatus.contains(statusCode)) {
      final body = err.response?.data;

      if (body is String &&
          body.toLowerCase().contains(kCloudflareChallengeTrace)) {
        if (_block) {
          // if we already open the webview, we should not open it again
          return handler.next(err);
        }
        _block = true;

        // open webview to solve cloudflare challenge
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) {
              return CloudflareChallengeSolverPage(
                url: err.requestOptions.uri.toString(),
                onCfClearance: (cookies) {
                  // set cookies
                  cookieJar.saveFromResponse(err.requestOptions.uri, cookies);
                  _block = false;

                  showSuccessToast(
                    context,
                    'Cloudflare challenge solved, you can close this screen now',
                  );
                },
              );
            },
          ),
        );
      }
    }

    return handler.next(err);
  }
}

extension CookieJarX on List<Cookie> {
  bool get hasClearance => any((e) => e.name == kCloudflareClearanceKey);
  String get cookieString => map((e) => e.toString()).join('; ');
}

class CloudflareChallengeSolverPage extends StatefulWidget {
  const CloudflareChallengeSolverPage({
    super.key,
    required this.url,
    required this.onCfClearance,
  });

  final String url;
  final void Function(List<Cookie> cookies) onCfClearance;

  @override
  State<CloudflareChallengeSolverPage> createState() =>
      _CloudflareChallengeSolverPageState();
}

class _CloudflareChallengeSolverPageState
    extends State<CloudflareChallengeSolverPage> {
  final WebViewController controller = WebViewController();

  @override
  void initState() {
    super.initState();

    final cookieManager = WebviewCookieManager();
    final urlWithoutQuery = Uri.parse(widget.url).replace(query: '').toString();

    controller.loadRequest(Uri.parse(widget.url));
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) async {
        final cookies = await cookieManager.getCookies(urlWithoutQuery);

        if (cookies.isNotEmpty) {
          widget.onCfClearance(cookies);
          return;
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cloudflare Challenge Solver'),
      ),
      body: Column(
        children: [
          _buildBanner(
              'Please stay on this screen and wait until the challenge is solved'),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
