// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';

class CookieAccessWebViewPage extends ConsumerStatefulWidget {
  const CookieAccessWebViewPage({
    required this.url,
    required this.onGet,
    super.key,
  });

  final String url;
  final void Function(List<Cookie> cookies) onGet;

  @override
  ConsumerState<CookieAccessWebViewPage> createState() =>
      _CookieAccessWebViewPageState();
}

class _CookieAccessWebViewPageState
    extends ConsumerState<CookieAccessWebViewPage> {
  late final Logger _logger;
  final controller = WebViewController();

  void _log(String message) => _logger.info(
    'Login',
    'login=${identityHashCode(this)} $message',
  );

  @override
  void initState() {
    super.initState();

    _logger = ref.read(loggerProvider);
    _log('opened host=${Uri.parse(widget.url).host}');
    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) =>
              _log('page started host=${Uri.tryParse(url)?.host}'),
          onPageFinished: (url) =>
              _log('page finished host=${Uri.tryParse(url)?.host}'),
          onWebResourceError: (error) => _log(
            'resource error code=${error.errorCode} type=${error.errorType} mainFrame=${error.isForMainFrame}',
          ),
        ),
      )
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  void dispose() {
    _log('closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Login'.hc),
      ),
      body: Column(
        children: [
          _buildBanner('Press the button below after you logged in.'.hc),
          FilledButton(
            onPressed: () async {
              _log('cookie access requested');
              final List<Cookie> cookies;
              try {
                final webViewCookies = await WebViewCookieManager().getCookies(
                  domain: Uri.parse(widget.url),
                );
                cookies = [
                  for (final cookie in webViewCookies)
                    Cookie(cookie.name, cookie.value)
                      ..domain = cookie.domain
                      ..path = cookie.path,
                ];
              } catch (error) {
                _log('cookie access failed type=${error.runtimeType}');
                rethrow;
              }
              _log(
                'cookie access count=${cookies.length} passHashPresent=${cookies.any((c) => c.name == 'pass_hash')} userIdPresent=${cookies.any((c) => c.name == 'user_id')}',
              );
              widget.onGet(cookies);
            },
            child: Text('Access Cookie'.hc),
          ),
          const SizedBox(height: 16),
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
          color: Colors.white,
        ),
      ),
      width: MediaQuery.widthOf(context),
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
