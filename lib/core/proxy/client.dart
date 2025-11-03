// Dart imports:
import 'dart:io';

// Package imports:
import 'package:socks5_proxy/socks.dart' as socks;

// Project imports:
import '../../foundation/loggers.dart';
import 'types.dart';

HttpClient createProxyHttpClient(
  ProxySettings settings, {
  Logger? logger,
}) {
  logger?.info(
    'Network',
    'Using proxy: ${settings.type.name.toUpperCase()} ${settings.host}:${settings.port}',
  );

  final client = HttpClient();

  switch (settings.type) {
    case ProxyType.socks5:
      _configureSockProxy(client, settings);
    case ProxyType.http:
      _configureHttpProxy(client, settings);
    case ProxyType.unknown:
      break;
  }

  return client;
}

void _configureSockProxy(HttpClient client, ProxySettings settings) {
  socks.SocksTCPClient.assignToHttpClient(
    client,
    [
      socks.ProxySettings(
        InternetAddress(settings.host),
        settings.port,
        username: settings.username,
        password: settings.password,
      ),
    ],
  );
}

void _configureHttpProxy(
  HttpClient client,
  ProxySettings settings,
) {
  final credentials = switch ((settings.username, settings.password)) {
    (final user?, final pass?) => HttpClientBasicCredentials(user, pass),
    _ => null,
  };

  client.badCertificateCallback = (cert, host, port) => true;
  client.findProxy = (uri) => 'PROXY ${settings.host}:${settings.port}';

  if (credentials case final creds?) {
    client.addProxyCredentials(
      settings.host,
      settings.port,
      'main',
      creds,
    );
  }
}
