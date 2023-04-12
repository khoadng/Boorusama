// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum DnsRecordType {
  A,
  AAAA,
  CNAME,
  MX,
  NS,
  PTR,
  SOA,
  SRV,
  TXT,
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

    var uri = Uri.parse(options.uri.toString());
    var headers = options.headers;
    headers['Host'] = options.uri.host;
    var modifiedUri = uri.replace(host: resolvedHost);
    var modifiedOptions = options.copyWith(
      baseUrl: modifiedUri.toString(),
      headers: headers,
    );

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
          if (answer['type'] == dnsRecordTypeToInt(_dnsType)) {
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

int dnsRecordTypeToInt(DnsRecordType type) {
  switch (type) {
    case DnsRecordType.A:
      return 1;
    case DnsRecordType.AAAA:
      return 28;
    case DnsRecordType.CNAME:
      return 5;
    case DnsRecordType.MX:
      return 15;
    case DnsRecordType.NS:
      return 2;
    case DnsRecordType.PTR:
      return 12;
    case DnsRecordType.SOA:
      return 6;
    case DnsRecordType.SRV:
      return 33;
    case DnsRecordType.TXT:
      return 16;
    default:
      throw ArgumentError('Invalid DNS record type');
  }
}

DnsRecordType intToDnsRecordType(int value) {
  switch (value) {
    case 1:
      return DnsRecordType.A;
    case 28:
      return DnsRecordType.AAAA;
    case 5:
      return DnsRecordType.CNAME;
    case 15:
      return DnsRecordType.MX;
    case 2:
      return DnsRecordType.NS;
    case 12:
      return DnsRecordType.PTR;
    case 6:
      return DnsRecordType.SOA;
    case 33:
      return DnsRecordType.SRV;
    case 16:
      return DnsRecordType.TXT;
    default:
      throw ArgumentError('Invalid DNS record type integer value');
  }
}
