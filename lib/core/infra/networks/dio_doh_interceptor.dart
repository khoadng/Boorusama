// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum DnsRecordType {
  A,
  AAAA,
  MX,
  CNAME,
}

enum DnsProvider {
  cloudflare,
  google,
}

class DohInterceptor extends Interceptor {
  DohInterceptor({
    required String dnsUrl,
    required DnsRecordType recordType,
  })  : _dnsUrl = dnsUrl,
        _dnsType = recordType;

  final String _dnsUrl;
  final DnsRecordType _dnsType;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final resolvedHost = await _resolveHostUsingDns(options.uri.host);
    print(resolvedHost);

    var uri = Uri.parse(options.uri.toString());
    var modifiedUri = uri.replace(host: resolvedHost);
    var modifiedOptions = options.copyWith(baseUrl: modifiedUri.toString());

    return handler.next(modifiedOptions);
  }

  Future<String?> _resolveHostUsingDns(String host) async {
    final queryParams = {
      'name': host,
      'type': _dnsType
          .toString()
          .split('.')
          .last, // convert DnsRecordType to String
    };

    final headers = {
      'Accept': 'application/dns-json',
    };

    final response = await http.get(
      Uri.parse(_dnsUrl).replace(queryParameters: queryParams),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final List<dynamic> answers = responseBody['Answer'] ?? [];

      if (answers.isNotEmpty) {
        for (final answer in answers) {
          if (answer['type'] == 1) {
            return answer['data'];
          }
        }
      }
    }

    return null;
  }

  factory DohInterceptor.from(
    DnsProvider provider, {
    DnsRecordType type = DnsRecordType.A,
  }) =>
      DohInterceptor(
        dnsUrl: _mapProviderToUrl(provider),
        recordType: type,
      );
}

String _mapProviderToUrl(DnsProvider provider) {
  switch (provider) {
    case DnsProvider.cloudflare:
      return 'https://cloudflare-dns.com/dns-query';
    case DnsProvider.google:
      return 'https://dns.google/resolve';
  }
}
